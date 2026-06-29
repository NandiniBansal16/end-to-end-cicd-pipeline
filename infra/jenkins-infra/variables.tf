variable "region" {
  description = "AWS region where all resources will be created"
  default     = "us-east-1"     
}

variable "project_name" {
  description = "Name prefix used for all resources — use your project name"
  default     = "devops-cicd"   
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "subnet_cidr" {
  description = "CIDR block for the public subnet"
  default     = "10.0.1.0/24"
}

variable "availability_zone" {
  description = "AZ inside your region to launch instances"
  default     = "us-east-1a"   
}

variable "ami_id" {
  description = "Ubuntu 22.04 LTS AMI ID for your region"
  default     = "ami-0b6d9d3d33ba97d99"
}

variable "key_pair_name" {
  description = "Name of your AWS EC2 Key Pair (the .pem file you downloaded)"
  default     = "kub-server-KP"   
}

variable "your_ip" {
  description = "Your public IP address with /32 — for SSH access. Find it at whatismyip.com"
  default     = "54.162.172.70/32"
}
