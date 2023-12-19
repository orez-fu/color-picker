provider "aws" {
  region = "us-east-1"
  # access_key = "<your_access_key>"
  # secret_key = "<your_secret_key>"
  access_key = "AKIAWFGGBXVDJQTIMO66"
  secret_key = "7YjmBSGAAmvgM757fCon4TwEqbHScR4QQrA6zYbp"
}

resource "aws_key_pair" "terraform_key" {
  key_name   = "terraform-demo"
  public_key = file("files/terraform.pub")
}

resource "aws_instance" "jenkins_instance" {
  ami                    = "ami-06aa3f7caf3a30282"
  instance_type          = "t2.small"
  key_name               = aws_key_pair.terraform_key.key_name
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]
  user_data              = file("files/install_docker.sh")

  tags = {
    Name = "Jenkins Server"
  }
}

resource "aws_instance" "k8s_instance" {
  ami                    = "ami-06aa3f7caf3a30282"
  instance_type          = "t2.small"
  key_name               = aws_key_pair.terraform_key.key_name
  vpc_security_group_ids = [aws_security_group.k8s_sg.id]
  user_data              = file("files/setup_kubernetes.sh")

  user_data_replace_on_change = true

  tags = {
    Name = "Kubernetes Node"
  }
}

# Security Groups & Rules
resource "aws_security_group" "jenkins_sg" {
  name = "jenkins_sg"

  ingress {
    from_port   = 8080
    to_port     = 8080
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
resource "aws_security_group" "k8s_sg" {
  name = "k8s_sg"

  ingress {
    from_port   = 6443
    to_port     = 6443
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
resource "aws_security_group_rule" "jenkins_ssh_sgr" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.jenkins_sg.id
}
resource "aws_security_group_rule" "k8s_ssh_sgr" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.k8s_sg.id
}
