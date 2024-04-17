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

output "public_ec2_instance_ids" {
  description = "IDs of the public EC2 instances (non-Elasticsearch)"
  value       = aws_instance.public_ec2_instances[*].id
}

output "public_es_ec2_instance_ids" {
  description = "IDs of the public Elasticsearch EC2 instances"
  value       = aws_instance.public_es_ec2_instances[*].id
}

output "private_es_ec2_instance_ids" {
  description = "IDs of the private Elasticsearch EC2 instances"
  value       = aws_instance.private_es_ec2_instances[*].id
}