variable "ec2_yaml_file" {
  description = "Path to the YAML file describing EC2 instances"
  type        = string
  default     = "ec2.yaml"
}

variable "ami" {
  description = "AMI ID for EC2 instances"
  type        = string
  default     = "ami-08e4b984abde34a4f" # Ubuntu 20.04 LTS
}

locals {
  vpc_id        = "vpc-05f0ddde7f3660106"
  ec2_instances = yamldecode(file(var.ec2_yaml_file))

  public_subnet_ids  = tolist(data.aws_subnet_ids.public.ids)
  private_subnet_ids = tolist(data.aws_subnet_ids.private.ids)

  ansible_instances = [
    for instance in local.ec2_instances.ansible : {
      name          = instance.name
      instance_type = instance.instance_type
      ansible       = try(instance.ansible, null)
    }
  ]

  elasticsearch = {
    public = [
      for instance in local.ec2_instances.elasticsearch.public : {
        name          = instance.name
        instance_type = instance.instance_type
        elasticsearch = try(instance.elasticsearch, null) # Ensure elasticsearch attribute is included
      }
    ]
    private = [
      for instance in local.ec2_instances.elasticsearch.private : {
        name          = instance.name
        instance_type = instance.instance_type
        elasticsearch = try(instance.elasticsearch, null) # Ensure elasticsearch attribute is included
      }
    ]
  }
}


data "aws_subnet_ids" "public" {
  vpc_id = local.vpc_id

  filter {
    name   = "tag:type"
    values = ["public"]
  }
}

data "aws_subnet_ids" "private" {
  vpc_id = local.vpc_id

  filter {
    name   = "tag:type"
    values = ["private"]
  }
}


# Ansible ec2 instance
resource "aws_instance" "ansible" {
  count = length(local.ansible_instances)

  ami                         = var.ami
  instance_type               = local.ansible_instances[count.index].instance_type
  subnet_id                   = local.public_subnet_ids[count.index % length(local.public_subnet_ids)]
  key_name                    = "elasticsearch"
  associate_public_ip_address = true

  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name

  tags = {
    Name = local.ansible_instances[count.index].name
  }

  vpc_security_group_ids = [aws_security_group.ansible.id]

  user_data = templatefile("${path.module}/user_data_ansible.tpl", {
    ansible = local.ansible_instances[count.index].ansible
  })
}


# Public Elasticsearch ec2 instance
resource "aws_instance" "public_es" {
  count = length(local.elasticsearch.public)

  ami                         = var.ami
  instance_type               = local.elasticsearch.public[count.index].instance_type
  subnet_id                   = local.public_subnet_ids[count.index % length(local.public_subnet_ids)]
  key_name                    = "elasticsearch"
  associate_public_ip_address = true

  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name

  tags = {
    Name = local.elasticsearch.public[count.index].name
  }

  vpc_security_group_ids = [aws_security_group.public_es_sg.id]

  user_data = templatefile("${path.module}/user_data_es.tpl", {
    elasticsearch = local.elasticsearch.public[count.index].elasticsearch
  })
}


# Private Elasticsearch ec2 instance
resource "aws_instance" "private_es" {
  count = length(local.elasticsearch.private)

  ami                         = var.ami
  instance_type               = local.elasticsearch.private[count.index].instance_type
  subnet_id                   = local.private_subnet_ids[count.index % length(local.private_subnet_ids)]
  key_name                    = "elasticsearch"
  associate_public_ip_address = false

  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name

  tags = {
    Name = local.elasticsearch.private[count.index].name
  }

  vpc_security_group_ids = [aws_security_group.private_es_sg.id]

  user_data = templatefile("${path.module}/user_data_es.tpl", {
    elasticsearch = local.elasticsearch.private[count.index].elasticsearch
  })
}
