# IAM Role for EKS Cluster
resource "aws_iam_role" "eks_cluster_role" {
  name_prefix = "y-r-eks-cluster-role-"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Effect = "Allow"
      },
    ]
  })

  tags = {
    Name    = "Y-R-EKS-Cluster-Role"
    Project = "TeamE"
  }
}

# Attach IAM Policy for EKS Cluster
resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# IAM Role for Node Group
resource "aws_iam_role" "eks_node_group_role" {
  name_prefix = "y-r-eks-node-group-role-"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Effect = "Allow"
      },
    ]
  })

  tags = {
    Name    = "Y-R-EKS-Node-Group-Role"
    Project = "TeamE"
  }
}

# Attach Policies for Node Group Role
resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  role       = aws_iam_role.eks_node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  depends_on = [aws_iam_role.eks_node_group_role]
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  role       = aws_iam_role.eks_node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  depends_on = [aws_iam_role.eks_node_group_role]
}

resource "aws_iam_role_policy_attachment" "ecr_read_only" {
  role       = aws_iam_role.eks_node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  depends_on = [aws_iam_role.eks_node_group_role]
}

# ELB Management Policy
resource "aws_iam_policy" "elb_policy" {
  name_prefix  = "y-r-elb-management-policy-"
  description  = "IAM policy for managing Elastic Load Balancer"
  policy       = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "elasticloadbalancing:*",
          "ec2:DetachNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface"
        ],
        Resource = "*"
      }
    ]
  })
}

# ELB Management Role
resource "aws_iam_role" "elb_role" {
  name_prefix = "y-r-elb-management-role-"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Effect = "Allow"
      }
    ]
  })

  tags = {
    Name    = "Y-R-ELB-Management-Role"
    Project = "TeamE"
  }
}

# Attach ELB Management Policy to Role
resource "aws_iam_role_policy_attachment" "elb_attachment" {
  policy_arn = aws_iam_policy.elb_policy.arn
  role       = aws_iam_role.elb_role.name
  depends_on = [aws_iam_policy.elb_policy, aws_iam_role.elb_role]
}

# State Management Commands (use these if necessary)
# terraform state list
# terraform state rm aws_iam_policy.elb_policy
# terraform state rm aws_iam_role.eks_cluster_role
# terraform state rm aws_iam_role.eks_node_group_role
# terraform state rm aws_iam_role.elb_role
