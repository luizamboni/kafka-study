variable name {
    type = string
}

variable region {
    type = string
}

variable subnet_ids {
    type = list(string)
}

variable security_group_id {
    type = string
}

variable topics {
    type = string
}

variable bucket_name {
    type = string
}

variable key_schema_name {
    type = string
}

variable register_name {
    type = string
}

variable value_schema_name {
    type = string
}

variable bootstrap_brokers_tls {
    type = string
}

variable custom_plugin_arn {
    type = string
}

variable custom_plugin_revision {
    type = string
}

variable tags {
    type = map(string)
    default = {}
}