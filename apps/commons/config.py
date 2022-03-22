from email.policy import default

# see here https://docs.confluent.io/platform/current/installation/configuration/topic-configs.html
default_topic_config = {
    "cleanup.policy": "compact",
    "delete.retention.ms": "100", 
    "segment.ms": "100",
    "min.cleanable.dirty.ratio": "0.01", 
    "min.compaction.lag.ms": "100", # The minimum time a message will remain uncompacted in the log
}