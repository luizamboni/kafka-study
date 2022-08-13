FROM confluentinc/cp-kafka-connect-base:7.0.1

USER root

RUN confluent-hub install --no-prompt confluentinc/kafka-connect-s3:10.0.9
RUN confluent-hub install --no-prompt confluentinc/kafka-connect-jdbc:10.3.3
RUN confluent-hub install --no-prompt confluentinc/connect-transforms:1.4.3

USER appuser
