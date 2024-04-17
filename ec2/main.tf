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

  public_subnet_count  = length(tolist(data.aws_subnet_ids.public.ids))
  private_subnet_count = length(tolist(data.aws_subnet_ids.private.ids))

  public_subnet_indices  = range(local.public_subnet_count)
  private_subnet_indices = range(local.private_subnet_count)

  public_instance_count  = length(local.ec2_instances.public)
  private_instance_count = length(local.ec2_instances.private)

  public_instances_with_es        = [for instance in local.ec2_instances.public : instance if instance.elasticsearch == "true"]
  public_instances_without_es     = [for instance in local.ec2_instances.public : instance if instance.elasticsearch == "false"]
  public_instances_without_es_map = { for instance in local.ec2_instances.public : instance.name => instance }

  public_instance_es_count  = length(local.public_instances_with_es)
  public_instance_non_count = length(local.public_instances_without_es)

  public_instance_indices = { for idx, instance in local.public_instances_without_es : idx => instance }
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

# Public ec2 instance for non Elasticsearch
resource "aws_instance" "public_ec2_instances" {
  for_each = local.public_instances_without_es_map

  ami           = var.ami
  instance_type = each.value.instance_type
  subnet_id = element(
    tolist(data.aws_subnet_ids.public.ids),
    index([for instance in values(local.public_instances_without_es_map) : instance.name], each.key) % local.public_subnet_count
  )
  
  key_name                    = "elasticsearch"
  associate_public_ip_address = true

  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name

  tags = {
    Name = each.value.name
  }

  vpc_security_group_ids = [aws_security_group.public_sg.id]

  user_data = templatefile("${path.module}/user_data_ansible.tpl", {
    elasticsearch = each.value.elasticsearch
  })
}

# Public ec2 instance for Elasticsearch
resource "aws_instance" "public_es_ec2_instances" {
  # count = local.public_instance_count
  count = local.public_instance_es_count

  ami                         = var.ami
  instance_type               = local.ec2_instances.public[count.index].instance_type
  subnet_id                   = element(data.aws_subnet_ids.public.ids, local.public_subnet_indices[count.index % local.public_subnet_count])
  key_name                    = "elasticsearch"
  associate_public_ip_address = true

  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name

  tags = {
    Name = local.ec2_instances.public[count.index].name
  }

  vpc_security_group_ids = [aws_security_group.public_es_sg.id]

  user_data = templatefile("${path.module}/user_data_es.tpl", {
    elasticsearch = local.ec2_instances.public[count.index].elasticsearch
  })
}

# Private ec2 instance for Elasticsearch
resource "aws_instance" "private_es_ec2_instances" {
  count = local.private_instance_count

  ami                         = var.ami
  instance_type               = local.ec2_instances.private[count.index].instance_type
  subnet_id                   = element(tolist(data.aws_subnet_ids.private.ids), local.private_subnet_indices[count.index % local.private_subnet_count])
  key_name                    = "elasticsearch"
  associate_public_ip_address = false

  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name

  tags = {
    Name = local.ec2_instances.private[count.index].name
  }

  vpc_security_group_ids = [aws_security_group.private_es_sg.id]

  user_data = templatefile("${path.module}/user_data_es.tpl", {
    elasticsearch = local.ec2_instances.private[count.index].elasticsearch
  })
}
