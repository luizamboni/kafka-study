from confluent_kafka.avro import AvroConsumer
from confluent_kafka.avro.serializer import SerializerError
import argparse
import uuid

def get_args():
  parser = argparse.ArgumentParser()
  parser.add_argument('--host')
  parser.add_argument('--registry')
  parser.add_argument('--topic')
  return parser.parse_args()

args = get_args()

c = AvroConsumer({
  'bootstrap.servers': args.host,
  'auto.offset.reset': 'earliest',
  'group.id': str(uuid.uuid4()),
  'schema.registry.url': args.registry,
})

c.subscribe([args.topic])

while True:
    try:
        msg = c.poll(10)

    except SerializerError as e:
        print("Message deserialization failed for {}: {}".format(msg, e))
        break

    if msg is None:
        continue

    if msg.error():
        print("AvroConsumer error: {}".format(msg.error()))
        continue

    print(msg.value())

c.close()