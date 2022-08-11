import json
from kafka import KafkaConsumer
import argparse

def get_args():
  parser = argparse.ArgumentParser()
  parser.add_argument('--host')
  parser.add_argument('--topic')
  parser.add_argument("--security-protocol")
  return parser.parse_args()

args = get_args()
print("args:", args)

# To consume latest messages and auto-commit offsets
consumer = KafkaConsumer(
    args.topic,
    security_protocol=args.security_protocol,
    group_id='group-id',
    auto_offset_reset="earliest",
    bootstrap_servers=args.host.split(",")
)

print("configured")
for message in consumer:

    # print(message)
    # message value and key are raw bytes -- decode if necessary!
    # e.g., for unicode: `message.value.decode('utf-8')`
    print("%s:%d:%d: key=%s value=%s" % (message.topic, message.partition,
                                          message.offset, message.key,
                                          message.value))

    print(json.loads(message.value))


