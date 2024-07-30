variable name {
  type = string
}

variable cluster_id {
    type = string
}

variable image {
    type = string
}

variable region {
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

variable optional_policy_json {
  type        = string
  default     = "{}"
}

variable cpu {
    type    = string
    default = "256"
}

variable memory {
    type    = string
    default = "512"
}

variable health_check {
    type = string
    default = "/"
}