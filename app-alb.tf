resource "aws_lb" "app-alb" {
  name               = "ecs-app-alb"
  internal           = true
  load_balancer_type = "application"
  #security_groups    = [aws_security_group.lb_sg.id]
  subnets = [module.module_app_subnet1.outputs_subnet_id, module.module_app_subnet2.outputs_subnet_id]

  enable_deletion_protection = false


  tags = {
    Name        = "${local.Projectname}-${local.Environment}-app-alb"
    Environment = "${local.Environment}"
  }
}



resource "aws_appautoscaling_target" "app-alb-fe-target-group" {
  max_capacity       = 4
  min_capacity       = 2
  resource_id        = "service/${aws_ecs_cluster.ecs-cluster-fe-oauth.name}/${aws_ecs_service.ecs-service-fe.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}



resource "aws_autoscaling_group" "app-fe-autoscaling" {
  name                      = "ecs-fe-autoscaling"
  max_size                  = 2
  min_size                  = 2
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = 2
  force_delete              = true
  vpc_zone_identifier       = [module.module_app_subnet1.outputs_subnet_id, module.module_app_subnet2.outputs_subnet_id]

  launch_template {
    id      = aws_launch_template.launch-template-ecs.id
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

#resource "aws_lb_target_group_attachment" "app-fe-attach-subnet1" {
#  target_group_arn = aws_lb_target_group.app-alb-fe-target-group.arn
#  target_id        = "10.100.100.0"
#  port             = 80
#}
#
#resource "aws_lb_target_group_attachment" "app-fe-attach-subnet2" {
#  target_group_arn = aws_lb_target_group.app-alb-fe-target-group.arn
#  target_id        = "10.100.200.0"
#  port             = 80
#}

resource "aws_lb_listener" "alb-listener-fe" {
  load_balancer_arn = aws_lb.app-alb.arn
  port              = "80"
  protocol          = "HTTP"
  #ssl_policy        = "ELBSecurityPolicy-2016-08"
  #certificate_arn   = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"

  default_action {
    type             = "forward"
    target_group_arn = aws_appautoscaling_target.app-alb-fe-target-group.arn
  }
}
