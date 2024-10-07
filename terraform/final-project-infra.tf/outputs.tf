output "vpc_id" {
  value = module.vpc.vpc_id
}

output "eks_cluster_name" {
  value = module.eks.cluster_name
}
output "public_subnet_ids" {
  value = module.vpc.public_subnet_ids
}

