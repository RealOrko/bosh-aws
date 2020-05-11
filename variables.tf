# VPC

variable "vpc_dns_support" {
    default = true
}

variable "vpc_dns_hostnames" {
    default = true
}

variable "vpc_cidr_block" {
    default = "10.0.0.0/16"
}

variable "vpc_instance_tenancy" {
    default = "default"
}

# VPC SUBNET

variable "vpc_subnet_availability_zone" {
     default = "eu-west-1a"
}

variable "vpc_subnet_cidr_block" {
    default = "10.0.0.0/24"
}

variable "vpc_subnet_map_public_ip_on_launch" {
    default = true
}

# SECURITY GROUP

variable "security_group_ingress_cidr_ranges" {
    type = list
    default = [ "0.0.0.0/0" ]
}

variable "security_group_engress_cidr_ranges" {
    type = list
    default = [ "0.0.0.0/0" ]
}