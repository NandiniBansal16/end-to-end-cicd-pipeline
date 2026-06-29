variable "cluster_name" {
  default = "demo-workshop-eks"
}

variable "region" {
  default = "us-east-1"
}

variable "vpc_id" {
  default = "YOUR_VPC_ID"
}

variable "subnet_id_az1" {
  default = "SUBNET1"
  # ↑ Your subnet in us-east-1a
}

variable "subnet_id_az2" {
  default = "subnet2"
  # ↑ Your subnet in us-east-1b
}

# ─── NEW: SSH Key Pair for Node Access ─────────────────────────
variable "ssh_key_name" {
  description = "The name of the EC2 Key Pair to allow SSH access to the nodes"
  default     = "devops-cicd-eks-KP"
}
