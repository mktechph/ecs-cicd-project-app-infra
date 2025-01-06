resource "aws_ecs_cluster" "ecs-cluster-fe-oauth" {
  name = "ecs-cicd-fe-oauth"

  setting {
    name  = "containerInsights"
    value = "enhanced"
  }
}

resource "aws_ecs_capacity_provider" "ecs-capacity-provider" {
  name = "capacity-provider-ecs-cicd"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.app-fe-autoscaling.arn
    managed_termination_protection = "DISABLED"

    managed_scaling {
      maximum_scaling_step_size = 5
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = 100
    }
  }
}

resource "aws_ecs_cluster_capacity_providers" "ecs-cluster-capacity-provider" {
  cluster_name = aws_ecs_cluster.ecs-cluster-fe-oauth.name

  capacity_providers = [aws_ecs_capacity_provider.ecs-capacity-provider.name]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = aws_ecs_capacity_provider.ecs-capacity-provider.name
  }
}

resource "aws_ecs_service" "ecs-service-fe" {
  name            = "ecs-service-fe"
  cluster         = aws_ecs_cluster.ecs-cluster-fe-oauth.id
  task_definition = aws_ecs_task_definition.ecs-task.arn
  desired_count   = 2
  #launch_type     = "EC2"
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
    target_group_arn = aws_alb_target_group.app-alb-fe-target-group.arn
    container_name   = "ecs-cicd-project-app-fe"
    container_port   = 80
  }
 
  network_configuration {
    subnets = [module.module_app_subnet1.outputs_subnet_id, module.module_app_subnet2.outputs_subnet_id]
    #security_groups = []
    assign_public_ip = false
  }

}

resource "aws_ecs_task_definition" "ecs-task" {
  family                   = "ecs-cicd-task-definition"
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]
  cpu                      = 256
  memory                   = 512


  container_definitions = jsonencode([
    {
      name      = "ecs-fe"
      image     = "public.ecr.aws/nginx/nginx:stable-perl"
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
    }
  ])

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }


  #execution_role_arn



}

