resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "my-node-js-vpc"
  }
}


resource "aws_subnet" "my_subnet" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-2a" 
  map_public_ip_on_launch = true
  tags = {
    Name = "my-subnet-node-js"
  }
  depends_on = [  aws_vpc.my_vpc ]
}


resource "aws_internet_gateway" "my_gateway" {
  vpc_id = aws_vpc.my_vpc.id
  depends_on = [  aws_vpc.my_vpc ]
}


resource "aws_route_table" "my_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_gateway.id
  }
  depends_on = [  aws_vpc.my_vpc, aws_internet_gateway.my_gateway ]
}

resource "aws_route_table_association" "public_association" {
  subnet_id      = aws_subnet.my_subnet.id
  route_table_id = aws_route_table.my_route_table.id
}


resource "aws_security_group" "ecs_security_group" {
  name        = var.sg_name
  description = "Allow inbound traffic to ECS tasks"
  vpc_id      = aws_vpc.my_vpc.id  


  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = "-1" 
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  depends_on = [ aws_vpc.my_vpc ]
}
