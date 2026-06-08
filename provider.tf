terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.0"
      #version so nothing breaks bc of updates
    }
  }
}
#terraform runs on many cloud providers, so have to tell terraform which provider im using

provider "aws" {
  region = "us-east-1"
}
# sets up region in a provider (aws's north virgina region)

# The main VPC container
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  #ip adress range
  enable_dns_hostnames = true
  enable_dns_support = true

  tags = {
    Name = "custom-vpc"
  }
}