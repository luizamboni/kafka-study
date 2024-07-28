variable name {
  type = string
}

variable cluster_id {
    type = string
}

variable image {
    type = string
}

variable internal {
    type = bool
}

variable vpc_id {
    type = string
}

variable subnet_ids {
    type = list(string)
}

variable security_group_id {
    type = string
}

variable tags {
    type = map(string)
    default = {}
}

variable environment_variables {
    type = map(string)
    default = {}
}

variable command {
    type = list(string)
    default = []
}

variable container_port {
    type = number
}