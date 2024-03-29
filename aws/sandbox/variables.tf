#############################################
#         NETWORK/VPC VARIABLES
#############################################
variable "region" {
  description = "Amazon region"
  default = "us-east-1"
}

# variable "vpc_cidr_block" {
#   description = "VPC Subnet"
# }

# variable "public_subnet_cidr_block" {
#   description = "Public Subnet"
# }

# variable "private_subnet_cidr_block" {
#   description = "Private Subnet"
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