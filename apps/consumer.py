from datetime import datetime, timedelta
from time import sleep
from pycoingecko import CoinGeckoAPI

cg = CoinGeckoAPI()

for coin in cg.get_coins_list():
    print(coin)
    if coin.get('id', None):
        today = datetime.now()
        for i in range(7):

            day_ago = datetime.now() - timedelta(days=i)
            coin_history = cg.get_coin_history_by_id(id=coin['id'], date=day_ago.strftime("%d-%m-%Y"))
            print(coin_history)
        
        # to prevent exceded quota
        sleep(2)