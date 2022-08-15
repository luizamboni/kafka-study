from confluent_kafka import SerializingProducer
from confluent_kafka.serialization import StringSerializer
from confluent_kafka.schema_registry import SchemaRegistryClient
from confluent_kafka.schema_registry.json_schema import JSONSerializer
import argparse
import os
from faker import Faker
from datetime import datetime


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
    'value.serializer': json_serializer,
    'api.version.request': True
})


# Send message data along with schema
faker = Faker()

for n in range(100):
    data = {
        'Timestamp': str(datetime.now()) , 
        'Scope': faker.random_element(elements=["dev", "prod"]), 
        'Version': faker.random_element(elements=["v0", "v1", "v2"]),
        'Payload': {
            'required_field': faker.random_element(elements=["abc", "zyz"]), 
            'struct_field': {
                'text_field': 'valor do text_field'
            }
        }, 
        'Name': 'testevent'
    }
    print("sending:", data)
    producer.produce(args.topic, value=data, key=f"{n}")

producer.flush()