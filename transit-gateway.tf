#resource "aws_ec2_transit_gateway" "tgw" {
#  description = "Transit Gateway"
#
#  default_route_table_association = "disable"
#  default_route_table_propagation = "disable"
#
#  tags = {
#    Name        = "${local.Projectname}-${local.Environment}-tgw"
#    Environment = "${local.Environment}"
#  }
#}
#
#
### NETWORK-VPC TGW SUBNETS ATTACHMENT
#resource "aws_ec2_transit_gateway_vpc_attachment" "tgw_attachment_network_vpc_tgw_subnets" {
#  subnet_ids         = [module.module_network_tgw_subnet1.outputs_subnet_id, module.module_network_tgw_subnet2.outputs_subnet_id]
#  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
#  vpc_id             = module.module_network_vpc.output_vpc_id
#
#  tags = {
#    Name        = "${local.Projectname}-${local.Environment}-network-vpc-tgw-subnets-attach"
#    Environment = "${local.Environment}"
#  }
#}
#
### APP-VPC TGW SUBNETS ATTACHMENT
#resource "aws_ec2_transit_gateway_vpc_attachment" "tgw_attachment_app_vpc_tgw_subnets" {
#  subnet_ids         = [module.module_app_tgw_subnet1.outputs_subnet_id, module.module_app_tgw_subnet2.outputs_subnet_id]
#  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
#  vpc_id             = module.module_app_vpc.output_vpc_id
#
#  tags = {
#    Name        = "${local.Projectname}-${local.Environment}-app-vpc-tgw-subnets-attach"
#    Environment = "${local.Environment}"
#  }
#}
#
#
### NETWORK-VPC ROUTE TABLE
#resource "aws_ec2_transit_gateway_route_table" "tgw_rtb_network" {
#  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
#
#  tags = {
#    Name        = "${local.Projectname}-${local.Environment}-tgw-rtb-network"
#    Environment = "${local.Environment}"
#  }
#}
### ROUTE TO APP-VPC
#resource "aws_ec2_transit_gateway_route" "tgw_route_to_app" {
#  destination_cidr_block         = "10.100.0.0/16"
#  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw_attachment_network_vpc_tgw_subnets.id
#  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw_rtb_network.id
#}
#
#
### APP-VPC ROUTE TABLE
#resource "aws_ec2_transit_gateway_route_table" "tgw_rtb_app" {
#  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
#
#  tags = {
#    Name        = "${local.Projectname}-${local.Environment}-tgw-rtb-app"
#    Environment = "${local.Environment}"
#  }
#}
### ROUTE TO NETWORK-VPC
#resource "aws_ec2_transit_gateway_route" "tgw_route_to_network" {
#  destination_cidr_block         = "0.0.0.0/0"
#  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw_attachment_app_vpc_tgw_subnets.id
#  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw_rtb_app.id
#}
#
### NETWORK VPC TGW ROUTE TABLE ASSOCIATION
#resource "aws_ec2_transit_gateway_route_table_association" "tgw_network_vpc_tgw_rtb_assoc" {
#  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw_attachment_network_vpc_tgw_subnets.id
#  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw_rtb_network.id
#}
#
### APP VPC TGW ROUTE TABLE ASSOCIATION
#resource "aws_ec2_transit_gateway_route_table_association" "tgw_app_vpc_tgw_rtb_assoc" {
#  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw_attachment_app_vpc_tgw_subnets.id
#  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw_rtb_app.id
#}