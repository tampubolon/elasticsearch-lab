output "public_sg_id" {
  description = "ID of the public EC2 security group"
  value       = aws_security_group.public_sg.id
}

output "public_es_sg_id" {
  description = "ID of the public Elasticsearch EC2 security group"
  value       = aws_security_group.public_es_sg.id
}

output "private_es_sg_id" {
  description = "ID of the private Elasticsearch EC2 security group"
  value       = aws_security_group.private_es_sg.id
}