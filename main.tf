# VPC

resource "aws_vpc" "cloudfoundary_vpc" {
    cidr_block           = var.vpc_cidr_block
    instance_tenancy     = var.vpc_instance_tenancy 
    enable_dns_support   = var.vpc_dns_support 
    enable_dns_hostnames = var.vpc_dns_hostnames
    tags = {
        Name = "cloudfoundary_vpc"
    }
}

# GATEWAY

resource "aws_internet_gateway" "cloudfoundary_internet_gateway" {
    vpc_id  = aws_vpc.cloudfoundary_vpc.id
    tags = {
        Name = "cloudfoundary_internet_gateway"
    }
}

# VPC SUBNET

resource "aws_subnet" "cloudfoundary_public_subnet" {
    vpc_id                  = aws_vpc.cloudfoundary_vpc.id
    cidr_block              = var.vpc_subnet_cidr_block
    map_public_ip_on_launch = var.vpc_subnet_map_public_ip_on_launch 
    availability_zone       = var.vpc_subnet_availability_zone
    depends_on              = [aws_internet_gateway.cloudfoundary_internet_gateway]
    tags = {
        Name = "cloudfoundary_public_subnet"
    }
}

# SECURITY GROUP

resource "aws_security_group" "cloudfoundary_security_group" {
    name            = "cloudfoundary_security_group"
    vpc_id          = aws_vpc.cloudfoundary_vpc.id

    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = var.security_group_ingress_cidr_ranges  
    } 

    ingress {
        from_port   = 6868
        to_port     = 6868
        protocol    = "tcp"
        cidr_blocks = var.security_group_ingress_cidr_ranges  
    } 

    ingress {
        from_port   = 25555
        to_port     = 25555
        protocol    = "tcp"
        cidr_blocks = var.security_group_ingress_cidr_ranges  
    } 

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = var.security_group_engress_cidr_ranges  
    }
    tags = {
        Name = "cloudfoundary_security_group"
        Description = "Cloud foundary security group"
    }
}

# ELASTIC IP

resource "aws_eip" "cloudfoundary_elastic_ip" {
    vpc                       = true
    associate_with_private_ip = var.elastic_ip_internal_ip
    depends_on                = [aws_internet_gateway.cloudfoundary_internet_gateway]
    tags = {
        Name = "cloudfoundary_elastic_ip"
    }
}

# KEY PAIR

resource "tls_private_key" "cloudfoundry_private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "cloudfoundry_keypair" {
    key_name   = "cloudfoundry_keypair"
    public_key = tls_private_key.cloudfoundry_private_key.public_key_openssh
    tags = {
        Name = "cloudfoundry_keypair"
    }
}