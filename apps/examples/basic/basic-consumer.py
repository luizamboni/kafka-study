import json
from kafka import KafkaConsumer
import argparse
import struct
import requests

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
    group_id='group-id-1',
    auto_offset_reset="earliest",
    bootstrap_servers=args.host.split(",")
)

print("configured")
for message in consumer:

    try: 
      magic, schema_id = struct.unpack('>bI', message.value[:5])
      print(magic, schema_id)
      schema_url = f"http://schema-registry:8081/subjects/{args.topic}-value/versions/{schema_id}"
      print(f"try recover schema by {schema_url}")
      schema = requests.get(schema_url, headers={'Content-Type': 'application/json'})
      print(schema.json())
      # f"http://localhost:8081/schemas/ids/1"
      # f"http://localhost:8081/subjects/{args.topic}-value/versions/1"

    except Exception as e:
      print(e)
    
    print("%s:%d:%d: key=%s value=%s" % (message.topic, message.partition,
                                          message.offset, message.key,
                                          message.value))


