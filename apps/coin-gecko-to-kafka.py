from datetime import datetime, timedelta
import json
from time import sleep
import argparse

from kafka import KafkaProducer
from kafka.admin import KafkaAdminClient, NewTopic
from pycoingecko import CoinGeckoAPI
from .config import default_topic_config
cg = CoinGeckoAPI()


def get_args():
  parser = argparse.ArgumentParser()
  parser.add_argument('--host')
  return parser.parse_args()

class KafkaBroker:
    def __init__(self, host: str) -> None:
        self.host = host
        self.admin_client = KafkaAdminClient(
            bootstrap_servers=self.host, 
            client_id='test'
        )

        self.producer = KafkaProducer(
            bootstrap_servers=args.host
        )

        
    
    def ensure_topic_exists(self, topic: str):

        try: 
            self.admin_client.create_topics(
                new_topics=[
                    NewTopic(
                        name=topic, 
                        num_partitions=1, 
                        replication_factor=1,
                        topic_configs= default_topic_config
                    )
                ],
                validate_only=False
            )
            print("topic created")
        except Exception as err:
            print(f"Unexpected {err}, {type(err)}")

    def send_to_kafka(self, topic: str, message: str, key: str):
        try:
            message_in_bytes = str.encode(message)
            key_in_bytes = str.encode(key)
            future = self.producer.send(
                topic,
                key=key_in_bytes,
                value=message_in_bytes
            )
        except Exception as err:
            print(f"Unexpected {err}, {type(err)}")
        self.producer.flush()

args = get_args()

kafka = KafkaBroker(args.host)


for coin in cg.get_coins_list():
    if coin.get('id', None):
        today = datetime.now()
        kafka.send_to_kafka('coins', json.dumps(coin), coin['id'])
        for i in range(7):

            day_ago = datetime.now() - timedelta(days=i)
            day_key = day_ago.strftime("%d-%m-%Y")
            coin_history = cg.get_coin_history_by_id(id=coin['id'], date=day_key)

            topic = f"{coin['id']}_history"
            kafka.ensure_topic_exists(topic)
            kafka.send_to_kafka(topic, json.dumps(coin_history), f"{coin['id']}-{day_key}")
        
        # to prevent exceded quota
        sleep(2)




