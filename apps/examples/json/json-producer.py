from confluent_kafka import SerializingProducer
from confluent_kafka.serialization import StringSerializer
from confluent_kafka.schema_registry import SchemaRegistryClient
from confluent_kafka.schema_registry.json_schema import JSONSerializer
import argparse
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

schema_registry_client = SchemaRegistryClient({
    'url': args.schema_registry
})

json_serializer = JSONSerializer(
    schema_value, 
    schema_registry_client
)

producer = SerializingProducer({
    'bootstrap.servers': args.host,
    'security.protocol': args.security_protocol,
    'key.serializer': StringSerializer('utf_8'),
    'value.serializer': json_serializer
})


# Send message data along with schema

data = {
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

for n in range(10):
    print("sending:", data)
    producer.produce(args.topic, value=data, key=f"{n}")

producer.flush()