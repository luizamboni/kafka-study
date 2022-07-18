up:
	docker-compose up zookeeper kafka kafka-admin connect pg

down:
	docker-compose down --remove-orphans

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
	docker-compose run --rm kafka-clients \
	python examples/coin-gecko/coin-gecko-to-kafka.py \
	--host=kafka:9092

avro-consumer:
	docker-compose run --rm kafka-clients \
		python examples/avro/avro-consumer.py \
		--host=kafka:9092 \
		--registry=http://schema-registry:8081 \
		--topic=test_arvro_schema

avro-producer:
	docker-compose run --rm kafka-clients \
		python examples/avro/avro-producer.py \
		--host=kafka:9092 \
		--registry=http://schema-registry:8081 \
		--topic=test_arvro_schema

kafka-to-pg:
	curl -X POST http://localhost:8083/connectors \
	-H 'Content-Type: application/json' \
	-d '$(shell cat connector/kafka-to-pg.json)'

kafka-to-s3:
	curl -X POST http://localhost:8083/connectors \
	-H 'Content-Type: application/json' \
	-d '$(shell cat connector/kafka-to-s3.json)'

check-pg:
	docker-compose exec pg \
	psql -U pg-example \
	-c 'SELECT * FROM test_arvro_schema'


http-server:
	docker-compose run --rm \
		-p 9001:9001 \
		kafka-clients \
		python ./examples/avro/http-server.py \
		--host=kafka:9092 \
		--registry=http://schema-registry:8081 \
		--topic=test_arvro_schema

up-ksql-example:
	docker-compose up \
		zookeeper kafka kafka-admin \
		ksqldb-server ksqldb-cli


down-ksql-example:
	docker-compose down \
		 zookeeper kafka kafka-admin \
		 ksqldb-server ksqldb-cli


ksql-cli:
	docker exec -it ksqldb-cli ksql http://ksqldb-server:8088
