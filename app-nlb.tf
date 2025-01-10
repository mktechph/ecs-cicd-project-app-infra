resource "aws_lb" "app-nlb" {
  name               = "ecs-app-nlb"
  internal           = true
  load_balancer_type = "network"
  subnets            = [module.module_app_subnet_nlb1.outputs_subnet_id, module.module_app_subnet_nlb2.outputs_subnet_id]
  security_groups    = [aws_security_group.sg_allow_all.id]

  enable_deletion_protection = false

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

resource "aws_lb_target_group_attachment" "app-nlb-target-group-attachment" {
  target_group_arn = aws_lb_target_group.app-nlb-target-group.arn
  target_id        = aws_lb.app-alb.arn
  port             = 80
}