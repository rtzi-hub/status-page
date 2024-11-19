# AWS EKS Infrastructure with Terraform

This terraform project sets up an AWS infrastructure with a VPC, subnets, an Internet Gateway, a Load Balancer, and an EKS cluster.
Estimate time - 15min

## Directory Structure
- `vpc/` - Contains VPC, subnets, and Internet Gateway configurations.
- `eks/` - Contains EKS cluster configuration.
- `load_balancer/` - Contains Load Balancer configuration.
- `iam/` - Contains The IAM Roles configuration.
- `main.tf` - Entry point for the Terraform configuration.
- `variables.tf` - Variable definitions.
- `outputs.tf` - Output values from the Terraform configuration.

# Terraform Project for AWS Infrastructure

## Overview
This Terraform project automates the deployment of a robust and scalable infrastructure on AWS. The infrastructure includes a Virtual Private Cloud (VPC), Elastic Kubernetes Service (EKS), a managed Relational Database Service (RDS), Identity and Access Management (IAM) roles, and an Elastic Load Balancer (ELB). This setup ensures high availability and secure access to your applications.

## Prerequisites
- An AWS account with sufficient permissions to create resources.
- Terraform installed on your local machine.
- Basic knowledge of Terraform and AWS concepts.

## Components and Purpose
1. **VPC (Virtual Private Cloud)**:
   - **Purpose**: A dedicated network environment that houses all AWS resources. It includes both public and private subnets for resource segregation.
   - **Public Subnets**: Used for resources that need to be accessible from the internet, such as the Load Balancer.
   - **Private Subnets**: Used for internal resources like the RDS database and EKS worker nodes, which should not be directly accessible from the internet.

2. **Security Groups**:
   Security groups act as virtual firewalls, controlling inbound and outbound traffic for AWS resources.
   - **EKS Node Security Group (eks_node_sg)**:
     - **Purpose**: Controls traffic for EKS worker nodes.
     - **Ingress**: Allows traffic from the Kubernetes control plane and Load Balancer to the worker nodes.
     - **Egress**: Allows outbound internet traffic for updates or communication with other AWS services.
   - **RDS Security Group (db_SG)**:
     - **Purpose**: Restricts access to the RDS database.
     - **Ingress**: Only allows traffic from EKS worker nodes over PostgreSQL's default port (5432).
     - **Egress**: Allows outbound traffic for necessary AWS service communication.
   - **Application Security Group (app_security_group)**:
     - **Purpose**: Controls traffic for the Load Balancer routing requests to the application on EKS.
     - **Ingress**: Allows HTTP (port 80) and HTTPS (port 443) traffic from the internet.
     - **Egress**: Allows outgoing traffic from the Load Balancer to application instances.

3. **EKS (Elastic Kubernetes Service)**:
   - **Purpose**: Orchestrates containerized applications using Kubernetes. It manages the control plane while provisioning worker nodes in private subnets.

4. **RDS (Relational Database Service)**:
   - **Purpose**: Deploys a managed PostgreSQL database instance in private subnets for enhanced security, accessible only to approved sources like EKS worker nodes.

5. **IAM (Identity and Access Management)**:
   - **Purpose**: Manages access and permissions for AWS resources through IAM roles associated with EKS, RDS, and Load Balancer.

6. **Load Balancer**:
   - **Purpose**: Distributes incoming application traffic across EKS worker nodes, ensuring high availability and fault tolerance.

## Steps to Deploy the Infrastructure

### Step 1: Clone the Repository
Clone this repository to your local machine.
```bash
git clone https://github.com/yair232/status-page.git
cd final-project
```
### step 2: Configure AWS CLI
Run the following command to configure your AWS CLI with your access key, secret key, region, and output format:
```bash
aws configure
```
### Step 3: Initialize Terraform
Initialize the Terraform configuration.
```bash
terraform init
```
### Step 4: Validate the Configuration
Check the Terraform configuration for any errors.
```bash
terraform validate
```
### Step 5: Plan the Deployment
Generate and review the execution plan to ensure the changes are as expected.

```bash
terraform plan
```
### Step 6: Apply the Configuration
Deploy the infrastructure by applying the Terraform configuration.

```bash
terraform apply
```
**Confirm the action by typing yes when prompted.**

### Step 7: To remove all resources created by this Terraform project, run the following command:
```bash
terraform destroy
```
**Confirm the action by typing yes when prompted.**
