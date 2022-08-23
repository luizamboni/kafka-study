import argparse


from confluent_kafka import DeserializingConsumer
from confluent_kafka.schema_registry.protobuf import ProtobufDeserializer
from confluent_kafka.serialization import StringDeserializer
import schemas.value_schema_pb2 as value_schema_pb2 



def get_args():
  parser = argparse.ArgumentParser()
  parser.add_argument('--host')
  parser.add_argument('--topic')
  parser.add_argument('--security-protocol')
  return parser.parse_args()

args = get_args()

topic = args.topic

protobuf_deserializer = ProtobufDeserializer(
  value_schema_pb2.Eventtest,
  {'use.deprecated.format': False}
)

string_deserializer = StringDeserializer('utf_8')


consumer = DeserializingConsumer({
  'bootstrap.servers': args.host,
  'key.deserializer': string_deserializer,
  'value.deserializer': protobuf_deserializer,
  'group.id': "abc",
  'auto.offset.reset': "earliest"
})

consumer.subscribe([args.topic])

while True:
    try:
        # SIGINT can't be handled when polling, limit timeout to 1 second.
        msg = consumer.poll(1.0)
        if msg is None:
            continue

        value = msg.value()
        print(value)
    except KeyboardInterrupt:
        break

consumer.close()

