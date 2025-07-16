# CloudWatch Monitoring and Alarms

# CloudWatch Log Group for Application Logs
resource "aws_cloudwatch_log_group" "main" {
  name              = "/aws/ec2/${var.project_name}/${var.environment}"
  retention_in_days = var.log_retention_days

  tags = {
    Name        = "${var.project_name}-logs"
    Environment = var.environment
  }
}

# CloudWatch Log Group for VPC Flow Logs (Optional)
resource "aws_cloudwatch_log_group" "vpc_flow_log" {
  name              = "/aws/vpc/${var.project_name}/${var.environment}"
  retention_in_days = var.log_retention_days

  tags = {
    Name        = "${var.project_name}-vpc-flow-logs"
    Environment = var.environment
  }
}

# CloudWatch Metric Alarm - High CPU Usage
# This triggers auto-scaling to add more instances
resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "${var.project_name}-high-cpu-${var.environment}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"  # Number of periods to evaluate
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"  # 2 minutes
  statistic           = "Average"
  threshold           = var.scale_up_threshold
  alarm_description   = "Triggers when CPU exceeds ${var.scale_up_threshold}%"
  alarm_actions       = [aws_autoscaling_policy.scale_up.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.main.name
  }

  tags = {
    Name        = "${var.project_name}-high-cpu-alarm"
    Environment = var.environment
  }
}

# CloudWatch Metric Alarm - Low CPU Usage
# This triggers auto-scaling to remove instances
resource "aws_cloudwatch_metric_alarm" "low_cpu" {
  alarm_name          = "${var.project_name}-low-cpu-${var.environment}"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = var.scale_down_threshold
  alarm_description   = "Triggers when CPU falls below ${var.scale_down_threshold}%"
  alarm_actions       = [aws_autoscaling_policy.scale_down.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.main.name
  }

  tags = {
    Name        = "${var.project_name}-low-cpu-alarm"
    Environment = var.environment
  }
}

# CloudWatch Metric Alarm - Unhealthy Hosts
# Alerts when instances fail health checks
resource "aws_cloudwatch_metric_alarm" "unhealthy_hosts" {
  alarm_name          = "${var.project_name}-unhealthy-hosts-${var.environment}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "UnHealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  statistic           = "Average"
  threshold           = "0"
  alarm_description   = "Alert when we have any unhealthy hosts"
  treat_missing_data  = "notBreaching"

  dimensions = {
    TargetGroup  = aws_lb_target_group.main.arn_suffix
    LoadBalancer = aws_lb.main.arn_suffix
  }

  tags = {
    Name        = "${var.project_name}-unhealthy-hosts-alarm"
    Environment = var.environment
  }
}

# CloudWatch Metric Alarm - High Request Count
# Alerts when traffic is unusually high
resource "aws_cloudwatch_metric_alarm" "high_request_count" {
  alarm_name          = "${var.project_name}-high-requests-${var.environment}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "RequestCount"
  namespace           = "AWS/ApplicationELB"
  period              = "300"  # 5 minutes
  statistic           = "Sum"
  threshold           = "10000"  # Adjust based on expected traffic
  alarm_description   = "Alert when request count is unusually high"
  treat_missing_data  = "notBreaching"

  dimensions = {
    LoadBalancer = aws_lb.main.arn_suffix
  }

  tags = {
    Name        = "${var.project_name}-high-requests-alarm"
    Environment = var.environment
  }
}

# CloudWatch Dashboard
resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.project_name}-dashboard-${var.environment}"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/EC2", "CPUUtilization", { stat = "Average" }],
            [".", ".", { stat = "Maximum" }]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "EC2 CPU Utilization"
          period  = 300
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/ApplicationELB", "TargetResponseTime", { stat = "Average" }],
            [".", "RequestCount", { stat = "Sum" }]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "Load Balancer Metrics"
          period  = 300
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/ApplicationELB", "HealthyHostCount", { stat = "Average" }],
            [".", "UnHealthyHostCount", { stat = "Average" }]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "Target Health"
          period  = 300
        }
      }
    ]
  })
}
