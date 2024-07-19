import os

class KafkaConfig:
    KAFKA_BOOTSTRAP_URL = os.getenv("KAFKA_BOOTSTRAP_URL", "localhost:9094")
    SECURITY_PROTOCOL = os.getenv("SECURITY_PROTOCOL", "PLAINTEXT")

class SchemaRegistriesTypes:
    CONFLUENT = "CONFLUENT"
    GLUE = "GLUE"

class SchemaRegistryConfig:
    SCHEMA_REGISTRY_TYPE = os.getenv("SCHEMA_REGISTRY_TYPE", SchemaRegistriesTypes.GLUE)
    CONFLUENT_SCHEMA_REGISTRY_URL = os.getenv("CONFLUENT_SCHEMA_REGISTRY_URL", "http://localhost:8087")
    AWS_REGION = os.getenv("AWS_REGION", "us-east-1")
    GLUE_SCHEMA_REGISTRY_NAME = os.getenv("GLUE_SCHEMA_REGISTRY_NAME", "default")
    KAFKA_BOOTSTRAP_URL= os.getenv("KAFKA_BOOTSTRAP_URL", "localhost:9094")