from confluent_kafka import SerializingProducer
from confluent_kafka.serialization import StringSerializer
from confluent_kafka.schema_registry import SchemaRegistryClient
from confluent_kafka.schema_registry.protobuf import ProtobufSerializer
import schemas.value_schema_pb2 as value_schema_pb2 
import argparse

def get_args():
  parser = argparse.ArgumentParser()
  parser.add_argument('--host')
  parser.add_argument('--schema-registry')
  parser.add_argument('--topic')
  parser.add_argument('--security-protocol')
  return parser.parse_args()

args = get_args()



schema_registry_client = SchemaRegistryClient({
  'url': args.schema_registry
})


protobuf_serializer = ProtobufSerializer(
  value_schema_pb2.Eventtest,
  schema_registry_client,
  {'use.deprecated.format': False}
)

producer = SerializingProducer({
  'bootstrap.servers': args.host,
  'key.serializer': StringSerializer('utf_8'),
  'value.serializer': protobuf_serializer
})

for n in range(10):
  # Serve on_delivery callbacks from previous calls to produce()
  producer.poll(0.0)
  try:
    event = value_schema_pb2.Eventtest(
      Scope = "Dev",
      Version = "1",
      Name = "testevent",
      # Payload= value_schema_pb2.Eventtest.Payload(
      #   required_field = 'test',
      #   struct_field = value_schema_pb2.Eventtest.Payload.struct_field(
      #     name = 'b'
      #   )
      # )
    )
    event.Payload.required_field = "required value" 
    event.Payload.struct_field.name = "name requered"

    print("event: ", event.Payload)
  
    res = producer.produce(
      topic=args.topic, 
      partition=0, 
      key=str(n), 
      value=event,
    )

    print(res)

  except (KeyboardInterrupt, EOFError):
      break
  except ValueError:
      print("Invalid input, discarding record...")
      continue

print("\nFlushing records...")
producer.flush()
