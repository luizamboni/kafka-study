CREATE STREAM avro_example WITH (
    KAFKA_TOPIC='test_arvro_schema',
    KEY_FORMAT='AVRO',
    VALUE_FORMAT='AVRO'
);

describe avro_example;