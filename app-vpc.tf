###### APPLICATION VPC ######

module "module_app_vpc" {
  source  = "app.terraform.io/marvsmpb/vpc-module-marvs/aws"
  version = "1.0.4"

  vpc_cidr_block = "10.100.0.0/16"
  vpc_tags = {
    Name        = "${local.Projectname}-${local.Environment}-app-vpc"
    Environment = "${local.Environment}"
  }
}

module "module_app_tgw_subnet1" {
  source  = "app.terraform.io/marvsmpb/subnet-marvs/aws"
  version = "0.0.14"

  subnet_vpc  = module.module_app_vpc.output_vpc_id
  subnet_az   = "ap-southeast-1a"
  subnet_cidr = "10.100.10.0/24"
  subnet_tags = {
    Name        = "${local.Projectname}-${local.Environment}-app-tgw-subnet1"
    Environment = "${local.Environment}"
  }
}

module "module_app_tgw_subnet2" {
  source  = "app.terraform.io/marvsmpb/subnet-marvs/aws"
  version = "0.0.14"

  subnet_vpc  = module.module_app_vpc.output_vpc_id
  subnet_az   = "ap-southeast-1b"
  subnet_cidr = "10.100.20.0/24"
  subnet_tags = {
    Name        = "${local.Projectname}-${local.Environment}-app-tgw-subnet2"
    Environment = "${local.Environment}"
  }
}


module "module_app_subnet_nlb1" {
  source  = "app.terraform.io/marvsmpb/subnet-marvs/aws"
  version = "0.0.14"

  subnet_az   = "ap-southeast-1a"
  subnet_cidr = "10.100.30.0/24"
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
  subnet_cidr = "10.100.40.0/24"
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
    Name        = "${local.Projectname}-${local.Environment}-app-subnet-app2"
    Environment = "${local.Environment}"
  }
}


module "module_rtb_app" {
  source  = "app.terraform.io/marvsmpb/rtb-marvs/aws"
  version = "0.0.6"

  rtb_vpc = module.module_app_vpc.output_vpc_id

  #route_peering_bool                       = true
  #route_peering                            = module.module_app_vpc_peering.output_peering_id
  #route_vpc_peering_destination_cidr_block = "0.0.0.0/0"

  rtb_tags = {
    Name        = "${local.Projectname}-${local.Environment}-app-rtb-app1"
    Environment = "${local.Environment}"
  }
}

# TGW ROUTE
resource "aws_route" "route_app_subnet_to_tgw" {
  route_table_id         = module.module_rtb_app.outputs_rtb_id
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
}

resource "aws_route_table_association" "rtb_app_assoc_tgw_subnet1" {
  subnet_id      = module.module_app_tgw_subnet1.outputs_subnet_id
  route_table_id = module.module_rtb_app.outputs_rtb_id
}
resource "aws_route_table_association" "rtb_app_assoc_tgw_subnet2" {
  subnet_id      = module.module_app_tgw_subnet2.outputs_subnet_id
  route_table_id = module.module_rtb_app.outputs_rtb_id
}
resource "aws_route_table_association" "rtb_app_assoc_app_subnet1" {
  subnet_id      = module.module_app_subnet1.outputs_subnet_id
  route_table_id = module.module_rtb_app.outputs_rtb_id
}
resource "aws_route_table_association" "rtb_app_assoc_app_subnet2" {
  subnet_id      = module.module_app_subnet2.outputs_subnet_id
  route_table_id = module.module_rtb_app.outputs_rtb_id
}
resource "aws_route_table_association" "rtb_app_assoc_nlb_subnet1" {
  subnet_id      = module.module_app_subnet_nlb1.outputs_subnet_id
  route_table_id = module.module_rtb_app.outputs_rtb_id
}
resource "aws_route_table_association" "rtb_app_assoc_nlb_subnet2" {
  subnet_id      = module.module_app_subnet_nlb2.outputs_subnet_id
  route_table_id = module.module_rtb_app.outputs_rtb_id
}


