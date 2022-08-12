BROKER_ENDPOINTS=broker:9092
TOPIC_GLUE_EXAMPLES=registry-schema-test
TOPIC_GENERIC_AVRO=test_arvro_schema
SECURITY_PROTOCOL=PLAINTEXT
GLUE_REGISTRY=registry-test
CONFLUENT_REGISTRY=http://schema-registry:8081
TOPIC_BASIC_EXAMPLES=test_arvro_schema

up:
	docker-compose up zookeeper kafka kafka-admin connect pg

down:
	docker-compose down --remove-orphans

setup:
	docker-compose run --rm kafka-clients \
		python setup.py \
		--host=${BROKER_ENDPOINTS} \
		--topic=coins
	docker-compose run --rm kafka-clients \
		python setup.py \
		--host=${BROKER_ENDPOINTS} \
		--topic=coins_history

consumer:
	docker-compose run --rm kafka-clients \
	python examples/coin-gecko/coin-gecko-to-kafka.py \
	--host=${BROKER_ENDPOINTS} \

faker-example:
	docker-compose run --rm kafka-clients \
		python examples/faker-example.py \
		--host=${BROKER_ENDPOINTS} \
		--registry=${CONFLUENT_REGISTRY} \
		--topic=${TOPIC_GENERIC_AVRO}

avro-consumer:
	docker-compose run --rm kafka-clients \
		python examples/avro/avro-consumer.py \
		--host=${BROKER_ENDPOINTS} \
		--registry=${CONFLUENT_REGISTRY} \
		--topic=${TOPIC_GENERIC_AVRO}

avro-producer:
	docker-compose run --rm kafka-clients \
		python examples/avro/avro-producer.py \
		--host=${BROKER_ENDPOINTS} \
		--registry=${CONFLUENT_REGISTRY} \
		--topic=${TOPIC_GENERIC_AVRO}

basic-consumer:
	docker-compose run --rm kafka-clients \
		python examples/basic/basic-consumer.py \
		--host=${BROKER_ENDPOINTS} \
		--security-protocol=${SECURITY_PROTOCOL} \
		--topic=${TOPIC_BASIC_EXAMPLES}

basic-producer:
	docker-compose run --rm kafka-clients \
		python examples/basic/basic-producer.py \
		--host=${BROKER_ENDPOINTS} \
		--security-protocol=${SECURITY_PROTOCOL} \
		--topic=${TOPIC_BASIC_EXAMPLES}

basic-admin:
	docker-compose run --rm kafka-clients \
		python examples/basic/basic-admin.py \
		--host=${BROKER_ENDPOINTS} \
		--security-protocol=${SECURITY_PROTOCOL} \
		--topic=${TOPIC_BASIC_EXAMPLES}

glue-producer:
	docker-compose run --rm kafka-clients \
		python examples/glue/glue-producer.py \
		--host=${BROKER_ENDPOINTS} \
		--security-protocol=${SECURITY_PROTOCOL} \
		--topic=${TOPIC_GLUE_EXAMPLES} \
		--registry-name=${GLUE_REGISTRY}

glue-consumer:
	docker-compose run --rm kafka-clients \
		python examples/glue/glue-consumer.py \
		--host=${BROKER_ENDPOINTS} \
		--security-protocol=${SECURITY_PROTOCOL} \
		--topic=${TOPIC_GLUE_EXAMPLES} \
		--registry-name=${GLUE_REGISTRY}

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
	-c 'SELECT * FROM ${TOPIC_GENERIC_AVRO}'


http-server:
	docker-compose run --rm \
		-p 9001:9001 \
		kafka-clients \
		python ./examples/avro/http-server.py \
		--host=${BROKER_ENDPOINTS} \
		--registry=${CONFLUENT_REGISTRY} \
		--topic=${TOPIC_GENERIC_AVRO}

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
