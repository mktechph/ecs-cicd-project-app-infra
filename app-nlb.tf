resource "aws_lb" "app-nlb" {
  name               = "ecs-app-nlb"
  internal           = true
  load_balancer_type = "network"
  #subnets            = [module.module_app_subnet_nlb1.outputs_subnet_id, module.module_app_subnet_nlb2.outputs_subnet_id]
  security_groups = [aws_security_group.sg_allow_all.id]

  enable_deletion_protection = false

  subnet_mapping {
    subnet_id            = module.module_app_subnet_nlb1.outputs_subnet_id
    private_ipv4_address = "10.100.30.1"
  }

  subnet_mapping {
    subnet_id            = module.module_app_subnet_nlb2.outputs_subnet_id
    private_ipv4_address = "10.100.40.1"
  }

  tags = {
    Name        = "${local.Projectname}-${local.Environment}-app-nlb"
    Environment = "${local.Environment}"
  }
}



resource "aws_lb_target_group" "app-nlb-target-group" {
  name        = "ecs-cicd-nlb-target-group"
  target_type = "alb"
  port        = 80
  protocol    = "TCP"
  vpc_id      = module.module_app_vpc.output_vpc_id

  health_check {
    healthy_threshold   = "5"
    unhealthy_threshold = "2"
    interval            = "30"
    path                = "/"
    timeout             = 5
    matcher             = 200
    protocol            = "HTTP"
  }
}


resource "aws_lb_listener" "nlb-listener-fe-oauth" {
  load_balancer_arn = aws_lb.app-nlb.arn
  port              = "80"
  protocol          = "TCP"
  #ssl_policy        = "ELBSecurityPolicy-2016-08"
  #certificate_arn   = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app-nlb-target-group.arn
  }

}





#locals {
#  app_nlb_eni_ips = [for eni in data.aws_network_interfaces.app_nlb_enis.network_interfaces : eni.private_ip]
#}

#data "aws_network_interfaces" "app_nlb_enis" {
#  #for_each = toset([aws_lb.app-nlb.arn_suffix])
#  filter {
#    name   = "description"
#    values = ["ELB net/ecs-app-nlb/*"]
#  }
#}