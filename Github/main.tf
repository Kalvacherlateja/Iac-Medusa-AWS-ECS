name: Deploy Medusa on ECS Fargate Spot
on:
  push:
    branches:
      - main

jobs:
  terraform:
    name: Provision Infrastructure with Terraform
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v2

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v1
        with:
         terraform_version: 1.5.0  # Use your Terraform version here
        
      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v1
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: ${{ secrets.AWS_REGION }}

      - name: Terraform Init
        run: |
         cd Terraform
         terraform init

      - name: Terraform Plan
        run: |
         cd Terraform
         terraform plan

      - name: Terraform Apply
        env:
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          AWS_REGION: ${{ secrets.AWS_REGION }}
          DB_PASSWORD: ${{ secrets.DB_PASSWORD }}
        run: |
           cd Terraform 
           terraform apply -auto-approve -var "db_password=${{ secrets.DB_PASSWORD }}"

  pull_tag_push_image:
    name: Pull from Docker Hub, Tag, and Push to ECR
    runs-on: ubuntu-latest
    needs: terraform
    steps:
      - name: Checkout code
        uses: actions/checkout@v2

      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v1
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: ${{ secrets.AWS_REGION }}

      - name: Set ECR Repository URL
        run: |
          echo "ECR_REPOSITORY_URL=${{ secrets.AWS_ACCOUNT_ID }}.dkr.ecr.${{ secrets.AWS_REGION }}.amazonaws.com/${{ secrets.ECR_REPOSITORY_NAME }}" >> $GITHUB_ENV

      - name: Log in to Amazon ECR
        run: |
           aws ecr get-login-password --region ${{ secrets.AWS_REGION }} | docker login --username AWS --password-stdin ${{ env.ECR_REPOSITORY_URL }}
      
      - name: Pull Docker Image from Docker Hub
        run: docker pull gurkasathish/medusa-backend_medusa:latest

      - name: Tag Docker Image
        run: docker tag gurkasathish/medusa-backend_medusa:latest ${{ env.ECR_REPOSITORY_URL }}:latest

      - name: Push Docker Image to ECR
        run: docker push ${{ env.ECR_REPOSITORY_URL }}:latest

  deploy_to_ecs:
    name: Deploy to ECS
    runs-on: ubuntu-latest
    needs: pull_tag_push_image
    steps:
      - name: Checkout code
        uses: actions/checkout@v2

      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v1
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: ${{ secrets.AWS_REGION }}
          
      - name: Update ECS Service with New Task Definition
        run: |
         aws ecs update-service \
          --cluster ${{ secrets.ECS_CLUSTER_NAME }} \
          --service ${{ secrets.ECS_SERVICE_NAME }} \
          --task-definition ${{ secrets.TASK_FAMILY }} \
          --force-new-deployment
          
  post_deployment:
    name: Post-Deployment Steps
    runs-on: ubuntu-latest
    needs: deploy_to_ecs
    steps:
      - name: Check RDS Endpoint
        run: |
         echo "Medusa is deployed and connected to the RDS at: ${{ env.RDS_ENDPOINT }}"
