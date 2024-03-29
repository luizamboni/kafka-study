include .env

up:
	docker-compose up && docker-compose up

up-reset:
	docker-compose down  --volumes --remove-orphans && docker-compose up

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
		--topic=${TOPIC_BASIC_EXAMPLES} \
		--schema-registry=${CONFLUENT_REGISTRY}

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

json-glue-producer:
	docker-compose run --rm kafka-clients \
		python examples/glue/json/glue-producer.py \
		--host=${BROKER_ENDPOINTS} \
		--security-protocol=${SECURITY_PROTOCOL} \
		--topic=${TOPIC_GLUE_EXAMPLES} \
		--registry-name=${GLUE_REGISTRY}

json-glue-consumer:
	docker-compose run --rm kafka-clients \
		python examples/glue/json/glue-consumer.py \
		--host=${BROKER_ENDPOINTS} \
		--security-protocol=${SECURITY_PROTOCOL} \
		--topic=${TOPIC_GLUE_EXAMPLES} \
		--registry-name=${GLUE_REGISTRY}

avro-glue-producer:
	docker-compose run --rm kafka-clients \
		python examples/glue/avro/glue-producer.py \
		--host=${BROKER_ENDPOINTS} \
		--security-protocol=${SECURITY_PROTOCOL} \
		--topic=${TOPIC_GLUE_AVRO_EXAMPLES} \
		--registry-name=${GLUE_REGISTRY}

avro-glue-consumer:
	docker-compose run --rm kafka-clients \
		python examples/glue/avro/glue-consumer.py \
		--host=${BROKER_ENDPOINTS} \
		--security-protocol=${SECURITY_PROTOCOL} \
		--topic=${TOPIC_GLUE_AVRO_EXAMPLES} \
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


json-schema-producer:
	docker-compose run --rm kafka-clients \
		python examples/json/json-producer.py \
		--host=${BROKER_ENDPOINTS} \
		--security-protocol=${SECURITY_PROTOCOL} \
		--topic=${TOPIC_GENERIC_JSON} \
		--schema-registry=${CONFLUENT_REGISTRY} \
		--max-interval-in-seconds=0.1

json-schema-consumer:
	docker-compose run --rm kafka-clients \
		python examples/json/json-consumer.py \
		--host=${BROKER_ENDPOINTS} \
		--security-protocol=${SECURITY_PROTOCOL} \
		--topic=${TOPIC_GENERIC_JSON} \
		--schema-registry=${CONFLUENT_REGISTRY}

#root@12205e401437:/home/apps# 

compile-protobuf-schema-producer:
	docker-compose run \
		--rm kafka-clients \
		protoc -I=/home/apps/examples/protobuf/schemas/ --python_out=/home/apps/examples/protobuf/schemas/ /home/apps/examples/protobuf/schemas/value-schema.proto


protobuf-schema-producer: compile-protobuf-schema-producer
	docker-compose run \
		--rm kafka-clients \
		python examples/protobuf/protobuf-producer.py \
		--host=${BROKER_ENDPOINTS} \
		--security-protocol=${SECURITY_PROTOCOL} \
		--topic=${TOPIC_GENERIC_PROTOBUF} \
		--schema-registry=${CONFLUENT_REGISTRY}

# protubuf not need a schema regirstry to be deserialized
protobuf-schema-consumer:
	docker-compose run \
		--rm kafka-clients \
		python examples/protobuf/protobuf-consumer.py \
		--host=${BROKER_ENDPOINTS} \
		--security-protocol=${SECURITY_PROTOCOL} \
		--topic=${TOPIC_GENERIC_PROTOBUF}


s3-writer:
	docker-compose run --rm kafka-clients \
		python examples/s3-writer/app.py \
		--host=${BROKER_ENDPOINTS} \
		--security-protocol=${SECURITY_PROTOCOL} \
		--topic=${TOPIC_GENERIC_JSON} \
		--schema-registry=${CONFLUENT_REGISTRY} \
		--bucket=${BUCKET} \
		--buffer-limit-in-seconds=10.0 \
		--buffer-limit-in-units=1000 \
		--database=mammoth \
		--path-prefix='tables/{scope}/event/{name}/{version}' \
