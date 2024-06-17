variable name {
   type = string 
}

variable subnet_ids {
  type        = list(string)
  default     = []
}

variable security_group_id {
    type = string
}

variable "vpc_id" {
  type = string
}

variable tags {
    type = map(string)
    default = {}
}