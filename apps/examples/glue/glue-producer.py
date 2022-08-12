from aws_schema_registry import SchemaRegistryClient
from aws_schema_registry.jsonschema import JsonSchema
from aws_schema_registry.adapter.kafka import KafkaSerializer
from kafka import KafkaProducer
import argparse
import boto3
import os



def get_args():
  parser = argparse.ArgumentParser()
  parser.add_argument('--host')
  parser.add_argument('--topic')
  parser.add_argument("--security-protocol")
  parser.add_argument('--registry-name')
  return parser.parse_args()

args = get_args()
print("args:", args)


# Pass your AWS credentials or profile information here
glue_client = boto3.Session(region_name='us-east-1').client('glue')

# print(glue_client.list_schemas())

# Create the schema registry client, which is a façade around the boto3 glue client
client = SchemaRegistryClient(
    glue_client,
    registry_name=args.registry_name
)

# Create the serializer
serializer = KafkaSerializer(client)

# Create the producer
producer = KafkaProducer(
    value_serializer=serializer,
    security_protocol=args.security_protocol,
    bootstrap_servers=args.host.split(",")
)

schema_value = None
with open(f"{os.path.dirname(__file__)}/jsonschema-value.json", 'r') as schema_file:
    schema_value = JsonSchema(schema_file.read())

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

for _ in range(10):
    print("sending:", data)
    producer.send(args.topic, value=(data, schema_value))

producer.flush()