module "module_app_ecs_ecr_subnet1_endpoint" {
  source  = "app.terraform.io/marvsmpb/vpc-endpoint-ecs-ecr-marvs/aws"
  version = "0.0.8"

  vpc_id = module.module_app_vpc.output_vpc_id

  ecs_endpoint_subnet_id           = [module.module_app_subnet1.outputs_subnet_id]
  ecs_agent_endpoint_subnet_id     = [module.module_app_subnet1.outputs_subnet_id]
  ecs_telemetry_endpoint_subnet_id = [module.module_app_subnet1.outputs_subnet_id]
  ecr_api_endpoint_subnet_id       = [module.module_app_subnet1.outputs_subnet_id]
  ecr_dkr_endpoint_subnet_id       = [module.module_app_subnet1.outputs_subnet_id]

  sg_ecr_api_endpoint       = [aws_security_group.sg_allow_all.id]
  sg_ecr_dkr_endpoint       = [aws_security_group.sg_allow_all.id]
  sg_ecs_agent_endpoint     = [aws_security_group.sg_allow_all.id]
  sg_ecs_endpoint           = [aws_security_group.sg_allow_all.id]
  sg_ecs_telemetry_endpoint = [aws_security_group.sg_allow_all.id]


  endpoint_tags = {
    Name        = "${local.Projectname}-${local.Environment}-app-ecs-ecr-endpoint-subnet1-app1"
    Environment = "${local.Environment}"
  }
}

#module "module_app_ecs_ecr_subnet2_endpoint" {
#  source  = "app.terraform.io/marvsmpb/vpc-endpoint-ecs-ecr-marvs/aws"
#  version = "0.0.6"
#
#  vpc_id = module.module_app_vpc.output_vpc_id
#
#  ecs_endpoint_subnet_id           = [module.module_app_subnet2.outputs_subnet_id]
#  ecs_agent_endpoint_subnet_id     = [module.module_app_subnet2.outputs_subnet_id]
#  ecs_telemetry_endpoint_subnet_id = [module.module_app_subnet2.outputs_subnet_id]
#  ecr_api_endpoint_subnet_id       = [module.module_app_subnet2.outputs_subnet_id]
#  ecr_dkr_endpoint_subnet_id       = [module.module_app_subnet2.outputs_subnet_id]
#
#  endpoint_tags = {
#    Name        = "${local.Projectname}-${local.Environment}-app-ecs-ecr-endpoint-subnet2-app1"
#    Environment = "${local.Environment}"
#  }
#}


resource "aws_vpc_endpoint" "s3_endpoint" {
  vpc_id            = module.module_app_vpc.output_vpc_id
  service_name      = "com.amazonaws.ap-southeast-1.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [module.module_rtb_app.outputs_rtb_id]
}


#module "module_ssm_endpoint" {
#  source  = "app.terraform.io/marvsmpb/vpc-endpoint-ssm/aws"
#  version = "0.0.3"
#
#  vpc_id = module.module_app_vpc.output_vpc_id
#
#  ec2_messages_subnet_id = [module.module_app_subnet1.outputs_subnet_id]
#  ssm_endpoint_subnet_id = [module.module_app_subnet1.outputs_subnet_id]
#  ssm_messages_subnet_id = [module.module_app_subnet1.outputs_subnet_id]
#
#  sg_ec2_messages = [aws_security_group.sg_allow_all.id]
#  sg_ssm_endpoint = [aws_security_group.sg_allow_all.id]
#  sg_ssm_messages = [aws_security_group.sg_allow_all.id]
#
#  endpoint_tags = {
#    Name        = "${local.Projectname}-${local.Environment}-app-ssm-endpoints"
#    Environment = "${local.Environment}"
#  }
#}

#module "module_app_vpc_peering" {
#  source  = "app.terraform.io/marvsmpb/vpc-peering-owner-marvs/aws"
#  version = "0.0.3"
#
#  vpc_id      = module.module_app_vpc.output_vpc_id
#  peer_vpc_id = module.module_network_vpc.output_vpc_id
#  owner_tags = {
#    Name        = "${local.Projectname}-${local.Environment}-app-peering"
#    Environment = "${local.Environment}"
#  }
#}