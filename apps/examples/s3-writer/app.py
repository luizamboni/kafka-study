import argparse
from sqlite3 import Timestamp
from kafka import KafkaConsumer
import argparse
import struct
import requests
import os
from jsonschema import validate
import awswrangler as wr
import json
import uuid
import threading
import pandas as pd
import time
from datetime import datetime

from queue import Queue


class SetInterval:
    def __init__(self,interval,action) :
        self.interval=interval
        self.action=action
        self.stopEvent=threading.Event()
        thread=threading.Thread(target=self.__setInterval)
        thread.start()

    def __setInterval(self) :
        nextTime=time.time()+self.interval
        while not self.stopEvent.wait(nextTime-time.time()) :
            nextTime+=self.interval
            self.action()

    def cancel(self) :
        self.stopEvent.set()


class Buffer:

    def __init__(self, number_of_messages, bucket, path_prefix, database) -> None:

        self.database = database
        self.number_of_messages = number_of_messages
        self.bucket = bucket
        self.path_prefix = path_prefix
        self.acc = Queue(maxsize=0)
        self.init_database()

    def init_database(self):
        
        databases = wr.catalog.databases()

        if self.database not in databases.values:
            wr.catalog.create_database(self.database)
            print(wr.catalog.databases())
        else:
            print(f"Database {self.database} already exists")

    def add(self, key, value): 
        self.acc.put((key, value))
        if self.acc.qsize() >= self.number_of_messages:
            self.__call__()

    def replace_path(self, event_desc):
        prefix = self.path_prefix.replace("{scope}", event_desc["Scope"] ).replace("{version}", event_desc["Version"]).replace("{name}",  event_desc["Name"])
        return prefix

    def run(self): 
        self.__call__()

    def __call__(self):

        print("check if need writing anything", self.acc.qsize())

        if not self.acc.empty():

            data = {}

            items = []
            while not self.acc.empty():
                items.append(self.acc.get())
 
            for item in items:
                for key in item[1].keys():
                    data[key] = list(map(lambda v: v[1][key], items))

            df = pd.DataFrame(data=data)
            df['Timestamp'] = df['Timestamp'].astype('datetime64[ns]')

            df["date"] = df["Timestamp"].dt.date
            df["hour"] = df["Timestamp"].dt.hour.astype(int).astype(str)

            group_df = df.groupby(["Scope", "Version", "Name"]).count()
            paths = {}
            for row in group_df.itertuples():
                scope, version, name = row._asdict()["Index"]
                paths[scope + "_" + name + "_" + version ] = (
                    self.replace_path({ "Scope": scope, "Version": version, "Name": name }),
                    { "Scope": scope, "Version": version, "Name": name }
                )

            for key in paths.keys():
                print(key, paths[key])
                write_df = df.where(df.Scope == paths[key][1]["Scope"]) \
                    .where(df.Version == paths[key][1]["Version"]) \
                    .where(df.Name == paths[key][1]["Name"])


                res = wr.s3.to_parquet(
                    df=write_df,
                    path=f"s3://{self.bucket}/{paths[key][0]}/",
                    dataset=True,
                    mode="append",
                    database=self.database,
                    compression="snappy",
                    table=key,
                    partition_cols=["date", "hour"]
                )

                wr.catalog.table(database=self.database, table=key)


                # output response
                # {
                #     'paths': [
                #         's3://confluent-kafka-connect-s3-study/tables/prod/event/testevent/v0/date=2022-08-15/hour=19/d71733e4825b44279e05993e4dbda836.snappy.parquet'
                #     ], 
                #     'partitions_values': {
                #         's3://confluent-kafka-connect-s3-study/tables/prod/event/testevent/v0/date=2022-08-15/hour=19/': ['2022-08-15', '19']
                #     }
                # }

                print(res)

def get_args():
  parser = argparse.ArgumentParser()
  parser.add_argument('--host')
  parser.add_argument('--topic')
  parser.add_argument("--security-protocol")
  parser.add_argument("--schema-registry")
  parser.add_argument("--bucket")
  parser.add_argument("--buffer-limit-in-seconds", type=float)
  parser.add_argument("--buffer-limit-in-units", type=int)
  parser.add_argument("--path-prefix")
  parser.add_argument("--database")

  return parser.parse_args()

args = get_args()
print("args:", args)

# To consume latest messages and auto-commit offsets
consumer = KafkaConsumer(
    args.topic,
    security_protocol=args.security_protocol,
    group_id=str(uuid.uuid4()),
    auto_offset_reset="latest",
    bootstrap_servers=args.host.split(",")
)

class SchemaRegistry:
    def __init__(self, url):
        self.url = url
        self.schemas = {}

    def get_schema_by_payload(self, payload): 
        magic, schema_id = struct.unpack('>bI', payload[:5])
        key_schema_version = f"{args.topic}-{schema_id}"

        schema = self.schemas.get(key_schema_version, None)

        if not schema:
            print(magic, schema_id)
            schema_url = f"{args.schema_registry}/subjects/{args.topic}-value/versions/{schema_id}"
            print(f"try recover schema by {schema_url}")
            schema_res = requests.get(schema_url, headers={'Content-Type': 'application/json'})
            schema = schema_res.json()
            print(schema)
            self.schemas[key_schema_version] = json.loads(schema["schema"])
        
        return schema


print("configured")

schema_registry = SchemaRegistry(args.schema_registry)

write_buffer = Buffer(
    number_of_messages=args.buffer_limit_in_units,
    bucket=args.bucket, 
    path_prefix=args.path_prefix,
    database=args.database
)

SetInterval(
    args.buffer_limit_in_seconds, 
    write_buffer.run
)

for message in consumer:
    # print(message)
    try:

        schema = schema_registry.get_schema_by_payload(message.value)

        payload = json.loads(message.value[5:])
        validate(instance=payload, schema=schema)
        write_buffer.add(message.key, payload)

    except Exception as e:
        print(e)

    
    print("topic=%s partition=%d offset=%d key=%s value=%s" % (message.topic, message.partition, message.offset, message.key, message.value))



os.exit()