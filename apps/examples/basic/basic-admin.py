from kafka.admin import KafkaAdminClient, NewTopic
import time
import argparse


default_topic_config = {
    "cleanup.policy": "compact",
    "delete.retention.ms": "100", 
    "segment.ms": "100",
    "min.cleanable.dirty.ratio": "0.01", 
    "min.compaction.lag.ms": "100", # The minimum time a message will remain uncompacted in the log
}

def get_args():
  parser = argparse.ArgumentParser()
  parser.add_argument('--host')
  parser.add_argument('--topic')
  parser.add_argument("--security-protocol")
  return parser.parse_args()

args = get_args()

print("args:", args)
admin_client = KafkaAdminClient(
    security_protocol=args.security_protocol,
    bootstrap_servers=args.host.split(","), 
    client_id='test'
)

time.sleep(1)
print("try delete topic if it already exist")
try:
    admin_client.delete_topics([args.topic])
except:
    pass

time.sleep(10)
print("try create topic")

try: 
    admin_client.create_topics(
        new_topics=[
            NewTopic(
                name=args.topic, 
                num_partitions=1, 
                replication_factor=1,
                topic_configs=default_topic_config,
            )
        ],
        validate_only=False
    )
    print("topic created")
except Exception as err:
    print(err)