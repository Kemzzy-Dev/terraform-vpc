resource "tls_private_key" "private-key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "my-key-pair" {
  key_name   = "ansible_key"
  public_key = tls_private_key.private-key.public_key_openssh
}

resource "aws_security_group" "ec2_security_group" {
  name        = "ec2 security group"
  description = "Allow HTTP traffic"
  vpc_id      = aws_vpc.main_vpc.id

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

resource "aws_instance" "web" {
  count                       = var.instance_number
  vpc_security_group_ids      = [aws_security_group.ec2_security_group.id]
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.my-key-pair.key_name
  subnet_id                   = aws_subnet.public_subnet.id
  associate_public_ip_address = true

  tags = {
    Name = "ansible_test_${count.index + 1}"
  }
}
