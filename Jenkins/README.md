# Jenkins CI Pipeline for Terraform and Docker
## Overview
This project automates the CI pipeline using Jenkins to provision AWS infrastructure via Terraform, build and test Docker images, and push them to Docker Hub. Follow the steps below to configure and run the pipeline.
- Create estimate time: 15min
- Destroy estimate time: 11min

## Prerequisites
- A running Jenkins instance.
- AWS account with appropriate permissions.
- Docker Hub account.
- Access to the GitHub repository.
- Installed Terraform on your local machine.

## Directory Structure
- final-project-terraform/ - Contains all the Terraform configuration files and modules.
- Jenkins/Jenkinsfile - The pipeline definition used by Jenkins.

## Step 1: Set Up Jenkins
### 1. Install & Setup Jenkins EC2 Instance:

- Use the Terraform configuration in final-project-terraform/final-project-jenkins-ec2 to set up a Jenkins server on an AWS EC2 instance.
- Navigate to the directory and run the following commands:
```
git clone git@github.com:yair232/status-page.git
cd final-project-terraform/final-project-jenkins-ec2
terraform init
terraform apply -auto-approve
```
- Once applied, the EC2 instance running Jenkins will be provisioned.
### 2. Install Required Jenkins Plugins:

- Navigate to Manage Jenkins → Manage Plugins.
- Install the following plugins:
- Git Plugin
- Pipeline Plugin
- SSH Agent Plugin
- Docker Pipeline Plugin
- Credentials Binding Plugin
## Step 2: Configure Jenkins Credentials
### 1. Add Credentials:
- Go to Manage Jenkins → Manage Credentials → Global Credentials → Add Credentials.
### 2. Credentials to Add:
- **GitHub SSH Key**: Add an SSH credential with the ID `github-ssh-key` to access your GitHub repository.
- **AWS Credentials**: Add your AWS Access Key and Secret Key as a Username with Password credential with the ID `aws-credentials`.
- **Docker Hub Credentials**: Add your Docker Hub username and password as a Username with Password credential with the ID `dockerhub-credentials`.
## Step 3: Set Up the Jenkins Pipeline
1. **Create a New Jenkins Pipeline Project**:
- In Jenkins, create a new project of type Pipeline.
- Under Pipeline Definition, choose Pipeline from SCM.
### 2. Configure the Pipeline:
- Set the SCM to Git.
- Use the repository URL: git@github.com:yair232/status-page.git.
- Set the Credentials to github-ssh-key (created in Step 2).
- Point Jenkins to the Jenkinsfile located in the repository.
## Step 4: Run the CI Pipeline
1. **Stages in the Jenkins Pipeline**:

- Clone Repository: Jenkins will pull the repository from GitHub.
- Terraform Init & Apply: Terraform will initialize and provision the AWS infrastructure (VPC, EKS, etc.).
- Build Docker Image: Builds a Docker image from the Dockerfile in the repository.
- Test Docker Image: Runs basic tests inside the Docker container.
- Push Docker Image to Docker Hub: Pushes the Docker image to your Docker Hub repository.
2. **Running the Pipeline**:

- Once configured, trigger a Build in Jenkins to start the pipeline.
- Jenkins will automatically execute each stage in the pipeline.
## Step 5: Clean Up Resources (Optional)
1. **Destroy the Terraform Infrastructure**:

- To clean up AWS resources created by Terraform, create another pipeline or modify the existing one to include the terraform destroy command.
Destroy Pipeline:

```
pipeline {
    agent any

    environment {
        AWS_CREDENTIALS_ID = 'aws-credentials'  // AWS Credentials ID in Jenkins
    }

    stages {
        stage('Clone Repository') {
            steps {
                git branch: 'main',
                    url: 'git@github.com:<your-username>/<your-repo>.git',
                    credentialsId: 'github-ssh-key'
            }
        }

        stage('Terraform Destroy') {
            environment {
                AWS_ACCESS_KEY_ID = credentials("${AWS_CREDENTIALS_ID}")
                AWS_SECRET_ACCESS_KEY = credentials("${AWS_CREDENTIALS_ID}")
            }
            steps {
                dir('final-project-terraform') {
                    sh '''
                    terraform init
                    terraform destroy -auto-approve
                    '''
                }
            }
        }
    }
}
```
2. **Clean Up Workspace**:

- Jenkins will clean up the workspace and Docker resources after the pipeline run using `cleanWs()` and `docker system prune -f`.
## Extensions in Jenkins
- Git: For cloning repositories from GitHub.
- Pipeline: Manages multi-stage pipeline execution.
- SSH Agent: Allows SSH authentication for GitHub via SSH keys.
- Docker Pipeline: Builds, tests, and deploys Docker containers.
- Credentials Binding: Securely manages credentials for AWS, Docker Hub, and GitHub.
## Conclusion
This pipeline automates the infrastructure provisioning, Docker image management, and testing. Follow the steps outlined above to set up Jenkins for CI, and modify the pipeline as needed to destroy AWS resources when done.
