terraform {
  required_version = "= 1.7.2"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.0, < 4.0"
    }
  }

  backend "s3" {
    bucket  = "elasticsearch-martinus"
    key     = "elasticsearch-lab/ec2.tfstate"
    region  = "ap-southeast-1"
    encrypt = true
  }
}

provider "aws" {
  region = "ap-southeast-1"
}