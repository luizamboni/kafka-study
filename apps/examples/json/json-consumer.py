
import argparse

from confluent_kafka import DeserializingConsumer
from confluent_kafka.schema_registry.json_schema import JSONDeserializer
from confluent_kafka.serialization import StringDeserializer
import os

def get_args():
  parser = argparse.ArgumentParser()
  parser.add_argument('--host')
  parser.add_argument('--topic')
  parser.add_argument("--security-protocol")
  parser.add_argument("--schema-registry")

  return parser.parse_args()

args = get_args()
print("args:", args)


schema_value = None
with open(f"{os.path.dirname(__file__)}/jsonschema-value.json", 'r') as schema_file:
    schema_value = schema_file.read()

json_deserializer = JSONDeserializer(
    schema_value,
    from_dict=lambda x, ctx: x
)

string_deserializer = StringDeserializer('utf_8')


consumer = DeserializingConsumer({
    'bootstrap.servers': args.host,
    'key.deserializer': string_deserializer,
    'value.deserializer': json_deserializer,
    'group.id': "group-id-t",
    'auto.offset.reset': "earliest"
})

consumer.subscribe([args.topic])

while True:
    try:
        # SIGINT can't be handled when polling, limit timeout to 1 second.
        msg = consumer.poll(1.0)
        if msg is None:
            continue

        user = msg.value()
        if user is not None:
            print("User key {} and value {}".format(msg.key(), msg.value()))
    
    except KeyboardInterrupt:
        break

consumer.close()