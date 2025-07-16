# Output values to display after deployment

output "alb_dns_name" {
  description = "DNS name of the load balancer - use this to access our application"
  value       = aws_lb.main.dns_name
}

output "alb_url" {
  description = "Full URL to access the application"
  value       = "http://${aws_lb.main.dns_name}"
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket for static assets"
  value       = aws_s3_bucket.static_assets.id
}

output "s3_bucket_website_endpoint" {
  description = "Website endpoint of the S3 bucket"
  value       = aws_s3_bucket_website_configuration.static_assets.website_endpoint
}

output "cloudwatch_dashboard_url" {
  description = "URL to CloudWatch dashboard"
  value       = "https://${var.aws_region}.console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}#dashboards:name=${aws_cloudwatch_dashboard.main.dashboard_name}"
}

output "autoscaling_group_name" {
  description = "Name of the Auto Scaling Group"
  value       = aws_autoscaling_group.main.name
}

output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "IDs of public subnets"
  value       = [aws_subnet.public_1.id, aws_subnet.public_2.id]
}

output "security_group_ids" {
  description = "Security group IDs"
  value = {
    alb = aws_security_group.alb.id
    ec2 = aws_security_group.ec2.id
  }
}

output "iam_role_arn" {
  description = "ARN of the EC2 IAM role"
  value       = aws_iam_role.ec2_role.arn
}

output "aws_account_id" {
  description = "AWS Account ID"
  value       = data.aws_caller_identity.current.account_id
}

output "aws_region" {
  description = "AWS Region"
  value       = data.aws_region.current.name
}

# Instructions for next steps
output "next_steps" {
  description = "What to do after deployment"
  value = <<-EOT
    
    🎉 Deployment Complete! Here's what to do next:
    
    1. Access the application:
       ${aws_lb.main.dns_name}
    
    2. View CloudWatch Dashboard:
       https://${var.aws_region}.console.aws.amazon.com/cloudwatch
    
    3. Check Auto Scaling Group:
       https://${var.aws_region}.console.aws.amazon.com/ec2/v2/home?region=${var.aws_region}#AutoScalingGroups
    
    4. Upload additional files to S3:
       aws s3 cp <file> s3://${aws_s3_bucket.static_assets.id}/
    
    5. Test auto-scaling by generating load:
       - Terminate an instance to test auto-recovery
       - Generate CPU load to test scale-up
    
    Remember to run 'terraform destroy' when done to avoid charges!
  EOT
}
