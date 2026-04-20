# Get latest Ubuntu 22.04 AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Create SSH key pair
resource "aws_key_pair" "deployer" {
  key_name   = var.ssh_key_name
  public_key = file("~/.ssh/id_rsa.pub")

  tags = {
    Name    = "${var.project_name}-key"
    Project = var.project_name
  }
}

# Create EC2 instance
resource "aws_instance" "k8s_node" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.k8s_node.id]
  key_name               = aws_key_pair.deployer.key_name

  root_block_device {
    volume_size = 30  # 30GB root volume
    volume_type = "gp3"
  }

  user_data = <<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y apt-transport-https ca-certificates curl software-properties-common
              EOF

  tags = {
    Name    = "${var.project_name}-k8s-node"
    Project = var.project_name
  }
}
