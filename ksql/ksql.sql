CREATE STREAM avro_example WITH (
    KAFKA_TOPIC='test_arvro_schema',
    KEY_FORMAT='AVRO',
    VALUE_FORMAT='AVRO'
);

-- to show the records of stream
print test_arvro_schema;

-- describe stream like a table, with columns and etc
describe avro_example;
describe extended avro_example;


-- query from stream
SELECT * 
    FROM 
        avro_example 
    WHERE 
        ROWKEY->NAME = 'Key' 
    EMIT CHANGES;

-- to get old messages
SET 'auto.offset.reset'='earliest';
--
SELECT * 
    FROM 
        avro_example 
    EMIT CHANGES;