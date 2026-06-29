# ─── IAM Role for EKS Cluster Control Plane ────────────────────
resource "aws_iam_role" "eks_cluster_role" {
  name = "demo-workshop-eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

# ─── IAM Role for EKS Node Group ───────────────────────────────
resource "aws_iam_role" "eks_node_role" {
  name = "demo-workshop-eks-node-role"

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

resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "eks_ecr_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node_role.name
}

# ─── EKS Cluster ───────────────────────────────────────────────
resource "aws_eks_cluster" "demo_workshop" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids = [
      var.subnet_id_az1,
      var.subnet_id_az2
    ]
    endpoint_public_access = true
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy
  ]

  tags = {
    Name = var.cluster_name
  }
}

# ─── EKS Node Group ────────────────────────────────────────────
resource "aws_eks_node_group" "demo_workshop_nodes" {
  cluster_name    = aws_eks_cluster.demo_workshop.name
  node_group_name = "demo-workshop-nodes"
  node_role_arn   = aws_iam_role.eks_node_role.arn

  subnet_ids = [
    var.subnet_id_az1,
    var.subnet_id_az2
  ]

  instance_types = ["c7i-flex.large"]
  ami_type = "AL2023_x86_64_STANDARD"


  # ─── NEW: Remote Access Configuration ─────────────────────────
  remote_access {
    ec2_ssh_key = var.ssh_key_name
  }

  scaling_config {
    desired_size = 1
    min_size     = 1
    max_size     = 2
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.eks_ecr_policy,
  ]

  tags = {
    Name = "demo-workshop-nodes"
  }
}
