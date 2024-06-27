variable name {
    type = string
}

variable vpc_cidr {
    type = string
}

variable tags {
    type = map(string)
}

variable subnet_config {
    type = list(object({
        cidr = string
        az   = string
    }))
}

variable region {
    type = string
}