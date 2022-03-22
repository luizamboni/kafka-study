from datetime import datetime, timedelta
import json
from time import sleep
import argparse

import requests

from kafka import KafkaProducer
from kafka.admin import KafkaAdminClient, NewTopic
from pycoingecko import CoinGeckoAPI
from commons import default_topic_config

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
            # TopicAlreadyExistsError
        except Exception as e:
            pass

    def send_to_kafka(self, topic: str, message: str, key: str):
        try:
            message_in_bytes = str.encode(message)
            key_in_bytes = str.encode(key)
            future = self.producer.send(
                topic,
                key=key_in_bytes,
                value=message_in_bytes
            )
        except Exception as e:
            print(f"Unexpected {e}, {type(e)}")
        self.producer.flush()

args = get_args()

kafka = KafkaBroker(args.host)

def retry_if_many_requests(callable, tries=3):
    while tries > 0:
        try:
            return callable()
        except requests.exceptions.HTTPError as e:
            sleep(21)
        finally:
            tries -= 1

for coin in retry_if_many_requests(cg.get_coins_list, 3):
    if coin.get('id', None):
        today = datetime.now()
        kafka.send_to_kafka('coins', json.dumps(coin), coin['id'])
        for i in range(7):

            day_ago = datetime.now() - timedelta(days=i)
            day_key = day_ago.strftime("%d-%m-%Y")
            coin_history = retry_if_many_requests(lambda *args: cg.get_coin_history_by_id(id=coin['id'], date=day_key), 4)

            topic = f"{coin['id']}_history"
            kafka.ensure_topic_exists(topic)
            kafka.send_to_kafka(topic, json.dumps(coin_history), f"{coin['id']}-{day_key}")
        
        # to prevent exceded quota
        sleep(2)




