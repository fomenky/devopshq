#############################################
# NETWORK INFRASTRUCTURE TEMPLATE
#############################################

module "vpc_tags" {
  source = "../../global/tags"
  
  name = "terraform-playground"
}

## VPC
resource "aws_vpc" "default" {
    cidr_block = var.vpc_cidr_block

    tags = module.vpc_tags.tags
}

## IGW
resource "aws_internet_gateway" "default" {
    vpc_id = aws_vpc.default.id

    tags = merge(
        module.vpc_tags.tags,
        {
          Name = "playground-ibs-d-ue1-default-igw"
        }
      )
}

## Subnets
resource "aws_subnet" "public-subnet" {
    vpc_id            = aws_vpc.default.id
    cidr_block        = var.public_subnet_cidr_block
    availability_zone = "us-east-1a"

    tags = merge(
        module.vpc_tags.tags,
        {
          Name = "playground-ibs-d-ue1-public-subnet"
        }
      )
}

resource "aws_subnet" "private-subnet" {
    vpc_id            = aws_vpc.default.id
    cidr_block        = var.private_subnet_cidr_block
    availability_zone = "us-east-1b"

    tags = merge(
        module.vpc_tags.tags,
        {
          Name = "playground-ibs-d-ue1-private-subnet"
        }
      )

}

# Route Tables
resource "aws_route_table" "public-rt" {
    vpc_id = aws_vpc.default.id

    # route = {
    #     cidr_block = "0.0.0.0/0"
    #     gateway_id = aws_internet_gateway.default.id
    # }
    
    tags = merge(
        module.vpc_tags.tags,
        {
          Name = "playground-ibs-d-ue1-public-rt"
        }
      )
}

resource "aws_route_table_association" "public-rt-assoc" {
    subnet_id = aws_subnet.public-subnet.id
    route_table_id = aws_route_table.public-rt.id
}