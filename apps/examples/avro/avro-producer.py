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



key_schema = None
with open(f"{os.path.dirname(__file__)}/avroschema-key.json", 'r') as schema_file:
    key_schema = avro.loads(schema_file.read())

value_schema = None
with open(f"{os.path.dirname(__file__)}/avroschema-value.json", 'r') as schema_file:
    value_schema = avro.loads(schema_file.read())


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

  key = {
    'id': f"{n}"
  }

  value = {
      'Scope': 'dev', 
      'Version': 'v0', 
      'Payload': {
          'required_field': 'valor do required_field', 
          'struct_field': {
              'text_field': 'valor do text_field'
          }
      }, 
      'Name': 'testevent'
  }

  avroProducer.produce(
    topic=args.topic,
    key=key,
    value=value,
  )
avroProducer.flush()