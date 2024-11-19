#!/bin/bash

# Variables
REGION="us-east-1"
CLUSTER_NAME="y-r-cluster"
NAMESPACE="argocd"
ARGOCD_MANIFEST="https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml"
SERVICE_ACCOUNT_NAME="aws-load-balancer-controller"
IAM_ROLE_NAME="AmazonEKSLoadBalancerControllerRole-yair-ron"
POLICY_ARN="arn:aws:iam::992382545251:policy/AWSLoadBalancerControllerIAMPolicy"

# Check if eksctl is installed
if ! command -v eksctl &> /dev/null; then
  echo "eksctl not found. Installing eksctl..."
  curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
  chmod +x /tmp/eksctl
  export PATH=$PATH:/tmp  # Adding /tmp to PATH for the current script session
  if ! command -v eksctl &> /dev/null; then
    echo "Failed to install eksctl. Exiting."
    exit 1
  fi
  echo "eksctl installed successfully."
fi

# Update kubeconfig for AWS EKS cluster
echo "Updating kubeconfig for EKS cluster..."
aws eks update-kubeconfig --region "$REGION" --name "$CLUSTER_NAME"
if [ $? -ne 0 ]; then
  echo "Failed to update kubeconfig. Exiting."
  exit 1
fi

# Create Argo CD namespace
echo "Creating namespace $NAMESPACE..."
kubectl create namespace "$NAMESPACE"
if [ $? -ne 0 ]; then
  echo "Failed to create namespace. Exiting."
  exit 1
fi

# Apply Argo CD manifest
echo "Applying Argo CD manifest..."
kubectl apply -n "$NAMESPACE" -f "$ARGOCD_MANIFEST"
if [ $? -ne 0 ]; then
  echo "Failed to apply Argo CD manifest. Exiting."
  exit 1
fi

# Create IAM service account for AWS Load Balancer Controller
echo "Creating IAM service account for AWS Load Balancer Controller..."
eksctl create iamserviceaccount \
  --cluster="$CLUSTER_NAME" \
  --region="$REGION" \
  --namespace="kube-system" \
  --name="$SERVICE_ACCOUNT_NAME" \
  --role-name="$IAM_ROLE_NAME" \
  --attach-policy-arn="$POLICY_ARN" \
  --approve
if [ $? -ne 0 ]; then
  echo "Failed to create IAM service account. Exiting."
  exit 1
fi

echo "Argo CD installation and IAM service account creation completed successfully."
