from confluent_kafka import avro
from confluent_kafka.avro import AvroProducer
import argparse
import os

def get_args():
  parser = argparse.ArgumentParser()
  parser.add_argument('--host')
  parser.add_argument('--registry')
  parser.add_argument('--topic')
  return parser.parse_args()



value_schema = None
with open(f"{os.path.dirname(__file__)}/schema-value.json", 'r') as schema_file:
    value_schema = avro.loads(schema_file.read())

key_schema = None
with open(f"{os.path.dirname(__file__)}/schema-key.json", 'r') as schema_file:
    key_schema = avro.loads(schema_file.read())


def delivery_report(err, msg):
    if err is not None:
        print(f"Message delivery failed: {err}")
    else:
        print(f"Message delivered to {msg.topic()} [{msg.partition()}]")

args = get_args()
print(args)

avroProducer = AvroProducer({
    'bootstrap.servers': args.host,
    'on_delivery': delivery_report,
    'schema.registry.url': args.registry
  }, 
  default_key_schema=key_schema, 
  default_value_schema=value_schema
)


for n in range(100):
  value = {
    "name": f"{n}"
  }
  key = {
    "name": "Key"
  }

  avroProducer.produce(
    topic=args.topic, 
    value=value, 
    key=key
  )
avroProducer.flush()