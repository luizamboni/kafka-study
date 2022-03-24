up:
	docker-compose up zookeeper kafka kafka-admin schema-registry

build:
	docker-compose build kafka-clients

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

avro-consumer:
	docker-compose run --rm kafka-clients python avro-example-consumer.py --host=kafka:9092 --registry=http://schema-registry:8081 --topic=test_arvro_schema

avro-producer:
	docker-compose run --rm kafka-clients python avro-example-producer.py --host=kafka:9092 --registry=http://schema-registry:8081 --topic=test_arvro_schema