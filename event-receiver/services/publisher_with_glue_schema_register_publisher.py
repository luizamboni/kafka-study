from aws_schema_registry import SchemaRegistryClient
from aws_schema_registry.adapter.kafka import KafkaSerializer
from aws_schema_registry.avro import AvroSchema

from kafka import KafkaProducer
import boto3
import json
from config.kafka import SchemaRegistryConfig, KafkaConfig

from typing import Dict


def delivery_report(err, msg):
    if err is not None:
        print("Delivery failed for User record {}: {}".format(msg.key(), err))
        return
    print('User record {} successfully produced to {} [{}] at offset {}'.format(
        msg.key(), msg.topic(), msg.partition(), msg.offset()))


glue_client = boto3.Session(region_name=SchemaRegistryConfig.AWS_REGION).client('glue')


class PublisherWithGlueSchemaRegister:
    
    schema_registry_client: SchemaRegistryClient
    producer: KafkaProducer

    event_name: str
    event_version: str

    key_serializer: KafkaSerializer
    value_serializer: KafkaSerializer
    key_schema: AvroSchema
    value_schema: AvroSchema

    def __init__(self, event_name: str, event_version: str, value_schema: Dict) -> None:
        
        self.event_name = event_name
        self.event_version  = event_version

        self.key_schema = AvroSchema(json.dumps({
            "type": "record", 
            "name": "key", 
            "fields": [
                {"name": "id", "type": "string"}
            ]
        }))
        self.value_schema = AvroSchema(json.dumps(value_schema))
                                     
        self.schema_registry_client = SchemaRegistryClient(
            glue_client,
            registry_name=SchemaRegistryConfig.GLUE_SCHEMA_REGISTRY_NAME
        )

        self.key_serializer = KafkaSerializer(
            self.schema_registry_client,
            is_key=True
        )

        self.value_serializer = KafkaSerializer(
            self.schema_registry_client,
        )

        self.producer = KafkaProducer(
            key_serializer=self.key_serializer,
            value_serializer=self.value_serializer,
            security_protocol=KafkaConfig.SECURITY_PROTOCOL,
            bootstrap_servers=KafkaConfig.KAFKA_BOOTSTRAP_URL.split(","),
        )

    def publish(self, message: Dict):

        topic = f"{self.event_name}-{self.event_version}"
        key = {
            "id": f"{hash(frozenset(message.items()))}"
        }

        self.producer.send(
            topic=topic,
            key=(key, self.key_schema),
            value=(message, self.value_schema)
        )

        print(KafkaConfig, SchemaRegistryConfig)

        return True