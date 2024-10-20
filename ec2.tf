
# ============================WEB TIER=================================

resource "aws_launch_template" "web_launch_template" {
  name                    = "web_launch_template"
  image_id                = data.aws_ami.ubuntu.id
  instance_type           = var.instance_type
  disable_api_stop        = true
  disable_api_termination = true
  key_name                = var.key_name

  # iam_instance_profile {
  #   name = aws_iam_instance_profile.ssm_cloudwatch_profile.name
  # }

  monitoring {
    enabled = true
  }

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.web_security_group.id]
    subnet_id                   = aws_subnet.public_subnet[0].id
  }

  placement {
    availability_zone = var.availability_zones[0]
  }

  tags = {
    Name = "web_launch_template"
  }
  block_device_mappings {
    device_name = "/dev/xda"

    ebs {
      volume_size = 10 # Size in GiB
      volume_type = "gp2"
    }
  }
  user_data = filebase64("${path.module}/scripts/user_data.sh")

}

resource "aws_autoscaling_group" "skywardops-site" {
  desired_capacity          = 1
  min_size                  = 1
  max_size                  = 2
  health_check_type         = "EC2"
  health_check_grace_period = 800
  vpc_zone_identifier       = [aws_subnet.public_subnet[0].id, aws_subnet.public_subnet[1].id]

  launch_template {
    id      = aws_launch_template.web_launch_template.id
    version = aws_launch_template.web_launch_template.latest_version
  }

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 80
      skip_matching          = true
    }
    triggers = ["launch_template"]
  }

  lifecycle {
    ignore_changes = all
  }

  tag {
    key                 = "Name"
    value               = "web_launch_template-asg"
    propagate_at_launch = true
  }
}

resource "aws_security_group" "web_security_group" {
  name        = "ec2 security group"
  description = "Allow HTTP traffic"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    description = "HTTPS"
    from_port   = 442
    to_port     = 442
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
  }
}


# ============================APP TIER=================================

# resource "aws_launch_template" "app_launch_template" {
#   name                    = "app_launch_template"
#   image_id                = data.aws_ami.ubuntu.id
#   instance_type           = var.instance_type
#   disable_api_stop        = true
#   disable_api_termination = true
#   key_name                = var.key_name

#   # iam_instance_profile {
#   #   name = aws_iam_instance_profile.ssm_cloudwatch_profile.name
#   # }

#   monitoring {
#     enabled = true
#   }

#   network_interfaces {
#     associate_public_ip_address = true
#     security_groups             = [aws_security_group.app_security_group.id]
#     subnet_id                   = aws_subnet.public_subnet[0].id
#   }

#   placement {
#     availability_zone = var.availability_zones[0]
#   }

#   tags = {
#     Name = "web_launch_template"
#   }
#   block_device_mappings {
#     device_name = "/dev/xda"

#     ebs {
#       volume_size = 10 # Size in GiB
#       volume_type = "gp2"
#     }
#   }
#   user_data = filebase64("${path.module}/scripts/user_data.sh")

# }

# resource "aws_autoscaling_group" "skywardops-site" {
#   desired_capacity          = 1
#   min_size                  = 1
#   max_size                  = 2
#   health_check_type         = "EC2"
#   health_check_grace_period = 800
#   vpc_zone_identifier       = [aws_subnet.public_subnet[0].id, aws_subnet.public_subnet[1].id]

#   launch_template {
#     id      = aws_launch_template.web_launch_template.id
#     version = aws_launch_template.web_launch_template.latest_version
#   }

#   instance_refresh {
#     strategy = "Rolling"
#     preferences {
#       min_healthy_percentage = 80
#       skip_matching          = true
#     }
#     triggers = ["launch_template"]
#   }

#   lifecycle {
#     ignore_changes = all
#   }

#   tag {
#     key                 = "Name"
#     value               = "web_launch_template-asg"
#     propagate_at_launch = true
#   }
# }

# resource "aws_security_group" "web_security_group" {
#   name        = "ec2 security group"
#   description = "Allow HTTP traffic"
#   vpc_id      = aws_vpc.main_vpc.id

#   ingress {
#     description = "HTTPS"
#     from_port   = 442
#     to_port     = 442
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   ingress {
#     description = "HTTP"
#     from_port   = 80
#     to_port     = 80
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   ingress {
#     description = "SSH"
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   egress {
#     cidr_blocks = ["0.0.0.0/0"]
#     from_port   = 0
#     protocol    = "-1"
#     to_port     = 0
#   }
# }

# resource "aws_instance" "web" {
#   count                       = var.instance_number
#   vpc_security_group_ids      = [aws_security_group.web_security_group.id]
#   ami                         = data.aws_ami.ubuntu.id
#   instance_type               = var.instance_type
#   key_name                    = aws_key_pair.my-key-pair.key_name
#   subnet_id                   = aws_subnet.public_subnet.id
#   associate_public_ip_address = true

#   tags = {
#     Name = "ansible_test_${count.index + 1}"
#   }
# }

# resource "tls_private_key" "private-key" {
#   algorithm = "RSA"
#   rsa_bits  = 4096
# }

# resource "aws_key_pair" "my-key-pair" {
#   key_name   = "ansible_key"
#   public_key = tls_private_key.private-key.public_key_openssh
# }
