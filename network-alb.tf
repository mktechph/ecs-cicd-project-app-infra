resource "aws_lb" "network-alb" {
  name               = "ecs-network-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg_network_alb.id]
  subnets            = [module.module_network_pub_subnet1.outputs_subnet_id, module.module_network_pub_subnet2.outputs_subnet_id]

  enable_deletion_protection = false


  tags = {
    Name        = "${local.Projectname}-${local.Environment}-network-alb"
    Environment = "${local.Environment}"
  }
}


resource "aws_lb_listener" "network-alb-listener" {
  load_balancer_arn = aws_lb.network-alb.arn
  port              = "80"
  protocol          = "HTTP"
  #ssl_policy        = "ELBSecurityPolicy-2016-08"
  #certificate_arn   = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.app-alb-fe-target-group.arn
  }
}


resource "aws_alb_target_group" "network-alb-target-group" {
  name        = "ecs-cicd-network-target-group"
  target_type = "ip"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.module_network_vpc.output_vpc_id

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


resource "aws_lb_listener_rule" "network-alb-listener-rule" {
  listener_arn = aws_lb_listener.network-alb-listener.arn
  priority     = 1

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.network-alb-target-group.arn
  }

  condition {
    path_pattern {
      values = ["/"]
    }
  }
}



resource "aws_lb_target_group_attachment" "network-alb-subnet1-target-group-attachment" {
  target_group_arn  = aws_alb_target_group.network-alb-target-group.arn
  availability_zone = "ap-southeast-1a"
  target_id         = "10.100.30.1"
  port              = 80
}

resource "aws_lb_target_group_attachment" "network-alb-subnet2-target-group-attachment" {
  target_group_arn  = aws_alb_target_group.network-alb-target-group.arn
  availability_zone = "ap-southeast-1b"
  target_id         = "10.100.40.1"
  port              = 80
}