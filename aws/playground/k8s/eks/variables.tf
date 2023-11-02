#############################################
#              VARIABLES
#############################################
variable "cluster_name" {
  type  = string
}

variable "cluster_version" {
  type  = string
}

variable "tags" {
  type  = map(any)
  default = {}
}

variable "subnets" {
  type  = list(string)
}
