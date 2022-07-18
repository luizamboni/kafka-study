from confluent_kafka import avro
from confluent_kafka.avro import AvroProducer
import argparse


def get_args():
  parser = argparse.ArgumentParser()
  parser.add_argument('--host')
  parser.add_argument('--registry')
  parser.add_argument('--topic')
  return parser.parse_args()


value_schema_str = """
{
   "namespace": "my.test",
   "name": "value",
   "type": "record",
   "fields" : [
     {
       "name" : "name", "type" : "string"
     }
   ]
}
"""

key_schema_str = """
{
   "namespace": "my.test",
   "name": "key",
   "type": "record",
   "fields" : [
     {
       "name" : "name", "type" : "string"
     }
   ]
}
"""

value_schema = avro.loads(value_schema_str)
key_schema = avro.loads(key_schema_str)

def delivery_report(err, msg):
    if err is not None:
        print(f"Message delivery failed: {err}")
    else:
        print(f"Message delivered to {msg.topic()} [{msg.partition()}]")

args = get_args()

avroProducer = AvroProducer({
        'bootstrap.servers': args.host,
        'on_delivery': delivery_report,
        'schema.registry.url': args.registry
    }, 
    default_key_schema=key_schema, 
    default_value_schema=value_schema
)


for n in range(100):
  value = {
    "name": f"{n}"
  }
  key = {
    "name": "Key"
  }

  avroProducer.produce(
    topic=args.topic, 
    value=value, 
    key=key
  )
avroProducer.flush()