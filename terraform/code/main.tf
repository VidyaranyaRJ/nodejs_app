terraform {
  backend "s3" {
    bucket         = "vj-test-ecr-79"  # Your newly created S3 bucket
    key            = "terraform.tfstate"  # Path to store the state file in S3
    region         = "us-east-2"  # Update if your bucket is in a different region
    encrypt        = true
  }
}


module "ecr" {
  source                                 = "../modules/ecr"
  ecs_cluster_name = var.ecs_cluster_name
  ecr_repository_name                    = var.ecr_repository_name
  ecs_service_name                       = var.ecs_service_name
  ecs_execution_role_arn                 = module.iam.ecs_execution_role_arn
  ecs_task_role_arn                      = module.iam.ecs_task_role_arn
  # cluster                                = module.ecs.ecs_cluster_name   # <== pass here
  subnet                                 = module.network.subnet_id
  sg_id                                  = module.network.security_group_id
  # ccs  = module.ecs.ecs_cluster_name
}


module "iam" {
  source                                 = "../modules/IAM"
  ecs_execution_name = var.ecs_execution_name
  ecs_task_name = var.ecs_task_name
}

module "network" {
  source                                 = "../modules/network"
  sg_name = var.sg_name
}

