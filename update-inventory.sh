#!/bin/bash

# Get the EC2 public IP from Terraform output
EC2_IP=$(cd terraform && terraform output -raw bitbucket_public_ip)
RDS_ENDPOINT=$(cd terraform && terraform output -raw rds_endpoint)

# Update Ansible inventory
cat > ansible/inventory/hosts << EOF
[bitbucket_nodes]
${EC2_IP}

[bitbucket_nodes:vars]
ansible_user=ec2-user
ansible_ssh_private_key_file=/mnt/c/Users/Felix/Downloads/my_default_keypair.pem
ansible_ssh_common_args='-o StrictHostKeyChecking=no'
EOF

# Create Docker environment file
cat > docker/.env << EOF
DB_HOST=${RDS_ENDPOINT%:*}
DB_PASSWORD=BitbucketDB2025!
DOMAIN_NAME=${EC2_IP}
EOF

echo "Updated inventory with EC2 IP: ${EC2_IP}"
echo "Updated Docker environment with RDS endpoint: ${RDS_ENDPOINT%:*}"
