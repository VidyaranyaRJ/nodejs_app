# variable "ecr_repository_name" {
#   type        = string
# }

# variable "ecs_service_name" {
#   type        = string
# }


# variable "ecs_execution_role_arn" {
#   description = "The ARN of the ECS execution role"
#   type        = string
# }

# variable "ecs_task_role_arn" {
#   description = "The ARN of the ECS task role"
#   type        = string
# }


# variable "subnet" {
#   type        = string
# }

# variable "sg_id" {
#   type        = string
# }


# variable "cluster" {
#   description = "The ECS cluster name"
#   type        = string
# }


# variable "ccs" {
#   type        = string
# }

# variable "ecs_cluster_name" {
#   type        = string
# }


variable "ecs_cluster_name" {
  type = string
  default = "my-ecs-cluster"
}

variable "ecs_execution_name" {
  type = string
  default = "ecs_execution_role"
}

variable "ecs_task_name" {
  type = string
  default = "ecs_task_role"
}

variable "ecs_service_name" {
  type = string
  default = "my-ecs-service"
}

variable "ecr_repository_name" {
  type = string
  default = "my-node-app"
}

variable "sg_name" {
  type = string
  default = "ecs_sg"
}

variable "subnet" {
  type = string
  description = "Subnet ID to launch instances"
}

variable "sg_id" {
  type = string
  description = "Security group ID"
}

variable "ecs_execution_role_arn" {
  type = string
  description = "ARN of ECS execution role"
}

variable "ecs_task_role_arn" {
  type = string
  description = "ARN of ECS task role"
}
