output "cluster_name" {
  value = aws_eks_cluster.demo_workshop.name
}

output "cluster_endpoint" {
  value = aws_eks_cluster.demo_workshop.endpoint
}

output "cluster_region" {
  value = var.region
}
