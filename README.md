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

## Confluent schema-registry
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
## Glue Schema Registry

Aws Glue can be used as schema Registry too.

OBS: schema Registries add a header in raw message
In cara of Glue this header its compose of 18 bytes prefixing the payload.

|  0          |      1    |     2-17       |
|:------------:|-----------:|:------------:|
|8 bit version| 1 about compression| is a 128 bytes uuid |

create without schema-registry:

```b{'Scope': 'dev', 'Name': 'testevent', 'Version': 'v0', 'Payload': {'required_field': 'valor do required_field', 'struct_field': {'text_field': 'valor do text_field'}}}```

created by aws_glue_schema_registry producer:

```b\x03\x00\x13\xc0d\x87W\xd3E\x15\xa9\x18\xb6\x8a\x0f\x7f\xa0\xf0{"Scope":"dev","Version":"v0","Payload":{"required_field":"valor do required_field","struct_field":{"text_field":"valor do text_field"}},"Name":"testevent"}```




```python
import uuid

value = b'\x03\x00\x13\xc0d\x87W\xd3E\x15\xa9\x18\xb6\x8a\x0f\x7f\xa0\xf0{"Scope":"dev","Version":"v0","Payload":{"required_field":"valor do required_field","struct_field":{"text_field":"valor do text_field"}},"Name":"testevent"}'

uuid.UUID(bytes=value[2:18])
# UUID('13c06487-57d3-4515-a918-b68a0f7fa0f0') 
# ^ match with a schema registred in glue
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
    - product_id
    - click_id

- Visits
    - id


