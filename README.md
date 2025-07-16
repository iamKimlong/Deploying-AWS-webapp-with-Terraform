# AWS Cloud Computing Project

This project demonstrates building and deploying a web application on AWS using Infrastructure as Code (IaC) principles with Terraform.

## Project Overview

The application is a simple portfolio/blog site hosted on AWS with the following architecture:
- EC2 instances running the web application
- Application Load Balancer for distributing traffic
- Auto Scaling Group for high availability and resilience
- S3 bucket for hosting static assets
- CloudWatch for monitoring and logging
- IAM roles for secure access control

## Architecture Components

### Compute Layer
- **EC2 Instances**: Amazon Linux 2 instances running Apache web server
- **Auto Scaling Group**: Maintains 2-4 instances based on CPU utilization
- **Launch Template**: Defines instance configuration and user data script

### Networking Layer
- **VPC**: Custom VPC with CIDR 10.0.0.0/16
- **Subnets**: 2 public subnets across different availability zones
- **Internet Gateway**: Enables internet connectivity
- **Security Groups**: Control traffic to ALB and EC2 instances

### Load Balancing
- **Application Load Balancer**: Distributes traffic across EC2 instances
- **Target Group**: Health checks and routing configuration

### Storage
- **S3 Bucket**: Hosts static assets (CSS, JavaScript, images)
- **Public Access**: Configured for serving web content

### Monitoring & Logging
- **CloudWatch Metrics**: CPU utilization monitoring
- **CloudWatch Alarms**: Triggers auto-scaling actions
- **CloudWatch Logs**: Application and system logs

### Security
- **IAM Role**: EC2 instances access S3 and CloudWatch
- **Security Groups**: Restrict traffic to necessary ports only

## Prerequisites

1. AWS Account with appropriate permissions
2. Terraform installed (v1.0 or higher)
3. AWS CLI configured with credentials
4. Git for version control

## Project Structure

```
cloud-computing-project/
├── main.tf              # Main Terraform configuration
├── user_data.sh         # EC2 instance bootstrap script
├── README.md            # Project documentation
├── static/              # Static assets for S3
│   ├── style.css
│   ├── script.js
│   └── architecture.png
└── .gitignore          # Git ignore file
```

## Deployment Instructions

### 1. Clone the Repository
```bash
git clone https://github.com/yourusername/cloud-computing-project.git
cd cloud-computing-project
```

### 2. Initialize Terraform
```bash
terraform init
```

### 3. Review the Plan
```bash
terraform plan
```

### 4. Deploy Infrastructure
```bash
terraform apply
```
Type `yes` when prompted to confirm.

### 5. Upload Static Assets to S3
After deployment, upload the static files:
```bash
# Get the S3 bucket name from Terraform output
export BUCKET_NAME=$(terraform output -raw s3_bucket_name)

# Upload static assets
aws s3 cp static/style.css s3://$BUCKET_NAME/
aws s3 cp static/script.js s3://$BUCKET_NAME/
aws s3 cp static/architecture.png s3://$BUCKET_NAME/
```

### 6. Access the Application
Get the ALB DNS name:
```bash
terraform output alb_dns_name
```
Open this URL in your browser to access the application.

## Testing Auto Scaling

### Simulate High Load
1. SSH into one of the EC2 instances
2. Generate CPU load:
```bash
stress --cpu 8 --timeout 300s
```
3. Watch new instances being created in the AWS Console

### Simulate Instance Failure
1. Terminate an instance manually in AWS Console
2. Observe Auto Scaling Group launching a replacement
3. Verify application remains accessible

## Monitoring

### CloudWatch Dashboard
1. Navigate to CloudWatch in AWS Console
2. View metrics for:
   - EC2 CPU Utilization
   - ALB Request Count
   - Target Health

### View Logs
Check application logs in CloudWatch Logs:
- Log Group: `/aws/ec2/cloud-computing-project`
- Log Streams: Apache access and error logs

## Cost Optimization

### Estimated Monthly Costs (US East Region)
- EC2 t2.micro (2 instances): ~$17
- Application Load Balancer: ~$16
- S3 Storage (1GB): ~$0.02
- Data Transfer: ~$5
- **Total**: ~$38/month

### Cost Saving Tips
1. Use t3.micro instead of t2.micro for better performance/cost
2. Enable S3 lifecycle policies for old logs
3. Use Reserved Instances for long-term deployments
4. Set up billing alerts in AWS

## Clean Up

To avoid ongoing charges, destroy the infrastructure when done:
```bash
terraform destroy
```
Type `yes` to confirm deletion of all resources.

## Troubleshooting

### Common Issues

1. **Instances not healthy in Target Group**
   - Check Security Group rules
   - Verify user data script execution
   - Review Apache error logs

2. **Cannot access application**
   - Ensure ALB security group allows port 80
   - Check instance health in Target Group
   - Verify DNS propagation

3. **Auto Scaling not working**
   - Check CloudWatch alarms status
   - Verify IAM role permissions
   - Review Auto Scaling Group activity history

## Security Best Practices

1. **Principle of Least Privilege**: IAM roles have minimal required permissions
2. **Network Security**: Security groups restrict unnecessary access
3. **Encryption**: Enable S3 encryption for sensitive data
4. **Updates**: Regularly update EC2 instances with security patches

## Future Enhancements

- [ ] Add HTTPS support with ACM certificate
- [ ] Implement RDS database for dynamic content
- [ ] Add CloudFront CDN for better performance
- [ ] Implement CI/CD pipeline with CodePipeline
- [ ] Add Route 53 for custom domain
- [ ] Implement blue-green deployment strategy

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- AWS Documentation
- Terraform AWS Provider Documentation
- Cloud Computing Course Materials
