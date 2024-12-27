module "module_app_ecs_ecr_subnet1_endpoint" {
  source  = "app.terraform.io/marvsmpb/vpc-endpoint-ecs-ecr-marvs/aws"
  version = "0.0.6"

  vpc_id = module.module_app_vpc.output_vpc_id

  ecs_endpoint_subnet_id           = [module.module_app_subnet1.outputs_subnet_id]
  ecs_agent_endpoint_subnet_id     = [module.module_app_subnet1.outputs_subnet_id]
  ecs_telemetry_endpoint_subnet_id = [module.module_app_subnet1.outputs_subnet_id]
  ecr_api_endpoint_subnet_id       = [module.module_app_subnet1.outputs_subnet_id]
  ecr_dkr_endpoint_subnet_id       = [module.module_app_subnet1.outputs_subnet_id]

  endpoint_tags = {
    Name        = "${local.Projectname}-${local.Environment}-app-ecs-ecr-endpoint-subnet1-app1"
    Environment = "${local.Environment}"
  }
}

module "module_app_ecs_ecr_subnet2_endpoint" {
  source  = "app.terraform.io/marvsmpb/vpc-endpoint-ecs-ecr-marvs/aws"
  version = "0.0.6"

  vpc_id = module.module_app_vpc.output_vpc_id

  ecs_endpoint_subnet_id           = [module.module_app_subnet2.outputs_subnet_id]
  ecs_agent_endpoint_subnet_id     = [module.module_app_subnet2.outputs_subnet_id]
  ecs_telemetry_endpoint_subnet_id = [module.module_app_subnet2.outputs_subnet_id]
  ecr_api_endpoint_subnet_id       = [module.module_app_subnet2.outputs_subnet_id]
  ecr_dkr_endpoint_subnet_id       = [module.module_app_subnet2.outputs_subnet_id]

  endpoint_tags = {
    Name        = "${local.Projectname}-${local.Environment}-app-ecs-ecr-endpoint-subnet2-app1"
    Environment = "${local.Environment}"
  }
}