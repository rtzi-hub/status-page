resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  role_arn = var.eks_cluster_role_arn

  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = var.security_group_ids
  }

  tags = {
    Name    = "Y R EKS Cluster"
    Project = "TeamE"
  }
}

resource "aws_eks_node_group" "this" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = var.node_group_name
  node_role_arn   = var.eks_node_group_role_arn
  subnet_ids      = var.private_subnet_ids

  scaling_config {
    desired_size = var.desired_capacity
    max_size     = var.max_size
    min_size     = var.min_size
  }

  instance_types = [var.node_instance_type]

  ami_type = "AL2_x86_64"

  tags = {
    Name    = "Y R EKS Node Group"
    Project = "TeamE"
  }

  depends_on = [
    var.eks_worker_node_policy_attachment,
    var.eks_cni_policy_attachment,
    var.ecr_read_only_policy_attachment
  ]
}
