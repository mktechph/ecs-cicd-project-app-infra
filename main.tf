terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.73.0"
    }
  }
}

provider "aws" {
  region = "ap-southeast-1"
}

locals {
  environment = "dev"
  projectname = "ecs-cicd-project"
}


module "vpc" {
  source  = "app.terraform.io/marvsmpb/vpc-module-marvs/aws"
  version = "1.0.3"

  vpc_cidr_block = "10.0.0.0/16"
  vpc_tags = {
    Name        = "${local.projectname}-${local.environment}-vpc"
    environment = "${local.environment}"
  }
}


module "nlb_subnet1" {
  source  = "app.terraform.io/marvsmpb/subnet-marvs/aws"
  version = "0.0.2"

  subnet_az   = "ap-southeast-1a"
  subnet_cidr = "10.0.10.0/24"
  subnet_vpc  = module.vpc.output_vpc_id
  subnet_tags = {
    Name = "${local.projectname}-${local.environment}-nlb-subnet1"
  }
}

module "nlb_subnet2" {
  source  = "app.terraform.io/marvsmpb/subnet-marvs/aws"
  version = "0.0.2"

  subnet_az   = "ap-southeast-1b"
  subnet_cidr = "10.0.20.0/24"
  subnet_vpc  = module.vpc.output_vpc_id
  subnet_tags = {
    Name = "${local.projectname}-${local.environment}-nlb-subnet2"
  }
}

module "app_subnet1" {
  source  = "app.terraform.io/marvsmpb/subnet-marvs/aws"
  version = "0.0.2"

  subnet_az   = "ap-southeast-1a"
  subnet_cidr = "10.0.100.0/24"
  subnet_vpc  = module.vpc.output_vpc_id
  subnet_tags = {
    Name = "${local.projectname}-${local.environment}-app-subnet1"
  }
}

module "app_subnet2" {
  source  = "app.terraform.io/marvsmpb/subnet-marvs/aws"
  version = "0.0.2"

  subnet_az   = "ap-southeast-1b"
  subnet_cidr = "10.0.200.0/24"
  subnet_vpc  = module.vpc.output_vpc_id
  subnet_tags = {
    Name = "${local.projectname}-${local.environment}-app-subnet2"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = module.vpc.output_vpc_id

  tags = {
    Name = "main"
  }
}

resource "aws_internet_gateway_attachment" "example" {
  internet_gateway_id = aws_internet_gateway.igw.id
  vpc_id              = module.vpc.output_vpc_id
}

module "rtb-app" {
  source  = "app.terraform.io/marvsmpb/rtb-marvs/aws"
  version = "0.0.3"

  rtb_vpc = module.vpc.output_vpc_id
  route_destination_cidr_block = "0.0.0.0/0"
  rtb_tags = {
    Name = "${local.projectname}-${local.environment}-app-rtb"
  }

  route_internet_gateway_bool = true
  route_internet_gateway      = aws_internet_gateway.igw.id
}