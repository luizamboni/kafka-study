import os
import json
from flask import Flask, request
from avro_model import are_schemas_compatible, create_pydantic_model_from_avro_schema, convert_pydantic_to_avro_binary
import logging
from logging.handlers import TimedRotatingFileHandler
from services.publisher_with_confluent_schema_register import PublisherWithConfluentSchemaRegister
from services.publisher_with_glue_schema_register_publisher import PublisherWithGlueSchemaRegister
from config.kafka import SchemaRegistryConfig, SchemaRegistriesTypes


SchemaRegistryClass = PublisherWithGlueSchemaRegister

if SchemaRegistryConfig.SCHEMA_REGISTRY_TYPE == SchemaRegistriesTypes.CONFLUENT:
    SchemaRegistryClass = PublisherWithConfluentSchemaRegister

handler = TimedRotatingFileHandler("app.log", when="S", interval=60, backupCount=10)
logger = logging.getLogger('root')
logger.setLevel(logging.ERROR)
# logger.addHandler(handler)
app = Flask(__name__)

from config.kafka import KafkaConfig
print(SchemaRegistryConfig, KafkaConfig.SECURITY_PROTOCOL)

def load_event_schemas(events_dir: str):
    event_models = {}

    for event_name in os.listdir(events_dir):
        full_event_dir = f"{events_dir}/{event_name}"
        events_from_dir = os.listdir(full_event_dir)
        sorted_events_filenames = sorted(events_from_dir)

        event_schemes = []
        for filename in sorted_events_filenames:
            with open(f"{full_event_dir}/{filename}") as f:
                schema = json.load(f)
                schema["version"] = filename.split("-", 1)[0]
                event_schemes.append(schema)

        if not are_schemas_compatible(event_schemes):
            raise Exception(f"some {event_name} event's version are incompatible")
        
        event_models[event_name] = { 
            schema["version"]: {"schema": schema, "model": create_pydantic_model_from_avro_schema(schema)} for schema in event_schemes
        }
        last_event_scheme = event_schemes[-1]
        event_models[event_name]["last"] = {
            "schema": last_event_scheme,
            "model": create_pydantic_model_from_avro_schema(last_event_scheme)
        }
    
    return event_models

event_models = load_event_schemas("./events")


@app.route("/", methods=["GET"])
def events_list():
    return list(event_models.keys())

@app.route("/", methods=["POST"])
def send_event():
    payload_with_meta = request.json
    event_name = payload_with_meta["name"]
    event_version = payload_with_meta.get("version", "last")

    event_definitions =  event_models.get(event_name)

    if not event_definitions:
        return 404, "Event not found"    

    ClassModel = event_definitions[event_version]["model"]
    event = ClassModel(**payload_with_meta["payload"])

    producer = event_definitions[event_version].get("producer")
    
    if not producer:

        producer = SchemaRegistryClass(
            event_name=event_name, 
            event_version=event_version,
            value_schema=event_definitions[event_version]["schema"],
        )

        event_definitions[event_version]["producer"] = producer

    producer.publish(event.dict())


    return {
        "event": event.dict(),
        "current_schema": event_definitions[event_version]["schema"],
        # "avro": str(convert_pydantic_to_avro_binary(event))
    }
