resource "aws_ecs_cluster" "ecs-cluster-fe-oauth" {
  name = "ecs-fe-oauth"

  setting {
    name  = "containerInsights"
    value = "enhanced"
  }
}


resource "aws_ecs_service" "ecs-service-fe" {
  name            = "ecs-service-fe"
  cluster         = aws_ecs_cluster.ecs-cluster-fe-oauth.id
  task_definition = aws_ecs_task_definition.ecs-task.arn
  desired_count   = 2
  launch_type     = "EC2"
  #iam_role        = aws_iam_role.foo.arn
  #depends_on      = [aws_iam_role_policy.foo]



  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  deployment_controller {
    type = "ECS"
  }

  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100


  load_balancer {
    #target_group_arn = aws_lb_target_group.foo.arn
    container_name = "ecs-fe"
    container_port = 80
  }

  network_configuration {
    subnets = [module.module_app_subnet1.outputs_subnet_id, module.module_app_subnet2.outputs_subnet_id]
    #security_groups = []
    assign_public_ip = false
  }

}

resource "aws_ecs_task_definition" "ecs-task" {
  family = "ecs-task"
  container_definitions = jsonencode([
    {
      name      = "ecs-task"
      image     = "public.ecr.aws/nginx/nginx:stable-perl"
      cpu       = 1
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
    }
  ])

  requires_compatibilities = ["EC2"]
  #execution_role_arn
  network_mode = "awsvpc"


}

