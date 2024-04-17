terraform {
  required_version = "= 1.7.2"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.35.0"
    }
  }

  backend "s3" {
    bucket  = "elasticsearch-martinus"
    key     = "elasticsearch-lab/vpc.tfstate"
    region  = "ap-southeast-1"
    encrypt = true
  }
}

provider "aws" {
  region = "ap-southeast-1"
}