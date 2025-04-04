# Iac-Medusa-AWS-ECS
The project automates the provisioning and deployment of a Medusa e-commerce application on AWS using Terraform for infrastructure as code, Docker for containerization(ECR), ECS for Deployment and GitHub Actions for CI/CD. It aims to streamline workflows and enhance software delivery efficiency through modern DevOps practices.

Project Objectives
1. Automate Infrastructure Provisioning:

Use Terraform to define and provision AWS resources, ensuring a reproducible and scalable infrastructure setup.
2. Implement CI/CD Pipelines:

Set up GitHub Actions to automate the build, test, and deployment processes for the Medusa application, enhancing workflow efficiency.
3. Containerize Applications:

Utilize Docker to package the Medusa application and its dependencies, ensuring consistent deployment across Elastic Container Services (ECS).
4. Deploy on AWS:

Leverage AWS services like RDS ECS, and ECR to host and manage the Medusa application in a secure and scalable manner.
5. Enhance Security:

Configure security groups and VPC settings to ensure secure access to AWS resources while maintaining functionality
🔗 Links
linkedin

Authors
@GurkaSathish
Pre-Requisites
AWS account (user)

GitHub, GitHub Actions

Linux

GitHub repository with the necessary secrets configured." AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_REGION, AWS_ACCOUNT_ID, ECR_REPOSITORY_NAME, DB_PASSWORD, ECS_CLUSTER_NAME ECS_SERVICE_NAME, ECR_REPOSITORY_NAME, TASK_FAMILY"
Project Structure
Devops-Internship-1.6/
├── main.tf           # Terraform configuration
├── variables.tf      # Variables for Terraform
├── outputs.tf        # Output values for Terraform
├── README.md         # Project documentation
└── .github/
    └── workflows/    # GitHub Actions workflows
GitHub Actions Workflow Overview
GitHub Actions Workflow Overview
This workflow automates the deployment of the Medusa application on ECS Fargate Spot. It consists of several jobs that handle infrastructure provisioning, Docker image management, and application deployment.

Step-by-Step Explanation
Workflow Trigger:

The workflow triggers on a push event to the main branch.
Job 1: Provision Infrastructure with Terraform (terraform)

Checkout Code: Uses the actions/checkout@v2 action to pull the repository code.
Setup Terraform: Uses hashicorp/setup-terraform@v1 to set up Terraform with the specified version (1.5.0).
Configure AWS Credentials: Configures AWS credentials using aws-actions/configure-aws-credentials@v1, pulling secrets from GitHub Secrets (AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_REGION).
Terraform Init: Initializes the Terraform configuration by changing to the Terraform directory and running terraform init.
Terraform Plan: Creates an execution plan for Terraform to show what changes will be made.
Terraform Apply: Applies the changes required to reach the desired state of the infrastructure. It uses -auto-approve to skip manual approval and passes the database password from GitHub Secrets.
Job 2: Pull from Docker Hub, Tag, and Push to ECR (pull_tag_push_image)

Needs: This job depends on the successful completion of the terraform job.
Checkout Code: Checks out the code again.
Configure AWS Credentials: Similar to Job 1, sets up AWS credentials for ECR access.
Set ECR Repository URL: Constructs the ECR repository URL and saves it to the environment variable ECR_REPOSITORY_URL.
Log in to Amazon ECR: Authenticates the Docker CLI to ECR using the AWS CLI command.
Pull Docker Image from Docker Hub: Pulls the latest Docker image of the Medusa backend from Docker Hub.
Tag Docker Image: Tags the pulled Docker image with the ECR repository URL.
Push Docker Image to ECR: Pushes the tagged image to Amazon ECR.
Job 3: Deploy to ECS (deploy_to_ecs)

Needs: This job depends on the successful completion of the pull_tag_push_image job.
Checkout Code: Checks out the code once more.
Configure AWS Credentials: Sets up AWS credentials again for ECS access.
Update ECS Service with New Task Definition: Uses the AWS CLI to update the ECS service with the new task definition, forcing a new deployment.
Job 4: Post-Deployment Steps (post_deployment)

Needs: This job depends on the successful completion of the deploy_to_ecs job.
Check RDS Endpoint: Outputs the RDS endpoint to indicate successful deployment and connection to the RDS database. This uses an environment variable RDS_ENDPOINT that should be set earlier in the workflow or Terraform scripts.
Technologies Used
1. AWS Services:

Amazon ECS (Elastic Container Service)

Amazon ECR (Elastic Container Registry)

Amazon VPC (Virtual Private Cloud)

2. Infrastructure as Code:

Terraform

3. Containerization:

Docker

4. Continuous Integration/Continuous Deployment:

GitHub Actions

5. Version Control:

Git

6. Programming Languages:

YAML (for configuration files in GitHub Action

Contact
For any inquiries or issues related to this project, please reach out via email:

Author: Gurka Sathish

Email: sathishgurka@gmail.com

Result
Successfully streamlined the CI/CD of Medusa-backend using GitHub Actions , Elastc Container Registry(ECR) and Elastic Container Service (ECS)
