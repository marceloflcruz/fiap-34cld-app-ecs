provider "aws" {
  region = "us-east-1" # Replace with your preferred AWS region
}

resource "aws_ecs_cluster" "app_cluster" {
  name = "my-python-app-cluster"
}

resource "aws_launch_template" "ecs_launch_template" {
  name          = "ecs-launch-template"
  image_id      = "ami-00510a0be518b7bcf" # Replace with ECS-optimized AMI ID
  instance_type = "t2.micro"

  iam_instance_profile {
    name = aws_iam_instance_profile.ecs_instance_profile.name
  }

  network_interfaces {
    security_groups = [aws_security_group.ecs_sg.id]
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash
    echo ECS_CLUSTER=${aws_ecs_cluster.app_cluster.name} >> /etc/ecs/ecs.config
  EOF
  )
}


resource "aws_autoscaling_group" "ecs_asg" {
  launch_template {
    id      = aws_launch_template.ecs_launch_template.id
    version = "$Latest"
  }
  min_size            = 1
  max_size            = 2
  desired_capacity    = 1
  vpc_zone_identifier = ["subnet-0afc07826f7018f34"] # Replace with your subnet ID
}

resource "aws_iam_role" "ecs_instance_role" {
  name = "ecs-instance-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_instance_profile" "ecs_instance_profile" {
  name = "ecs-instance-profile"
  role = aws_iam_role.ecs_instance_role.name
}

resource "aws_security_group" "ecs_sg" {
  name        = "fiap-ecs-sg"
  description = "Allow inbound traffic for ECS services"
  vpc_id      = "vpc-0ccf4f582dae3892f"

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_ecr_repository" "app_repository" {
  name = "my-python-app"
}

resource "aws_ecs_task_definition" "app_task" {
  family                   = "my-python-app-task"
  network_mode             = "bridge"
  requires_compatibilities = ["EC2"]
  execution_role_arn       = aws_iam_role.ecs_instance_role.arn
  memory                   = "512"
  cpu                      = "256"

  container_definitions = jsonencode([
    {
      name  = "my-python-app"
      image = "${aws_ecr_repository.app_repository.repository_url}:latest"
      essential = true
      portMappings = [
        {
          containerPort = 5000
          hostPort      = 5000
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "app_service" {
  name            = "my-python-app-service"
  cluster         = aws_ecs_cluster.app_cluster.id
  task_definition = aws_ecs_task_definition.app_task.arn
  desired_count   = 1
}
