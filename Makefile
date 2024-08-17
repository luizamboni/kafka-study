

SECURITY_PROTOCOL=PLAINTEXT
TOPIC_GENERIC_AVRO=test_avro_schema_2
TOPIC_GENERIC_JSON=test_json_schema_2
TOPIC_BASIC_EXAMPLES=test_json_schema_2
INTERNAL_BROKER_ENDPOINT=broker:9092
CONFLUENT_REGISTRY=http://schema-registry:8081
GLUE_REGISTRY=kafka-study

include .env
-include .env.cloud
include Makefile.Confluent
include Makefile.Glue
include Makefile.Protobuf
include Makefile.Connect
include Makefile.CoinGenko
include Makefile.Ksql
include Makefile.SchemaRegistry
include infra/Makefile
include Makefile.EventReceiver
include Makefile.Seeds


test_load_vars:
	echo ${INTERNAL_BROKER_ENDPOINT}

up:
	docker-compose up zookeeper kafka schema-registry akhq connect

down:
	docker-compose down  --volumes --remove-orphans zookeeper kafka schema-registry akhq connect

basic-consumer:
	docker-compose run --rm kafka-clients \
		python examples/basic/basic-consumer.py \
		--host=${INTERNAL_BROKER_ENDPOINT} \
		--security-protocol=${SECURITY_PROTOCOL} \
		--topic=${TOPIC_BASIC_EXAMPLES} \
		--schema-registry=${CONFLUENT_REGISTRY}

basic-producer:
	docker-compose run --rm kafka-clients \
		python examples/basic/basic-producer.py \
		--host=${INTERNAL_BROKER_ENDPOINT} \
		--security-protocol=${SECURITY_PROTOCOL} \
		--topic=${TOPIC_BASIC_EXAMPLES}

basic-admin:
	docker-compose run --rm kafka-clients \
		python examples/basic/basic-admin.py \
		--host=${INTERNAL_BROKER_ENDPOINT} \
		--security-protocol=${SECURITY_PROTOCOL} \
		--topic=${TOPIC_BASIC_EXAMPLES}

s3-writer:
	docker-compose run --rm kafka-clients \
		python examples/s3-writer/app.py \
		--host=${INTERNAL_BROKER_ENDPOINT} \
		--security-protocol=${SECURITY_PROTOCOL} \
		--topic=${TOPIC_GENERIC_JSON} \
		--schema-registry=${CONFLUENT_REGISTRY} \
		--bucket=${BUCKET} \
		--buffer-limit-in-seconds=10.0 \
		--buffer-limit-in-units=1000 \
		--database=mammoth \
		--path-prefix='tables/{scope}/event/{name}/{version}'


spark:
	docker run -it apache/spark-py \
		/opt/spark/bin/pyspark
