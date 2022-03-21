from email.policy import default


default_topic_config = {
    "cleanup.policy": "compact",
    # "delete.retention.ms": "1000", 
    # "segment.ms": "100",
    # "min.cleanable.dirty.ratio": "0.01",
}