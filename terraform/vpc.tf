resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true  # Allows EC2 instances to have public DNS names
  enable_dns_support   = true   # Enables DNS resolution within the VPC

  tags = {
    Name = "${var.project_name}-vpc-${var.environment}"
  }
}

# Internet Gateway - Allows VPC to communicate with the internet
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-igw-${var.environment}"
  }
}

# Public Subnet 1 - In first availability zone
resource "aws_subnet" "public_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_1_cidr
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true  # Instances get public IPs automatically

  tags = {
    Name = "${var.project_name}-public-subnet-1-${var.environment}"
    Type = "public"
    AZ   = data.aws_availability_zones.available.names[0]
  }
}

# Public Subnet 2 - In second availability zone for high availability
resource "aws_subnet" "public_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_2_cidr
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-public-subnet-2-${var.environment}"
    Type = "public"
    AZ   = data.aws_availability_zones.available.names[1]
  }
}

# Route Table - Defines how traffic is routed
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  # Route all non-local traffic through internet gateway
  route {
    cidr_block = "0.0.0.0/0"  # All internet traffic
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.project_name}-public-rt-${var.environment}"
    Type = "public"
  }
}

# Associate Route Table with Subnet 1
resource "aws_route_table_association" "public_1" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public.id
}

# Associate Route Table with Subnet 2
resource "aws_route_table_association" "public_2" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.public.id
}

# VPC Flow Logs (Optional - uncomment to enable)
# This logs all network traffic for security and debugging
# resource "aws_flow_log" "main" {
#   iam_role_arn    = aws_iam_role.flow_log.arn
#   log_destination = aws_cloudwatch_log_group.vpc_flow_log.arn
#   traffic_type    = "ALL"
#   vpc_id          = aws_vpc.main.id
#   
#   tags = {
#     Name = "${var.project_name}-flow-logs-${var.environment}"
#   }
# }
