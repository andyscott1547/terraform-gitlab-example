variable "interface_endpoints" {
  description = "object representing the region and services to create interface endpoints for"
  type = map(object({
    phz = string
  }))
}

variable "gateway_endpoints" {
  description = "object representing the region and services to create gateway endpoints for"
  type = map(object({
    route_table_ids = list(string)
  }))
}

variable "vpc_id" {
  description = "ID of the VPC to create endpoints in"
  type        = string
  validation {
    condition     = can(regex("^vpc-[a-z0-9]{8,}", var.vpc_id))
    error_message = "The VPC ID value must be a valid VPC ID, starting with \"vpc-\"."
  }
}

variable "subnet_ids" {
  description = "IDs of the subnets to create endpoints in"
  type        = list(string)
}

