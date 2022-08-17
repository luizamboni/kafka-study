from aws_schema_registry import SchemaRegistryClient
from aws_schema_registry.adapter.kafka import KafkaDeserializer
from kafka import KafkaConsumer
import boto3
import argparse



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


# Create the schema registry client, which is a façade around the boto3 glue client
client = SchemaRegistryClient(
    glue_client,
    registry_name=args.registry_name
)

# Create the deserializer
deserializer = KafkaDeserializer(client)

# Create the consumer
consumer = KafkaConsumer(
    args.topic,
    value_deserializer=deserializer,
    security_protocol=args.security_protocol,
    bootstrap_servers=args.host.split(","),
    # group_id='group-id',
    auto_offset_reset="earliest",
)

# Now use the consumer normally
for message in consumer:

    # The deserializer produces DataAndSchema instances
    [data, schema] = message.value
    print("schema:", schema)
    print("data:", data) 


    # which are NamedTuples with a `data` and `schema` property
    message.value.data == message.value[0]
    message.value.schema == message.value[1]
    # and can be deconstructed
    data, schema = message.value