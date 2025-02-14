Write-Host "Generating SSH key pair for Bitbucket server..."
ssh-keygen -t rsa -b 4096 -f terraform/bitbucket -N '""'
Move-Item terraform/bitbucket.pub terraform/bitbucket.pub -Force
Move-Item terraform/bitbucket terraform/bitbucket.pem -Force
Write-Host "SSH key pair generated successfully!"
Write-Host "Private key saved as: terraform/bitbucket.pem"
Write-Host "Public key saved as: terraform/bitbucket.pub"
