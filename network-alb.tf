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