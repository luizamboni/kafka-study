import argparse
from kafka import KafkaProducer
import argparse

def get_args():
  parser = argparse.ArgumentParser()
  parser.add_argument('--host')
  parser.add_argument('--topic')
  parser.add_argument("--security-protocol")
  return parser.parse_args()

args = get_args()
print("args:", args)


producer = KafkaProducer(
    security_protocol=args.security_protocol,
    bootstrap_servers=args.host.split(",")
)

for i in range(100):
    print(f"sending message n {i}")
    producer.send(args.topic, 
        key=b"anykey", 
        value=b"anyvalue"
    )

producer.flush()