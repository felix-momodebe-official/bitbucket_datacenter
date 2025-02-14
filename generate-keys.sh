#!/bin/bash
echo "Generating SSH key pair for Bitbucket server..."
ssh-keygen -t rsa -b 4096 -f terraform/bitbucket -N ''
mv terraform/bitbucket terraform/bitbucket.pem
chmod 400 terraform/bitbucket.pem
echo "SSH key pair generated successfully!"
echo "Private key saved as: terraform/bitbucket.pem"
echo "Public key saved as: terraform/bitbucket.pub"
