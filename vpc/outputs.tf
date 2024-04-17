# Output VPC ID
output "vpc_id" {
  value       = aws_vpc.elasticsearch_vpc.id
  description = "VPC ID"
}

output "vpc_cidr" {
  value       = aws_vpc.elasticsearch_vpc.cidr_block
  description = "VPC Info"
}

output "public_subnet_0_id" {
  value       = aws_subnet.public[0].id
  description = "Public Subnet ID"
}

output "public_subnet_1_id" {
  value       = aws_subnet.public[1].id
  description = "Public Subnet 1 ID"
}

output "public_subnet_2_id" {
  value       = aws_subnet.public[2].id
  description = "Public Subnet 1 ID"
}

output "private_subnet_0_id" {
  value       = aws_subnet.private[0].id
  description = "Private Subnet ID"
}

output "private_subnet_1_id" {
  value       = aws_subnet.private[1].id
  description = "Private Subnet ID"
}

output "private_subnet_2_id" {
  value       = aws_subnet.private[2].id
  description = "Private Subnet ID"
}

output "igw_id" {
  value       = aws_internet_gateway.gw.id
  description = "Internet Gateway ID"
}