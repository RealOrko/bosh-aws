output "cloudfoundry_security_group_name" {
    value = aws_security_group.cloudfoundary_security_group.name
}

output "cloudfoundry_availability_zone" {
    value = var.vpc_subnet_availability_zone
}

output "cloudfoundry_elastic_ip_public_ip" {
    value = aws_eip.cloudfoundary_elastic_ip.public_ip
}

output "cloudfoundry_elastic_ip_private_ip" {
    value = var.elastic_ip_internal_ip
}

output "cloudfoundry_internet_gateway_cidr" {
    value = var.vpc_cidr_block
}

output "cloudfoundry_vpc_subnet_id" {
    value = aws_subnet.cloudfoundary_public_subnet.id
}

output "cloudfoundry_vpc_subnet_cidr_block" {
    value = var.vpc_subnet_cidr_block
}

output "cloudfoundry_keyname" {
    value = aws_key_pair.cloudfoundry_keypair.key_name
}

output "cloudfoundry_private_key" {
    value = tls_private_key.cloudfoundry_private_key.private_key_pem
    sensitive = true
}

output "cloudfoundry_public_key" {
    value = tls_private_key.cloudfoundry_private_key.public_key_openssh
    sensitive = true
}