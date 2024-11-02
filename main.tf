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
  Environment = "test"
  Projectname = "ecs-cicd-infra"
}


###### APPLICATION VPC ######

module "module_app_vpc" {
  source  = "app.terraform.io/marvsmpb/vpc-module-marvs/aws"
  version = "1.0.3"

  vpc_cidr_block = "10.100.0.0/16"
  vpc_tags = {
    Name        = "${local.Projectname}-${local.Environment}-app-vpc"
    Environment = "${local.Environment}"
  }
}


module "module_app_subnet_nlb1" {
  source  = "app.terraform.io/marvsmpb/subnet-marvs/aws"
  version = "0.0.14"

  subnet_az   = "ap-southeast-1a"
  subnet_cidr = "10.100.10.0/24"
  subnet_vpc  = module.module_app_vpc.output_vpc_id
  subnet_tags = {
    Name        = "${local.Projectname}-${local.Environment}-app-subnet-nlb1"
    Environment = "${local.Environment}"
  }
}

module "module_app_subnet_nlb2" {
  source  = "app.terraform.io/marvsmpb/subnet-marvs/aws"
  version = "0.0.14"

  subnet_az   = "ap-southeast-1b"
  subnet_cidr = "10.100.20.0/24"
  subnet_vpc  = module.module_app_vpc.output_vpc_id
  subnet_tags = {
    Name        = "${local.Projectname}-${local.Environment}-app-subnet-nlb2"
    Environment = "${local.Environment}"
  }
}

module "module_app_subnet1" {
  source  = "app.terraform.io/marvsmpb/subnet-marvs/aws"
  version = "0.0.14"

  subnet_az   = "ap-southeast-1a"
  subnet_cidr = "10.100.100.0/24"
  subnet_vpc  = module.module_app_vpc.output_vpc_id
  subnet_tags = {
    Name        = "${local.Projectname}-${local.Environment}-app-subnet-app1"
    Environment = "${local.Environment}"
  }
}

module "module_app_subnet2" {
  source  = "app.terraform.io/marvsmpb/subnet-marvs/aws"
  version = "0.0.14"

  subnet_az   = "ap-southeast-1b"
  subnet_cidr = "10.100.200.0/24"
  subnet_vpc  = module.module_app_vpc.output_vpc_id
  subnet_tags = {
    Name        = "${local.Projectname}-${local.Environment}-app-subnet-app1"
    Environment = "${local.Environment}"
  }
}

module "module_app_vpc_peering" {
  source  = "app.terraform.io/marvsmpb/vpc-peering-owner-marvs/aws"
  version = "0.0.3"

  vpc_id      = module.vpc_infra_app.output_vpc_id
  peer_vpc_id = module.module_network_vpc_peering.output_peering_id
  owner_tags = {
    Name        = "${local.Projectname}-${local.Environment}-app-peering"
    Environment = "${local.Environment}"
  }
}

module "module_rtb_app" {
  source  = "app.terraform.io/marvsmpb/rtb-marvs/aws"
  version = "0.0.6"

  rtb_vpc = module.module_app_vpc.output_vpc_id

  route_peering_bool           = true
  route_peering                = module.module_app_vpc_peering.output_peering_id
  route_vpc_peering_destination_cidr_block = "0.0.0.0/0"



  rtb_tags = {
    Name        = "${local.Projectname}-${local.Environment}-app-rtb-app1"
    Environment = "${local.Environment}"
  }
}









###### NETWORK VPC ######

module "module_network_vpc" {
  source  = "app.terraform.io/marvsmpb/vpc-module-marvs/aws"
  version = "1.0.3"

  vpc_cidr_block = "10.200.0.0/16"
  vpc_tags = {
    Name        = "${local.Projectname}-${local.Environment}-network-vpc"
    Environment = "${local.Environment}"
  }
}


module "module_network_subnet_pub1" {
  source  = "app.terraform.io/marvsmpb/subnet-marvs/aws"
  version = "0.0.14"

  subnet_vpc  = module.module_network_vpc.output_vpc_id
  subnet_az   = "ap-southeast-1a"
  subnet_cidr = "10.200.10.0/24"
  subnet_tags = {
    Name        = "${local.Projectname}-${local.Environment}-network-subnet_pub1"
    Environment = "${local.Environment}"
  }

  subnet_public_bool = true
  igw_tags = {
    Name        = "${local.Projectname}-${local.Environment}-network-subnet_pub_igw"
    Environment = "${local.Environment}"
  }
}

module "module_network_subnet_pub2" {
  source  = "app.terraform.io/marvsmpb/subnet-marvs/aws"
  version = "0.0.14"

  subnet_vpc  = module.module_network_vpc.output_vpc_id
  subnet_az   = "ap-southeast-1b"
  subnet_cidr = "10.200.20.0/24"
  subnet_tags = {
    Name        = "${local.Projectname}-${local.Environment}-network-subnet_pub2"
    Environment = "${local.Environment}"
  }
}

module "module_network_vpc_peering" {
  source  = "app.terraform.io/marvsmpb/vpc-peering-owner-marvs/aws"
  version = "0.0.3"

  vpc_id      = module.module_network_vpc.output_vpc_id
  peer_vpc_id = module.module_app_vpc_peering.output_peering_id
  owner_tags = {
    Name        = "${local.Projectname}-${local.Environment}-network-peering"
    Environment = "${local.Environment}"
  }
}

module "module_network_rtb" {
  source  = "app.terraform.io/marvsmpb/rtb-marvs/aws"
  version = "0.0.6"

  rtb_vpc = module.module_network_vpc.output_vpc_id

  route_peering_bool           = true
  route_peering                = module.module_app_vpc_peering.output_peering_id
  route_vpc_peering_destination_cidr_block = "10.100.0.0/16"

  route_internet_gateway_bool                   = true
  route_internet_gateway                        = module.module_network_subnet_pub1.outputs_route_route_internet_gateway
  route_internet_gateway_destination_cidr_block = "0.0.0.0/0"

  rtb_tags = {
    Name        = "${local.Projectname}-${local.Environment}-network-rtb-app1"
    Environment = "${local.Environment}"
  }
}


