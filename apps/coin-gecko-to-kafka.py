from datetime import datetime, timedelta
import json
from time import sleep
import argparse

from kafka import KafkaProducer
from pycoingecko import CoinGeckoAPI

cg = CoinGeckoAPI()


def get_args():
  parser = argparse.ArgumentParser()
  parser.add_argument('--host')
  return parser.parse_args()

def send_to_kafka(topic: str, message: str, key: str):
    try:
        message_in_bytes = str.encode(message)
        key_in_bytes = str.encode(key)
        future = producer.send(
            topic,
            key=key_in_bytes,
            value=message_in_bytes
        )
        # result = future.get(timeout=60)
        # print(result)
    except Exception as err:
        print(f"Unexpected {err}, {type(err)}")
    producer.flush()

args = get_args()

producer = KafkaProducer(
    bootstrap_servers=args.host
)


for coin in cg.get_coins_list():
    if coin.get('id', None):
        today = datetime.now()
        send_to_kafka('coins', json.dumps(coin), coin['id'])
        for i in range(7):

            day_ago = datetime.now() - timedelta(days=i)
            day_key = day_ago.strftime("%d-%m-%Y")
            coin_history = cg.get_coin_history_by_id(id=coin['id'], date=day_key)
            send_to_kafka("coins_history", json.dumps(coin_history), f"{coin['id']}-{day_key}")
        
        # to prevent exceded quota
        sleep(2)




