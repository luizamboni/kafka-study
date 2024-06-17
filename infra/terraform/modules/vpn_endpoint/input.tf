variable subnet_ids {
  type = list(string)
}

variable vpc_id {
    type = string
}

variable tags {
    type = map(string)
    default = {}
}

variable security_group_id {
    type = string
}

variable cert_ca {
    type = string
}

variable cert_server_ctr {
    type = string
}

variable cert_server_key {
    type = string
}

variable cert_client_ctr {
    type = string
}

variable cert_client_key {
    type = string
}

variable client_cidr_block {
    type = string
}