resource "aws_security_group" "sg_alb" {
  name        = "sg_alb"
  description = "Security Group for ALB"
  vpc_id      = module.module_app_vpc.output_vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0", "0.0.0.0/0"]
    #cidr_blocks = ["10.100.30.101/32", "10.100.40.101/32"]
    #security_groups = [aws_security_group.sg_nlb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "sg_nlb" {
  name        = "sg_nlb"
  description = "Security Group for NLB"
  vpc_id      = module.module_app_vpc.output_vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.200.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "sg_ecs" {
  name        = "sg_ecs"
  description = "Security Group for ECS"
  vpc_id      = module.module_app_vpc.output_vpc_id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_security_group" "sg_allow_all" {
  name        = "sg_allow_all"
  description = "Security Group to allow all."
  vpc_id      = module.module_app_vpc.output_vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#resource "aws_security_group" "sg_allow_all" {
#  name        = "allow_all"
#  description = "Allow All traffic."
#  vpc_id      = module.module_app_vpc.output_vpc_id
#}
#
#
#resource "aws_vpc_security_group_ingress_rule" "ingress_allow_all" {
#  security_group_id = aws_security_group.sg_allow_all.id
#  cidr_ipv4         = "0.0.0.0/0"
#  from_port         = 0
#  to_port           = 0
#  ip_protocol       = "-1"
#}
#
#resource "aws_vpc_security_group_egress_rule" "egress_allow_all" {
#  security_group_id = aws_security_group.sg_allow_all.id
#  cidr_ipv4         = "0.0.0.0/0"
#  from_port         = 0
#  to_port           = 0
#  ip_protocol       = "-1"
#}




resource "aws_security_group" "sg_service" {
  name        = "allow_alb"
  description = "Allow ALB traffic."
  vpc_id      = module.module_app_vpc.output_vpc_id
}


## NETWORK ##

resource "aws_security_group" "sg_network_alb" {
  name        = "sg_network_alb"
  description = "Security Group for Public  ALB"
  vpc_id      = module.module_network_vpc.output_vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}