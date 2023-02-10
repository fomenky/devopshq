#############################################
# OUTPUTS
#############################################

output "vpc_id" {
  description = "VPC Id"
  value       = aws_vpc.default.id
}
