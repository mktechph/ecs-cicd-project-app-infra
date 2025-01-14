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


resource "aws_lb_listener" "network-alb-listener-http" {
  depends_on        = [aws_lb.network-alb]
  load_balancer_arn = aws_lb.network-alb.arn
  port              = "80"
  protocol          = "HTTP"
  #ssl_policy        = "ELBSecurityPolicy-2016-08"
  #certificate_arn   = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.network-alb-target-group-api.arn
  }
}

resource "aws_lb_listener" "network-alb-listener-https" {
  depends_on        = [aws_lb.network-alb]
  load_balancer_arn = aws_lb.network-alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = "arn:aws:acm:ap-southeast-1:015594108990:certificate/469df146-5d9a-43cc-962e-0fad057f79f6" # api certificate

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.network-alb-target-group-api.arn
  }
}

resource "aws_lb_listener_rule" "network-alb-listener-rule-fe" {
  depends_on   = [aws_lb_listener.network-alb-listener-https]
  listener_arn = aws_lb_listener.network-alb-listener-https.arn
  priority     = 2

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.network-alb-target-group-fe.arn
  }

  condition {
    host_header {
      values = ["fe.mktechph.cloud"]
    }
  }
}

resource "aws_lb_listener_rule" "network-alb-listener-rule-oauth" {
  depends_on   = [aws_lb_listener.network-alb-listener-https]
  listener_arn = aws_lb_listener.network-alb-listener-https.arn
  priority     = 3

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.network-alb-target-group-oauth.arn
  }

  condition {
    host_header {
      values = ["oauth.mktechph.cloud"]
    }
  }
}

resource "aws_lb_listener_rule" "network-alb-listener-rule-api" {
  depends_on   = [aws_lb_listener.network-alb-listener-https]
  listener_arn = aws_lb_listener.network-alb-listener-https.arn
  priority     = 1

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.network-alb-target-group-api.arn
  }

  condition {
    host_header {
      values = ["api.mktechph.cloud"]
    }
  }
}


resource "aws_alb_target_group" "network-alb-target-group-fe" {
  name        = "ecs-target-group-network-fe"
  target_type = "ip"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.module_network_vpc.output_vpc_id

  health_check {
    healthy_threshold   = "2"
    unhealthy_threshold = "2"
    interval            = "30"
    path                = "/"
    timeout             = 5
    matcher             = 200
    protocol            = "HTTP"
  }
}

resource "aws_alb_target_group" "network-alb-target-group-oauth" {
  name        = "ecs-target-group-network-oauth"
  target_type = "ip"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.module_network_vpc.output_vpc_id

  health_check {
    healthy_threshold   = "2"
    unhealthy_threshold = "2"
    interval            = "30"
    path                = "/"
    timeout             = 5
    matcher             = 200
    protocol            = "HTTP"
  }
}

resource "aws_alb_target_group" "network-alb-target-group-api" {
  name        = "ecs-target-group-network-api"
  target_type = "ip"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.module_network_vpc.output_vpc_id

  health_check {
    healthy_threshold   = "2"
    unhealthy_threshold = "2"
    interval            = "30"
    path                = "/"
    timeout             = 5
    matcher             = 200
    protocol            = "HTTP"
  }
}



resource "aws_lb_listener_certificate" "network-alb-listener-cert-fe" {
  listener_arn    = aws_lb_listener.network-alb-listener-https.arn
  certificate_arn = "arn:aws:acm:ap-southeast-1:015594108990:certificate/3e017404-67e6-409c-a023-a189e316da05"
}

resource "aws_lb_listener_certificate" "network-alb-listener-cert-oauth" {
  listener_arn    = aws_lb_listener.network-alb-listener-https.arn
  certificate_arn = "arn:aws:acm:ap-southeast-1:015594108990:certificate/2e00f8ff-6b84-45ef-930a-a2d6a3667a2b"
}

resource "aws_lb_listener_certificate" "network-alb-listener-cert-api" {
  listener_arn    = aws_lb_listener.network-alb-listener-https.arn
  certificate_arn = "arn:aws:acm:ap-southeast-1:015594108990:certificate/469df146-5d9a-43cc-962e-0fad057f79f6"
}



resource "aws_lb_target_group_attachment" "network-alb-subnet1-target-group-attachment-fe" {
  target_group_arn  = aws_alb_target_group.network-alb-target-group-fe.arn
  availability_zone = "ap-southeast-1a"
  target_id         = "10.100.30.101"
  port              = 80
}

resource "aws_lb_target_group_attachment" "network-alb-subnet2-target-group-attachment-fe" {
  target_group_arn  = aws_alb_target_group.network-alb-target-group-fe.arn
  availability_zone = "ap-southeast-1b"
  target_id         = "10.100.40.101"
  port              = 80
}

resource "aws_lb_target_group_attachment" "network-alb-subnet1-target-group-attachment-oauth" {
  target_group_arn  = aws_alb_target_group.network-alb-target-group-oauth.arn
  availability_zone = "ap-southeast-1a"
  target_id         = "10.100.30.101"
  port              = 80
}

resource "aws_lb_target_group_attachment" "network-alb-subnet2-target-group-attachment-oauth" {
  target_group_arn  = aws_alb_target_group.network-alb-target-group-oauth.arn
  availability_zone = "ap-southeast-1b"
  target_id         = "10.100.40.101"
  port              = 80
}

resource "aws_lb_target_group_attachment" "network-alb-subnet1-target-group-attachment-api" {
  target_group_arn  = aws_alb_target_group.network-alb-target-group-api.arn
  availability_zone = "ap-southeast-1a"
  target_id         = "10.100.30.101"
  port              = 80
}

resource "aws_lb_target_group_attachment" "network-alb-subnet2-target-group-attachment-api" {
  target_group_arn  = aws_alb_target_group.network-alb-target-group-api.arn
  availability_zone = "ap-southeast-1b"
  target_id         = "10.100.40.101"
  port              = 80
}