variable "ecr_repository_name" {
  type        = string
}

variable "ecs_service_name" {
  type        = string
}


variable "ecs_execution_role_arn" {
  description = "The ARN of the ECS execution role"
  type        = string
}

variable "ecs_task_role_arn" {
  description = "The ARN of the ECS task role"
  type        = string
}

variable "cluster" {
  type        = string
}
variable "subnet" {
  type        = string
}

variable "sg_id" {
  type        = string
}