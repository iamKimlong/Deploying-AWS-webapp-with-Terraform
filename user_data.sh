#!/bin/bash
# user_data.sh - EC2 Instance Bootstrap Script

# Update system
yum update -y

# Install necessary packages
yum install -y httpd wget curl git amazon-cloudwatch-agent

# Start and enable Apache
systemctl start httpd
systemctl enable httpd

# Create a simple web application
cat > /var/www/html/index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Cloud Computing Project</title>
    <link rel="stylesheet" href="${s3_bucket_url}/style.css">
</head>
<body>
    <div class="container">
        <header>
            <h1>Welcome to My Cloud Computing Project</h1>
            <p>This web application is hosted on AWS using Infrastructure as Code</p>
        </header>
        
        <main>
            <section class="info">
                <h2>Project Details</h2>
                <ul>
                    <li>Hosted on EC2 with Auto Scaling</li>
                    <li>Static assets served from S3</li>
                    <li>Load balanced with Application Load Balancer</li>
                    <li>Monitored with CloudWatch</li>
                    <li>Infrastructure managed with Terraform</li>
                </ul>
            </section>
            
            <section class="instance-info">
                <h2>Instance Information</h2>
                <p>Instance ID: <span id="instance-id"></span></p>
                <p>Availability Zone: <span id="az"></span></p>
                <p>Instance Type: <span id="instance-type"></span></p>
            </section>
            
            <section class="image-section">
                <h2>Architecture Overview</h2>
                <img src="${s3_bucket_url}/architecture.png" alt="AWS Architecture">
            </section>
        </main>
        
        <footer>
            <p>&copy; 2024 Cloud Computing Project. All rights reserved.</p>
        </footer>
    </div>
    
    <script src="${s3_bucket_url}/script.js"></script>
    <script>
        // Fetch instance metadata
        fetch('http://169.254.169.254/latest/meta-data/instance-id')
            .then(response => response.text())
            .then(data => document.getElementById('instance-id').textContent = data);
            
        fetch('http://169.254.169.254/latest/meta-data/placement/availability-zone')
            .then(response => response.text())
            .then(data => document.getElementById('az').textContent = data);
            
        fetch('http://169.254.169.254/latest/meta-data/instance-type')
            .then(response => response.text())
            .then(data => document.getElementById('instance-type').textContent = data);
    </script>
</body>
</html>
EOF

# Create a simple health check endpoint
cat > /var/www/html/health.html << 'EOF'
<!DOCTYPE html>
<html>
<head><title>Health Check</title></head>
<body><h1>Healthy</h1></body>
</html>
EOF

# Set proper permissions
chown -R apache:apache /var/www/html
chmod -R 755 /var/www/html

# Configure CloudWatch agent
cat > /opt/aws/amazon-cloudwatch-agent/etc/cloudwatch-config.json << 'EOF'
{
  "metrics": {
    "namespace": "CloudComputingProject",
    "metrics_collected": {
      "cpu": {
        "measurement": [
          {
            "name": "cpu_usage_idle",
            "rename": "CPU_USAGE_IDLE",
            "unit": "Percent"
          },
          {
            "name": "cpu_usage_iowait",
            "rename": "CPU_USAGE_IOWAIT",
            "unit": "Percent"
          },
          "cpu_time_guest"
        ],
        "totalcpu": false,
        "metrics_collection_interval": 60
      },
      "disk": {
        "measurement": [
          {
            "name": "used_percent",
            "rename": "DISK_USED_PERCENT",
            "unit": "Percent"
          }
        ],
        "metrics_collection_interval": 60,
        "resources": [
          "*"
        ]
      },
      "mem": {
        "measurement": [
          {
            "name": "mem_used_percent",
            "rename": "MEM_USED_PERCENT",
            "unit": "Percent"
          }
        ],
        "metrics_collection_interval": 60
      }
    }
  },
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/httpd/access_log",
            "log_group_name": "/aws/ec2/cloudproject",
            "log_stream_name": "{instance_id}/apache/access"
          },
          {
            "file_path": "/var/log/httpd/error_log",
            "log_group_name": "/aws/ec2/cloudproject",
            "log_stream_name": "{instance_id}/apache/error"
          }
        ]
      }
    }
  }
}
EOF

# Start CloudWatch agent
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
    -a fetch-config \
    -m ec2 \
    -s \
    -c file:/opt/aws/amazon-cloudwatch-agent/etc/cloudwatch-config.json

# Log the completion
echo "User data script completed at $(date)" >> /var/log/user-data.log
