resource "aws_ecs_cluster" "test" {
  name = var.ecs_cluster_name
}

resource "aws_ecr_repository" "test" {
  name = var.ecr_repository_name
}

data "aws_iam_instance_profile" "ecs_profile" {
  name = "vj-ecs-ec2-1"
}

resource "aws_instance" "ecs_instance" {
  ami                         = "ami-0c3b809fcf2445b6a"
  instance_type               = "t2.micro"
  subnet_id                   = var.subnet
  vpc_security_group_ids      = [var.sg_id]
  iam_instance_profile        = data.aws_iam_instance_profile.ecs_profile.name
  associate_public_ip_address = true
  key_name                    = "vj-test"

  user_data = <<-EOF
    #!/bin/bash
    echo "ECS_CLUSTER=${aws_ecs_cluster.test.name}" >> /etc/ecs/ecs.config

    # Install Docker
    apt-get update
    apt-get install -y docker.io awscli
    systemctl enable docker
    systemctl start docker

    # Install ECS Agent
    docker run --name ecs-agent \
      --detach=true \
      --restart=always \
      --volume=/var/run/docker.sock:/var/run/docker.sock \
      --volume=/var/log/ecs/:/log \
      --volume=/var/lib/ecs/data:/data \
      --volume=/etc/ecs:/etc/ecs \
      --net=host \
      --env ECS_LOGFILE=/log/ecs-agent.log \
      --env ECS_LOGLEVEL=info \
      --env ECS_CLUSTER=${aws_ecs_cluster.test.name} \
      amazon/amazon-ecs-agent:latest
  EOF

  tags = {
    Name = "ecs-instance-ubuntu"
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
          hostPort      = 3000 
        }
      ]
    }
  ])

  depends_on = [aws_ecr_repository.test]
}

resource "aws_ecs_service" "my_service" {
  name            = var.ecs_service_name
  cluster         = aws_ecs_cluster.test.id
  task_definition = aws_ecs_task_definition.my_node_app_task.arn
  desired_count   = 1

  depends_on = [aws_ecs_task_definition.my_node_app_task, aws_instance.ecs_instance]
}
