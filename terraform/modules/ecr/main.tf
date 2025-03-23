resource "aws_ecr_repository" "test" {
  name                 = var.ecr_repository_name
}




resource "aws_ecs_task_definition" "my_node_app_task" {
  family                   = "my-node-app-task"
  execution_role_arn       = var.ecs_execution_role_arn  # Reference the output from IAM module
  task_role_arn            = var.ecs_task_role_arn  # Reference the output from IAM module
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  
  container_definitions = jsonencode([
    {
      name      = "my-node-app-container"
      image     = "${aws_ecr_repository.test.repository_url}:latest"
      cpu       = 256
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
  depends_on = [ aws_ecr_repository.test ]
}



resource "aws_ecs_service" "my_service" {
  name            = var.ecs_service_name
  cluster         = var.cluster
  task_definition = aws_ecs_task_definition.my_node_app_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [var.subnet]  # Use the subnet ID from network module
    assign_public_ip = true
    security_groups = [var.sg_id]  # Use the SG ID from network module
  }
  depends_on = [ aws_ecs_task_definition.my_node_app_task ]
}



