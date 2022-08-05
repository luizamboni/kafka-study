Kafka Study
===

This is a dummy project with the purpose of kafka study with the use of some small examples to cover some topics.

- log compression;
- order consuming;
- messaging schemas;
- schemas formats (Akron, JSON, Protobuffer, etc);
- replay, foward and rewind of the messagens in a topic;
- cluster management (creation, deletion and scaling);
- [kSQL](https://www.confluent.io/blog/ksql-streaming-sql-for-apache-kafka/) uses;
- alternatives do Docker (extra topic);
- and more ...

We will use [coingecko](https://www.coingecko.com/en/api/documentation) API to give some contexts to project and make it more tasty.

This project uses docker and docker-compose in order to create local environments and Makefile to automatize some tasks.

# kafka stack components
kafka stack means a set of servers to deliver and receive streams or messages
with many features and assets

## kakfa
it s kafka broker itself, where messages are pull and pushed

## zookeper
it controls a kafka necessary metadata, has already a discussion in comunity about strip
out 

## schema-registry
where producers registry the schemas as Avro, JsonSchema, ProtoBuff and
consumers loads it ones.
SchemaRegistry works as http API and use kafka as your storage for schemas.
### The REST Api
subjects
```shell
    curl localhost:8081/subjects  | jq '.'
```

schemas will responds our Avro(in example) schemas, a descriptions of fields
```shell
    curl localhost:8081/schemas  | jq '.'
```


## kafka-rest
...

## ksqldb-server
...

## kafka-connect
It s a integration of sources and syncs with kafka by "plug and play" based in declarative configs.
For exemple:
mysql table -> kafka topic -> kibana index


### 
https://github.com/confluentinc/kafka-connect-storage-cloud/

## partitioners
https://github.com/confluentinc/kafka-connect-storage-common/tree/master/partitioner/src/main/java/io/confluent/connect/storage/partitioner


# Avro Example
- Products
    - id
    - name

- Clicks
    - id uuid
    - product_id
    - visit_id

- Orders
    - id
    - visit_id
    - product_id