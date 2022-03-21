up:
	docker-compose up zookeeper kafka kafka-admin

setup:
	docker-compose run --rm kafka-clients \
		python setup.py \
		--host=kafka:9092 \
		--topic=coins
	docker-compose run --rm kafka-clients \
		python setup.py \
		--host=kafka:9092 \
		--topic=coins_history

consumer:
	docker-compose run --rm kafka-clients python coin-gecko-to-kafka.py --host=kafka:9092