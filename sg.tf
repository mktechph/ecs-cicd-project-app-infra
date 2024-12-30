resource "aws_security_group" "sg_allow_all" {
  name        = "allow_all"
  description = "Allow All traffic."
  vpc_id      = module.module_app_vpc.output_vpc_id
}


resource "aws_vpc_security_group_ingress_rule" "ingress_allow_all" {
  security_group_id = aws_security_group.sg_allow_all.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 0
  to_port           = 0
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_egress_rule" "egress_allow_all" {
  security_group_id = aws_security_group.sg_allow_all.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 0
  to_port           = 0
  ip_protocol       = "-1"
}