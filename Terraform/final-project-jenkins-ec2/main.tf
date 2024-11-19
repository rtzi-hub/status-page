provider "aws" {
  region = var.aws_region
}

# Create a VPC for Jenkins with a non-overlapping CIDR block
resource "aws_vpc" "jenkins_vpc" {
  cidr_block = var.vpc_cidr_block

  tags = {
    Name    = var.vpc_name
    Project = "TeamE"
  }
}

# Create a public subnet
resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.jenkins_vpc.id
  cidr_block        = var.public_subnet_cidr
  availability_zone = var.availability_zone
  map_public_ip_on_launch = true

  tags = {
    Name    = "y-r-JenkinsPublicSubnet"
    Project = "TeamE"
  }
}

# Create a private subnet
resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.jenkins_vpc.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = var.availability_zone

  tags = {
    Name    = "y-r-JenkinsPrivateSubnet"
    Project = "TeamE"
  }
}

# Create an Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.jenkins_vpc.id

  tags = {
    Name    = "y-r-JenkinsIGW"
    Project = "TeamE"
  }
}

# Route Table for Public Subnet
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.jenkins_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "y-r-PublicRouteTable"
    Project = "TeamE"
  }
}

# Associate Public Subnet with Route Table
resource "aws_route_table_association" "public_route_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

# Create Security Group for Jenkins EC2 instance
resource "aws_security_group" "jenkins_sg" {
  vpc_id = aws_vpc.jenkins_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow SSH from anywhere
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow HTTP for Jenkins UI
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # HTTP Access
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # HTTPS Access
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # Allow all outbound traffic
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = var.security_group_name
    Project = "TeamE"
  }
}

# Create an EC2 instance for Jenkins
resource "aws_instance" "jenkins_ec2" {
  ami                    = data.aws_ssm_parameter.ubuntu_ami.value
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]
  key_name               = var.key_name

  # Add root volume with a 30 GB size
  root_block_device {
    volume_size = 30  # Set the size of the root volume to 30 GB
    volume_type = "gp3"  # Specify volume type (e.g., gp3 for General Purpose SSD)
  }

  tags = {
    Name    = var.ec2_name
    Project = "TeamE"
  }

  # Install Jenkins and restore backup via user_data script
  user_data = <<-EOF
  #!/bin/bash
  set -e

  # Update package list and install core utilities
  sudo apt update -y
  sudo apt install -y apt-transport-https ca-certificates curl software-properties-common

  # Install OpenJDK
  sudo apt install -y openjdk-17-jdk

  # Install Docker
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
  echo "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list
  sudo apt-get update
  sudo apt-get install -y docker-ce

  # Add jenkins user to the docker group
  sudo usermod -aG docker jenkins

  # Download and install Terraform
  curl -LO "https://releases.hashicorp.com/terraform/1.6.3/terraform_1.6.3_linux_amd64.zip"
  unzip terraform_1.6.3_linux_amd64.zip
  sudo mv terraform /usr/local/bin/
  rm terraform_1.6.3_linux_amd64.zip  # Cleanup

  # Download Kubectl
  curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
  chmod +x kubectl
  sudo mv kubectl /usr/local/bin/
  kubectl version --client

  # Download AWS CLI
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
  unzip awscliv2.zip
  sudo ./aws/install
  rm awscliv2.zip

  # Add Jenkins key and repository
  sudo wget -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
  echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

  # Install Jenkins
  sudo apt-get update
  sudo apt-get install -y jenkins

  # Enable and start Jenkins
  sudo systemctl enable jenkins
  sudo systemctl start jenkins

  # Install Python and related modules
  sudo apt-get install -y python3 python3-pip
  sudo pip3 install pytest

  # Create backup directory if it doesn't exist
  sudo mkdir -p /var/lib/jenkins/backup

  # Clone the backup repository and copy backups to Jenkins
  git clone https://github.com/yair232/status-page.git /tmp/jenkins-backup
  sudo cp -r /tmp/jenkins-backup/status-page/final-project-terraform/Jenkins/backups/* /var/lib/jenkins/backup/ # Adjust as necessary

  # Set proper ownership
  sudo chown -R jenkins:jenkins /var/lib/jenkins/
EOF
}

# Fetch the latest Ubuntu 22.04 LTS AMI using AWS SSM Parameter Store
data "aws_ssm_parameter" "ubuntu_ami" {
  name = "/aws/service/canonical/ubuntu/server/22.04/stable/current/amd64/hvm/ebs-gp2/ami-id"
}
