# Bitbucket Data Center Deployment

This repository contains the necessary configuration files to deploy Bitbucket Data Center on AWS using Docker Compose and Ansible.

## Required Resources:

### 1. AWS Resources:
- VPC with public and private subnets
- Application Load Balancer (ALB)
- EC2 instances for Bitbucket nodes
- RDS PostgreSQL instance for database
- Elastic File System (EFS) for shared storage
- Security Groups
- IAM roles and policies

## Component Clarification:

EFS (Elastic File System):
- Used for storing Git repositories and shared attachments
- Needed because multiple Bitbucket instances need to access the same files

RDS PostgreSQL:
- Required as Bitbucket's primary database
- Stores user accounts, project metadata, pull request data, etc.
- More reliable and manageable than running PostgreSQL in a container

Elasticsearch:
- Required for Bitbucket's code search functionality
- Runs in a container alongside Bitbucket
- Makes repository content searchable

### 2. Environment:
- Terraform
- Ansible
- Docker and Docker Compose
- AWS CLI
- Git/GitHub Repo

## Project Directory Structure

```
bitbucket-datacenter/
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── terraform.tfvars
├── ansible/
│   ├── inventory/
│   ├── playbooks/
│   └── roles/
└── docker/
    └── docker-compose.yml
```

## Deployment Steps/Setup Instructions:


### 1. Prerequisites:
- Install AWS CLI and configure it with your credentials
- Install Terraform
- Install Ansible
- Have a valid Bitbucket Data Center license
### 2. Infrastructure Deployment: The Terraform configuration will create:
- A VPC with public and private subnets
- An Application Load Balancer (ALB)
- Auto Scaling Group for Bitbucket nodes
- RDS PostgreSQL database
- EFS for shared storage
- Required security groups and IAM roles
- 
### 3. Configuration Management: The Ansible playbook will:
- Install Docker and Docker Compose
- Configure the EFS mount
- Set up the Bitbucket environment
- Deploy the Docker containers

## How to Deploy:

1. First, initialize and apply the Terraform configuration:

bash
```
cd terraform

terraform init

terraform plan

terraform apply
```

2. After the infrastructure is created, update your Ansible inventory with the new EC2 instances.
3. Run the Ansible playbook:

bash
```
cd ../ansible

ansible-playbook -i inventory/hosts playbooks/setup-bitbucket.yml
```

## Important Notes:

1. Security:
- The configuration includes basic security groups
- You should add SSL/TLS configuration for production use
- Change the database password in production

2. Scaling:
- The configuration supports horizontal scaling through the Auto Scaling Group
- You can adjust the number of nodes by changing bitbucket_cluster_size in variables.tf

3. Monitoring:
- Consider adding CloudWatch monitoring
- Set up alerts for system metrics

4. Backup:
- RDS has automated backups
- Consider setting up EFS backups
- Implement a backup strategy for Bitbucket data

# To access Bitbucket:

- After deployment, get the ALB DNS name from the AWS Console or Terraform outputs
- Access Bitbucket through your browser using the ALB DNS name
- Complete the initial setup using the web interface

