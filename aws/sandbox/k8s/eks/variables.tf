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

# variable "subnets" {
#   type  = list(string)
# }

# variable "nodegroup_subnet" {
#   type  = list(string)
# }

# variable "nodegroup_data" {
#   type  = map(object({
#     name = string
#     scaling_config = list(object({
#       desired   = number
#       max       = number
#       min       = number
#     }))
#   }))
# }