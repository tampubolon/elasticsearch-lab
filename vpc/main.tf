locals {
  region = "ap-southeast-1"
  default_tags = {
    Owner       = "team-cloud-infra"
    ManagedBy   = "terraform"
    TFProject   = "github.com/tampubolon/elasticsearch-lab/vpc"
    Environment = "playground"
  }

  azs_count      = length(data.aws_availability_zones.available.names)
  subnets_per_az = ceil(var.number_of_subnets / local.azs_count)
}

# Get availability zones in the region
data "aws_availability_zones" "available" {}

# Calculate number of subnets per AZ
variable "number_of_subnets" {
  default = 3
}


# Create VPC
resource "aws_vpc" "elasticsearch_vpc" {
  cidr_block = "192.168.0.0/16"

  tags = merge({
    Name = "Elasticsearch-VPC"
    }, local.default_tags
  )
}


# Create Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.elasticsearch_vpc.id


  tags = merge({
    Name = "Main-IGW"
    }, local.default_tags
  )
}


# Create Public Subnets
resource "aws_subnet" "public" {
  count                   = 3
  vpc_id                  = aws_vpc.elasticsearch_vpc.id
  cidr_block              = cidrsubnet(aws_vpc.elasticsearch_vpc.cidr_block, 8, count.index)
  availability_zone       = element(data.aws_availability_zones.available.names, count.index / local.subnets_per_az)
  map_public_ip_on_launch = true

  tags = merge({
    Name = "Public-Subnet-${count.index}"
    type = "public"
    }, local.default_tags
  )
}


# Create Private Subnets
resource "aws_subnet" "private" {
  count             = 3
  vpc_id            = aws_vpc.elasticsearch_vpc.id
  cidr_block        = cidrsubnet(aws_vpc.elasticsearch_vpc.cidr_block, 8, count.index + 3)
  availability_zone = element(data.aws_availability_zones.available.names, count.index / local.subnets_per_az)

  tags = merge({
    Name = "Private-Subnet-${count.index}"
    type = "private"
    }, local.default_tags
  )
}


# Create Route Table for Public Subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.elasticsearch_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = merge({
    Name = "Public-Route-Table"
    }, local.default_tags
  )
}


# Associate Public Subnets with Public Route Table
resource "aws_route_table_association" "public" {
  count          = 3
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}