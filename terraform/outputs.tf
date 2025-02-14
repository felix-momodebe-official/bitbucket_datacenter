output "bitbucket_public_ip" {
  value = aws_instance.bitbucket.public_ip
}

output "rds_endpoint" {
  value = aws_db_instance.bitbucket.endpoint
}

output "bitbucket_url" {
  value = "http://${aws_instance.bitbucket.public_ip}:7990"
}

output "efs_dns_name" {
  value = aws_efs_file_system.bitbucket.dns_name
}
