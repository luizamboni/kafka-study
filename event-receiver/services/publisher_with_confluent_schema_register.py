from confluent_kafka.serialization import SerializationContext, MessageField
from confluent_kafka.schema_registry import SchemaRegistryClient
from confluent_kafka.schema_registry.avro import AvroSerializer
from confluent_kafka import Producer
import json
from typing import Dict
from config.kafka import SchemaRegistryConfig, KafkaConfig


def delivery_report(err, msg):
    if err is not None:
        print("Delivery failed for User record {}: {}".format(msg.key(), err))
        return
    print('User record {} successfully produced to {} [{}] at offset {}'.format(
        msg.key(), msg.topic(), msg.partition(), msg.offset()))


class PublisherWithConfluentSchemaRegister:
    
    schema_registry_client: SchemaRegistryClient
    producer: Producer

    event_name: str
    event_version: str

    key_serializer: AvroSerializer
    value_serializer: AvroSerializer

    def __init__(self, event_name: str, event_version: str, value_schema: Dict) -> None:
        
        self.event_name = event_name
        self.event_version = event_version

        self.schema_registry_client = SchemaRegistryClient({
            "url": SchemaRegistryConfig.CONFLUENT_SCHEMA_REGISTRY_URL
        })

        self.key_serializer = AvroSerializer(
            self.schema_registry_client,
            json.dumps({ "name" : "id", "type" : "string"})
        )

        self.value_serializer = AvroSerializer(
            self.schema_registry_client,
            json.dumps(value_schema),
        )

        self.producer = Producer({
            'bootstrap.servers': KafkaConfig.KAFKA_BOOTSTRAP_URL,
            'security.protocol': KafkaConfig.SECURITY_PROTOCOL,
            'queue.buffering.max.messages': 50_000, 
            'queue.buffering.max.ms' : 60_000,  
            'batch.num.messages': 1_000
        })

    def publish(self, message: Dict):

        topic = f"{self.event_name}-{self.event_version}"
        key = {
            "id": hash(frozenset(message.items()))
        }

        self.producer.produce(
            topic=topic,
            key=self.key_serializer(key, SerializationContext(topic, MessageField.KEY)),
            value=self.value_serializer(message, SerializationContext(topic, MessageField.VALUE)),
            on_delivery=delivery_report
        )

        print(message)
        return True