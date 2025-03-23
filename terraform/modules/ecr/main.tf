# resource "aws_ecr_repository" "test" {
#   name = var.ecr_repository_name
# }


# data "aws_iam_instance_profile" "ecs_profile" {
#   name = "vj-ecs-ec2-1"  # Use the existing instance profile name
# }



# resource "aws_instance" "ecs_instance" {
#   ami                         = "ami-059601b8419c53014"  # latest ECS-optimized AMI
#   instance_type               = "t2.micro"
#   subnet_id                   = var.subnet
#   vpc_security_group_ids      = [var.sg_id]
#   iam_instance_profile        = data.aws_iam_instance_profile.ecs_profile.name
#   associate_public_ip_address = true
#   key_name                    = "vj-test"   # <-- Add this line to attach the key pair!

#   user_data = <<-EOF
#     #!/bin/bash
#     echo ECS_CLUSTER=${var.cluster} >> /etc/ecs/ecs.config
#     yum update -y
#     systemctl restart ecs
#   EOF

#   tags = {
#     Name = "ecs-instance"
#   }
# }

# resource "aws_ecs_task_definition" "my_node_app_task" {
#   family                   = "my-node-app-task"
#   execution_role_arn       = var.ecs_execution_role_arn
#   task_role_arn            = var.ecs_task_role_arn
#   network_mode             = "bridge"  # Using bridge mode for EC2
#   requires_compatibilities = ["EC2"]   # Using EC2 compatibility
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
#           containerPort = 3000
#           hostPort      = 0
#         }
#       ]
#     }
#   ])
#   depends_on = [aws_ecr_repository.test]
# }



# resource "aws_ecs_service" "my_service" {
#   name            = var.ecs_service_name
#   cluster         = var.cluster
#   task_definition = aws_ecs_task_definition.my_node_app_task.arn
#   desired_count   = 1
  

#   depends_on = [aws_ecs_task_definition.my_node_app_task, aws_instance.ecs_instance]
# }






# resource "aws_ecs_cluster" "ecs_cluster" {
#   name = var.cluster  # Make sure var.cluster is the cluster name
# }

resource "aws_ecr_repository" "test" {
  name = var.ecr_repository_name
}

data "aws_iam_instance_profile" "ecs_profile" {
  name = "vj-ecs-ec2-1"
}

resource "aws_instance" "ecs_instance" {
  ami                         = "ami-059601b8419c53014"  # Latest ECS-optimized AMI
  instance_type               = "t2.micro"
  subnet_id                   = var.subnet
  vpc_security_group_ids      = [var.sg_id]
  iam_instance_profile        = data.aws_iam_instance_profile.ecs_profile.name
  associate_public_ip_address = true
  key_name                    = "vj-test"

  user_data = <<-EOF
    #!/bin/bash
    echo "ECS_CLUSTER=${var.cluster}" >> /etc/ecs/ecs.config
    systemctl enable --now ecs
  EOF


  tags = {
    Name = "ecs-instance"
  }
}

resource "aws_ecs_task_definition" "my_node_app_task" {
  family                   = "my-node-app-task"
  execution_role_arn       = var.ecs_execution_role_arn
  task_role_arn            = var.ecs_task_role_arn
  network_mode             = "bridge"
  requires_compatibilities = ["EC2"]
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
          hostPort      = 0
        }
      ]
    }
  ])

  depends_on = [aws_ecr_repository.test]
}

resource "aws_ecs_service" "my_service" {
  name            = var.ecs_service_name
  cluster         =var.ccs #module.ecs.aws_ecs_cluster_name
  task_definition = aws_ecs_task_definition.my_node_app_task.arn
  desired_count   = 1

  depends_on = [aws_ecs_task_definition.my_node_app_task, aws_instance.ecs_instance]
}
