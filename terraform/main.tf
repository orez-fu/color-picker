provider "aws" {
  region = "us-east-2"
}

resource "aws_key_pair" "terraform_key" {
  key_name   = "${var.prefix}-terraform"
  public_key = file("files/terraform-key.pub")
}

resource "aws_instance" "jenkins_instance" {
  ami                    = "ami-07b36ea9852e986ad"
  instance_type          = "t2.small"
  key_name               = aws_key_pair.terraform_key.key_name
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]
  user_data              = file("files/install_docker.sh")

  tags = {
    Name = "${var.prefix} Jenkins Server"
  }
}

resource "aws_instance" "k8s_instance" {
  ami                    = "ami-07b36ea9852e986ad"
  instance_type          = "t2.small"
  key_name               = aws_key_pair.terraform_key.key_name
  vpc_security_group_ids = [aws_security_group.k8s_sg.id]
  user_data              = file("files/setup_kubernetes.sh")

  user_data_replace_on_change = true

  tags = {
    Name = "${var.prefix} Kubernetes Node"
  }
}

# Security Groups & Rules
resource "aws_security_group" "jenkins_sg" {
  name = "${var.prefix}_jenkins_sg"

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
  name = "${var.prefix}_k8s_sg"

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
resource "aws_security_group_rule" "k8s_node_port_sgr" {
  type              = "ingress"
  from_port         = 30000
  to_port           = 32767
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.k8s_sg.id

}
