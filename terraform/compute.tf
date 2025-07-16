# Data source for Amazon Linux 2 AMI
# This automatically selects the latest Amazon Linux 2 image as default
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Application Load Balancer
# This distributes incoming traffic across multiple EC2 instances
resource "aws_lb" "main" {
  name               = "${var.project_name}-alb-${var.environment}"
  internal           = false  # Internet-facing
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = [aws_subnet.public_1.id, aws_subnet.public_2.id]

  enable_deletion_protection = false  # Set to true in production
  enable_http2              = true    # Better performance

  tags = {
    Name = "${var.project_name}-alb-${var.environment}"
  }
}

# Target Group
# This defines how the load balancer routes traffic to instances
resource "aws_lb_target_group" "main" {
  name     = "${var.project_name}-tg-${var.environment}"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  # Health check configuration
  health_check {
    enabled             = true
    healthy_threshold   = 2    # Number of consecutive successful checks
    unhealthy_threshold = 2    # Number of consecutive failed checks
    timeout             = 5    # Seconds to wait for response
    interval            = 30   # Seconds between checks
    path                = "/"  # What URL to check
    matcher             = "200" # Expected HTTP response code
  }

  # Stickiness - keeps users on the same instance
  stickiness {
    type            = "lb_cookie"
    cookie_duration = 86400  # 24 hours
    enabled         = true
  }

  tags = {
    Name = "${var.project_name}-tg-${var.environment}"
  }
}

# ALB Listener
# This tells the load balancer what to do with incoming requests
resource "aws_lb_listener" "main" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}

# Launch Template
# This is the blueprint for our EC2 instances
resource "aws_launch_template" "main" {
  name_prefix   = "${var.project_name}-lt-${var.environment}-"
  image_id      = data.aws_ami.amazon_linux_2.id
  instance_type = var.instance_type

  # Attach security group
  vpc_security_group_ids = [aws_security_group.ec2.id]

  # Attach IAM role
  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_profile.name
  }

  # User data script - runs when instance starts
  user_data = base64encode(templatefile("${path.module}/../user_data.sh", {
    s3_bucket_url = "https://${aws_s3_bucket.static_assets.id}.s3.${var.aws_region}.amazonaws.com"
    project_name  = var.project_name
    environment   = var.environment
  }))

  # Instance metadata options (IMDSv2 for better security)
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "optional"  # Set to "required" for better security
    http_put_response_hop_limit = 1
  }

  # Monitoring
  monitoring {
    enabled = true  # Detailed monitoring (1-minute intervals)
  }

  # Tags for instances
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.project_name}-instance-${var.environment}"
    }
  }

  # Tags for volumes
  tag_specifications {
    resource_type = "volume"
    tags = {
      Name = "${var.project_name}-volume-${var.environment}"
    }
  }
}

# Auto Scaling Group
# This automatically adds/removes EC2 instances based on demand
resource "aws_autoscaling_group" "main" {
  name                = "${var.project_name}-asg-${var.environment}"
  vpc_zone_identifier = [aws_subnet.public_1.id, aws_subnet.public_2.id]
  target_group_arns   = [aws_lb_target_group.main.arn]
  health_check_type   = "ELB"  # Use load balancer health checks
  health_check_grace_period = 300  # Wait 5 minutes before checking health

  min_size         = var.min_size
  max_size         = var.max_size
  desired_capacity = var.desired_capacity

  # Use the launch template
  launch_template {
    id      = aws_launch_template.main.id
    version = "$Latest"
  }

  # Instance refresh - for rolling updates
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
  }

  # Tags for instances
  tag {
    key                 = "Name"
    value               = "${var.project_name}-asg-instance-${var.environment}"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = var.environment
    propagate_at_launch = true
  }

  tag {
    key                 = "AutoScaling"
    value               = "true"
    propagate_at_launch = true
  }
}

# Auto Scaling Policy - Scale Up
resource "aws_autoscaling_policy" "scale_up" {
  name                   = "${var.project_name}-scale-up-${var.environment}"
  scaling_adjustment     = 1  # Add 1 instance
  adjustment_type        = "ChangeInCapacity"
  cooldown              = 300  # Wait 5 minutes before next scaling
  autoscaling_group_name = aws_autoscaling_group.main.name
}

# Auto Scaling Policy - Scale Down
resource "aws_autoscaling_policy" "scale_down" {
  name                   = "${var.project_name}-scale-down-${var.environment}"
  scaling_adjustment     = -1  # Remove 1 instance
  adjustment_type        = "ChangeInCapacity"
  cooldown              = 300
  autoscaling_group_name = aws_autoscaling_group.main.name
}
