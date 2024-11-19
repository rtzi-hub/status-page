output "eks_cluster_role_arn" {
  value = aws_iam_role.eks_cluster_role.arn
}

output "eks_node_group_role_arn" {
  value = aws_iam_role.eks_node_group_role.arn
}

output "eks_cluster_policy_attachment" {
  value = aws_iam_role_policy_attachment.eks_cluster_policy.id
}

output "eks_worker_node_policy_attachment" {
  value = aws_iam_role_policy_attachment.eks_worker_node_policy.id
}

output "eks_cni_policy_attachment" {
  value = aws_iam_role_policy_attachment.eks_cni_policy.id
}

output "ecr_read_only_policy_attachment" {
  value = aws_iam_role_policy_attachment.ecr_read_only.id
}
