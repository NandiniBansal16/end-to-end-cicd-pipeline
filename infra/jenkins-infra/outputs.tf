output "jenkins_master_public_ip" {
  description = "Public IP of Jenkins Master — use this to access Jenkins UI at :8080"
  value       = aws_instance.jenkins_master.public_ip
}

output "jenkins_master_private_ip" {
  description = "Private IP of Jenkins Master — used for agent-to-master communication"
  value       = aws_instance.jenkins_master.private_ip
}

output "jenkins_agent_public_ip" {
  description = "Public IP of Jenkins Agent — used for SSH and Ansible"
  value       = aws_instance.jenkins_agent.public_ip
}

output "jenkins_agent_private_ip" {
  description = "Private IP of Jenkins Agent"
  value       = aws_instance.jenkins_agent.private_ip
}

output "vpc_id" {
  description = "VPC ID — you will need this for EKS setup in Step 10"
  value       = aws_vpc.main.id
}

output "subnet_id" {
  description = "Subnet ID — you will need this for EKS setup in Step 10"
  value       = aws_subnet.public.id
}

output "jenkins_ui_url" {
  description = "Open this URL in your browser after Jenkins installs"
  value       = "http://${aws_instance.jenkins_master.public_ip}:8080"
}
