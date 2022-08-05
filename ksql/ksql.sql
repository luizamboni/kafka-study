CREATE OR REPLACE STREAM avro_example_stream WITH (
    KAFKA_TOPIC='test_arvro_schema',
    KEY_FORMAT='AVRO',
    VALUE_FORMAT='AVRO'
);

-- as table
CREATE OR REPLACE TABLE avro_example_table WITH (
    KAFKA_TOPIC='test_arvro_schema',
    KEY_FORMAT='AVRO',
    VALUE_FORMAT='AVRO'
);

-- to show the records of stream
print test_arvro_schema;

-- describe stream like a table, with columns and etc
describe avro_example_stream;
describe avro_example_stream extended;

describe avro_example_table;
describe avro_example_table extended;


CREATE OR REPLACE  table moduls_table AS
    SELECT 
        count(*) AS N,
        CAST(NAME AS INT) % 2 AS module
    FROM avro_example_table 
    GROUP BY 
        CAST(NAME AS INT)  % 2;


CREATE OR REPLACE table moduls_stream AS
    SELECT 
        count(*) AS N,
        CAST(NAME AS INT) % 2 AS module
    FROM avro_example 
    GROUP BY 
        CAST(NAME AS INT)  % 2;




-- query from stream
SELECT * 
    FROM 
        avro_example 
    WHERE 
        ROWKEY->NAME = 'Key' 
    EMIT CHANGES;

-- to get old messages
SET 'auto.offset.reset'='earliest';


-- example of a push query
SELECT * FROM avro_example EMIT CHANGES;

-- GROUP BY examples
SELECT 
    count(*),
    ROWKEY->NAME
FROM avro_example 
GROUP BY 
    ROWKEY EMIT CHANGES;

SELECT 
    count(*),
    '2'
FROM avro_example 
GROUP BY 
    '2'
EMIT CHANGES;


SELECT * FROM moduls EMIT CHANGES;





LIST STREAMS;

LISTA TABLES;