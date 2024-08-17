FROM confluentinc/cp-kafka-connect-base:7.0.10.arm64
# FROM confluentinc/cp-kafka-connect-base:7.0.10

USER root

ENV KAFKA_HEAP_OPTS="-Xms512m -Xmx2g"


RUN confluent-hub install --no-prompt confluentinc/kafka-connect-s3:10.0.9
RUN confluent-hub install --no-prompt confluentinc/kafka-connect-jdbc:10.3.3
RUN confluent-hub install --no-prompt confluentinc/connect-transforms:1.4.3
COPY /aws/ /usr/share/confluent-hub-components/confluentinc-kafka-connect-s3/lib
USER appuser
