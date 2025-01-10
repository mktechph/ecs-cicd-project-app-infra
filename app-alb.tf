resource "aws_lb" "app-alb" {
  name               = "ecs-app-alb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg_alb.id]
  subnets            = [module.module_app_subnet1.outputs_subnet_id, module.module_app_subnet2.outputs_subnet_id]

  enable_deletion_protection = false


  tags = {
    Name        = "${local.Projectname}-${local.Environment}-app-alb"
    Environment = "${local.Environment}"
  }
}

resource "aws_autoscaling_group" "app-autoscaling-fe-oauth" {
  name                      = "ecs-cicd-autoscaling-fe-oauth"
  max_size                  = 2
  min_size                  = 2
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = 2
  force_delete              = true
  vpc_zone_identifier       = [module.module_app_subnet1.outputs_subnet_id, module.module_app_subnet2.outputs_subnet_id]

  launch_template {
    id = aws_launch_template.ecs-cicd-launch-template.id
    #id      = "lt-0d10601275565fcb5"
    version = "$Latest"
  }

  instance_maintenance_policy {
    min_healthy_percentage = 90
    max_healthy_percentage = 120
  }

  timeouts {
    delete = "15m"
  }


}


resource "aws_lb_listener" "alb-listener-fe-oauth" {
  load_balancer_arn = aws_lb.app-alb.arn
  port              = "80"
  protocol          = "HTTP"
  #ssl_policy        = "ELBSecurityPolicy-2016-08"
  #certificate_arn   = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"

  #default_action {
  #  type             = "forward"
  #  target_group_arn = aws_alb_target_group.app-alb-fe-target-group.arn
  #}

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      status_code  = "404"
      message_body = "Page not found."
    }
  }
}

## FE ##

resource "aws_alb_target_group" "app-alb-fe-target-group" {
  name        = "ecs-cicd-fe-target-group"
  target_type = "ip"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.module_app_vpc.output_vpc_id

  health_check {
    healthy_threshold   = "2"
    unhealthy_threshold = "2"
    interval            = "30"
    path                = "/"
    timeout             = 5
    matcher             = 200
    protocol            = "HTTP"
  }

  #lifecycle {
  #  create_before_destroy = true
  #}
}


resource "aws_lb_listener_rule" "alb-listener-rule-fe" {
  listener_arn = aws_lb_listener.alb-listener-fe-oauth.arn
  priority     = 1

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.app-alb-fe-target-group.arn
  }

  condition {
    path_pattern {
      values = ["/"]
    }
  }
}



## OAUTH ##

resource "aws_alb_target_group" "app-alb-oauth-target-group" {
  name        = "ecs-cicd-oauth-target-group"
  target_type = "ip"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.module_app_vpc.output_vpc_id

  health_check {
    healthy_threshold   = "2"
    unhealthy_threshold = "2"
    interval            = "30"
    path                = "/oauth*"
    timeout             = 5
    matcher             = 200
    protocol            = "HTTP"
  }

  #lifecycle {
  #  create_before_destroy = true
  #}
}


resource "aws_lb_listener_rule" "alb-listener-rule-oauth" {
  listener_arn = aws_lb_listener.alb-listener-fe-oauth.arn
  priority     = 2

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.app-alb-oauth-target-group.arn
  }

  condition {
    path_pattern {
      values = ["/oauth*"]
    }
  }
}
