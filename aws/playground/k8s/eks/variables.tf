#############################################
#              VARIABLES
#############################################
variable "tags" {
  type  = map(any)
  default = {}
}

variable "subnets" {
  type  = list(string)
}
