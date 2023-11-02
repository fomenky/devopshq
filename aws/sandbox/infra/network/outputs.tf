#############################################
# OUTPUTS
#############################################

output "vpc_id" {
  description = "VPC Id"
  value       = aws_vpc.default.id
}

output "public_subnet_one" {
  description = "Public Subnet Id"
  value       = aws_subnet.public-subnet.id
}

output "private_subnet_one" {
  description = "Private Subnet Id"
  value       = aws_subnet.private-subnet.id
}