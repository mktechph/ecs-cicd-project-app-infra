####### NETWORK VPC ######
#
#module "module_network_vpc" {
#  source  = "app.terraform.io/marvsmpb/vpc-module-marvs/aws"
#  version = "1.0.4"
#
#  vpc_cidr_block = "10.200.0.0/16"
#  vpc_tags = {
#    Name        = "${local.Projectname}-${local.Environment}-network-vpc"
#    Environment = "${local.Environment}"
#  }
#}
#
#
#module "module_network_pub_subnet1" {
#  source  = "app.terraform.io/marvsmpb/subnet-marvs/aws"
#  version = "0.0.14"
#
#  subnet_vpc  = module.module_network_vpc.output_vpc_id
#  subnet_az   = "ap-southeast-1a"
#  subnet_cidr = "10.200.10.0/24"
#  subnet_tags = {
#    Name        = "${local.Projectname}-${local.Environment}-network-pub-subnet1"
#    Environment = "${local.Environment}"
#  }
#
#  subnet_public_bool = true
#  igw_tags = {
#    Name        = "${local.Projectname}-${local.Environment}-network-pub-subnet-igw"
#    Environment = "${local.Environment}"
#  }
#}
#
#module "module_network_pub_subnet2" {
#  source  = "app.terraform.io/marvsmpb/subnet-marvs/aws"
#  version = "0.0.14"
#
#  subnet_vpc  = module.module_network_vpc.output_vpc_id
#  subnet_az   = "ap-southeast-1b"
#  subnet_cidr = "10.200.20.0/24"
#  subnet_tags = {
#    Name        = "${local.Projectname}-${local.Environment}-network-pub-subnet2"
#    Environment = "${local.Environment}"
#  }
#}
#
#module "module_network_tgw_subnet1" {
#  source  = "app.terraform.io/marvsmpb/subnet-marvs/aws"
#  version = "0.0.14"
#
#  subnet_vpc  = module.module_network_vpc.output_vpc_id
#  subnet_az   = "ap-southeast-1a"
#  subnet_cidr = "10.200.100.0/24"
#  subnet_tags = {
#    Name        = "${local.Projectname}-${local.Environment}-network-tgw-subnet1"
#    Environment = "${local.Environment}"
#  }
#}
#
#module "module_network_tgw_subnet2" {
#  source  = "app.terraform.io/marvsmpb/subnet-marvs/aws"
#  version = "0.0.14"
#
#  subnet_vpc  = module.module_network_vpc.output_vpc_id
#  subnet_az   = "ap-southeast-1b"
#  subnet_cidr = "10.200.200.0/24"
#  subnet_tags = {
#    Name        = "${local.Projectname}-${local.Environment}-network-tgw-subnet2"
#    Environment = "${local.Environment}"
#  }
#}
#
#
#
#module "module_network_rtb_pub" {
#  source  = "app.terraform.io/marvsmpb/rtb-marvs/aws"
#  version = "0.0.6"
#
#  rtb_vpc = module.module_network_vpc.output_vpc_id
#
#  #route_peering_bool                       = true
#  #route_peering                            = module.module_app_vpc_peering.output_peering_id
#  #route_vpc_peering_destination_cidr_block = "10.100.0.0/16"
#
#  route_internet_gateway_bool                   = true
#  route_internet_gateway                        = module.module_network_pub_subnet1.outputs_internet_gateway_id
#  route_internet_gateway_destination_cidr_block = "0.0.0.0/0"
#
#  rtb_tags = {
#    Name        = "${local.Projectname}-${local.Environment}-network-rtb"
#    Environment = "${local.Environment}"
#  }
#}
#
## TGW ROUTE
#resource "aws_route" "route_network_pub_subnet_to_tgw" {
#  route_table_id         = module.module_network_rtb_pub.outputs_rtb_id
#  destination_cidr_block = "10.100.0.0/16"
#  transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
#}
#
#
#module "module_network_rtb_tgw" {
#  source  = "app.terraform.io/marvsmpb/rtb-marvs/aws"
#  version = "0.0.6"
#
#  rtb_vpc = module.module_network_vpc.output_vpc_id
#
#  rtb_tags = {
#    Name        = "${local.Projectname}-${local.Environment}-tgw-rtb"
#    Environment = "${local.Environment}"
#  }
#}
#
## TGW ROUTE
#resource "aws_route" "route_network_tgw_subnet_to_tgw" {
#  route_table_id         = module.module_network_rtb_tgw.outputs_rtb_id
#  destination_cidr_block = "10.100.0.0/16"
#  transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
#}
#
#
#resource "aws_route_table_association" "rtb_network_assoc_public_subnet1" {
#  subnet_id      = module.module_network_pub_subnet1.outputs_subnet_id
#  route_table_id = module.module_network_rtb_pub.outputs_rtb_id
#}
#
#resource "aws_route_table_association" "rtb_network_assoc_public_subnet2" {
#  subnet_id      = module.module_network_pub_subnet2.outputs_subnet_id
#  route_table_id = module.module_network_rtb_pub.outputs_rtb_id
#}
#
#resource "aws_route_table_association" "rtb_network_assoc_tgw_subnet1" {
#  subnet_id      = module.module_network_tgw_subnet1.outputs_subnet_id
#  route_table_id = module.module_network_rtb_tgw.outputs_rtb_id
#}
#
#resource "aws_route_table_association" "rtb_network_assoc_tgw_subnet2" {
#  subnet_id      = module.module_network_tgw_subnet2.outputs_subnet_id
#  route_table_id = module.module_network_rtb_tgw.outputs_rtb_id
#}








#module "module_network_vpc_peering" {
#  source  = "app.terraform.io/marvsmpb/vpc-peering-accepter-marvs/aws"
#  version = "0.0.6"
#
#  peering_connection_id = module.module_app_vpc_peering.output_peering_id
#  peer_tags = {
#    Name        = "${local.Projectname}-${local.Environment}-network-peering"
#    Environment = "${local.Environment}"
#  }
#}



