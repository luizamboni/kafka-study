SET 'ksql.query.pull.table.scan.enabled'='true'
-- to get old messages
SET 'auto.offset.reset'='earliest';

-- SET 'auto.offset.reset'='latest';


-- to show the records of stream
print 'test_arvro_schema-product';

-- as table
CREATE OR REPLACE TABLE original_product_table WITH (
    KAFKA_TOPIC='test_arvro_schema-product',
    KEY_FORMAT='AVRO',
    VALUE_FORMAT='AVRO'
);

CREATE OR REPLACE STREAM original_visit WITH (
    KAFKA_TOPIC='test_arvro_schema-visit',
    KEY_FORMAT='AVRO',
    VALUE_FORMAT='AVRO'
);

CREATE OR REPLACE STREAM original_click WITH (
    KAFKA_TOPIC='test_arvro_schema-click',
    KEY_FORMAT='AVRO',
    VALUE_FORMAT='AVRO'
);


CREATE OR REPLACE STREAM original_order WITH (
    KAFKA_TOPIC='test_arvro_schema-order',
    KEY_FORMAT='AVRO',
    VALUE_FORMAT='AVRO'
);




CREATE TABLE product_table AS SELECT * FROM original_product_table;

-- describe stream like a table, with columns and etc
describe product_stream;
describe product_stream;

describe product_table;
describe product_table extended;





-- query from stream

SELECT
    p.name product_name,
    p.id product_id,
    o.id order_id,
    c.id click_id
FROM 
    original_order o
JOIN original_click c WITHIN 1 HOURS ON c.id = o.click_id
JOIN original_visit v WITHIN 48 HOURS ON v.id = c.visit_id
-- Invalid join condition: stream-table joins require to join on the table's primary key
JOIN original_product_table p ON p.rowkey = o.product_id
EMIT CHANGES;


DROP stream enriched_orders;

CREATE OR REPLACE stream enriched_orders AS 

    SELECT
        o.id order_id,
        p.name product_name,
        o.product_id product_id,
        c.id click_id,
        v.id visit_id
    FROM 
        original_order o
    JOIN original_click c WITHIN 1 HOURS ON c.id = o.click_id
    JOIN original_visit v WITHIN 48 HOURS ON v.id = c.visit_id
    JOIN original_product_table p ON p.rowkey = o.product_id
;

SELECT 
    *
FROM enriched_orders 
EMIT CHANGES;



-- grouping products_order
SELECT
    p.id product_id,
    p.name name,
    count(1)
FROM 
    original_order o
JOIN 
    original_product_table p ON p.rowkey = o.product_id
GROUP BY 
    p.id, p.name
EMIT CHANGES;


LIST STREAMS;
LIST TABLES;