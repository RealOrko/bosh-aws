# VPC

resource "aws_vpc" "cloud_foundary_vpc" {
    cidr_block           = var.vpc_cidr_block
    instance_tenancy     = var.vpc_instance_tenancy 
    enable_dns_support   = var.vpc_dns_support 
    enable_dns_hostnames = var.vpc_dns_hostnames
    tags = {
        Name = "cloud_foundary_vpc"
    }
}

# VPC SUBNET

resource "aws_subnet" "cloud_foundary_public_subnet" {
    vpc_id                  = aws_vpc.cloud_foundary_vpc.id
    cidr_block              = var.vpc_subnet_cidr_block
    map_public_ip_on_launch = var.vpc_subnet_map_public_ip_on_launch 
    availability_zone       = var.vpc_subnet_availability_zone
    tags = {
        Name = "cloud_foundary_public_subnet"
    }
}

# SECURITY GROUP

resource "aws_security_group" "cloud_foundary_security_group" {
    name            = "cloud_foundary_security_group"
    vpc_id          = aws_vpc.cloud_foundary_vpc.id

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
        Name = "cloud_foundary_security_group"
        Description = "Cloud foundary security group"
    }
}