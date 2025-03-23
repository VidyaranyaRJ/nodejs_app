resource "aws_ecr_repository" "test" {
  name = var.ecr_repository_name
}


data "aws_iam_instance_profile" "ecs_profile" {
  name = "vj-ecs-ec2-1"  # Use the existing instance profile name
}


resource "aws_instance" "ecs_instance" {
  ami                    = "ami-0d0f28110d16ee7d6" # Use an ECS-optimized AMI for your region
  instance_type          = "t2.micro"
  subnet_id              = var.subnet
  vpc_security_group_ids = [var.sg_id]
  iam_instance_profile   = data.aws_iam_instance_profile.ecs_profile.name  # Correct reference

  user_data = <<-EOF
    #!/bin/bash
    echo ECS_CLUSTER=${var.cluster} >> /etc/ecs/ecs.config
    systemctl enable --now ecs
  EOF

  tags = {
    Name = "ecs-instance"
  }
}


# resource "aws_ecs_task_definition" "my_node_app_task" {
#   family                   = "my-node-app-task"
#   execution_role_arn       = var.ecs_execution_role_arn  # Reference the output from IAM module
#   task_role_arn            = var.ecs_task_role_arn  # Reference the output from IAM module
#   network_mode             = "awsvpc"
#   requires_compatibilities = ["FARGATE"]
#   cpu                      = "256"
#   memory                   = "512"
  
#   container_definitions = jsonencode([
#     {
#       name      = "my-node-app-container"
#       image     = "${aws_ecr_repository.test.repository_url}:latest"
#       cpu       = 256
#       memory    = 512
#       essential = true
#       portMappings = [
#         {
#           containerPort = 80
#           hostPort      = 80
#         }
#       ]
#     }
#   ])
#   depends_on = [ aws_ecr_repository.test ]
# }
resource "aws_ecs_task_definition" "my_node_app_task" {
  family                   = "my-node-app-task"
  execution_role_arn       = var.ecs_execution_role_arn
  task_role_arn            = var.ecs_task_role_arn
  network_mode             = "bridge"  # Using bridge mode for EC2
  requires_compatibilities = ["EC2"]   # Using EC2 compatibility
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
          containerPort = 3000
          hostPort      = 3000
        }
      ]
    }
  ])
  depends_on = [aws_ecr_repository.test]
}


# resource "aws_ecs_service" "my_service" {
#   name            = var.ecs_service_name
#   cluster         = var.cluster
#   task_definition = aws_ecs_task_definition.my_node_app_task.arn
#   desired_count   = 1
#   launch_type     = "FARGATE"

#   network_configuration {
#     subnets          = [var.subnet]  # Use the subnet ID from network module
#     assign_public_ip = true
#     security_groups = [var.sg_id]  # Use the SG ID from network module
#   }
#   depends_on = [ aws_ecs_task_definition.my_node_app_task ]
# }



resource "aws_ecs_service" "my_service" {
  name            = var.ecs_service_name
  cluster         = var.cluster
  task_definition = aws_ecs_task_definition.my_node_app_task.arn
  desired_count   = 1
  
  # No launch_type needed for EC2 
  # No capacity_provider_strategy needed for this simplified case
  
  depends_on = [aws_ecs_task_definition.my_node_app_task, aws_instance.ecs_instance]
}