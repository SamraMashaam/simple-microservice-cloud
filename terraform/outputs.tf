output "ec2_public_ip" {
  description = "Public IP of EC2 instance"
  value       = aws_instance.k8s_node.public_ip
}

output "ec2_instance_id" {
  description = "Instance ID"
  value       = aws_instance.k8s_node.id
}

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "ssh_command" {
  description = "SSH command to connect to instance"
  value       = "ssh -i ~/.ssh/id_rsa ubuntu@${aws_instance.k8s_node.public_ip}"
}
