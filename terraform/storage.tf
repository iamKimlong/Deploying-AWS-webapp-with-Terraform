# S3 Bucket for Static Assets

# Random string to ensure unique bucket name
resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}

# S3 Bucket for Static Assets
resource "aws_s3_bucket" "static_assets" {
  bucket = "${var.project_name}-static-${var.environment}-${random_string.bucket_suffix.result}"

  tags = {
    Name        = "${var.project_name}-static-assets"
    Environment = var.environment
  }
}

# S3 Bucket Versioning (Optional - helps recover deleted files)
resource "aws_s3_bucket_versioning" "static_assets" {
  bucket = aws_s3_bucket.static_assets.id
  
  versioning_configuration {
    status = "Disabled"  # Set to "Enabled" to keep file history
  }
}

# S3 Bucket Public Access Block
# Configure public access settings
resource "aws_s3_bucket_public_access_block" "static_assets" {
  bucket = aws_s3_bucket.static_assets.id

  # Set these to true for private bucket
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# S3 Bucket Policy for Public Read Access
resource "aws_s3_bucket_policy" "static_assets" {
  bucket = aws_s3_bucket.static_assets.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"  # Anyone can read
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.static_assets.arn}/*"
      }
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.static_assets]
}

# S3 Bucket Website Configuration
# This allows the bucket to serve web content
resource "aws_s3_bucket_website_configuration" "static_assets" {
  bucket = aws_s3_bucket.static_assets.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

# S3 Bucket CORS Configuration
# Allows web browsers to access the content
resource "aws_s3_bucket_cors_configuration" "static_assets" {
  bucket = aws_s3_bucket.static_assets.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "HEAD"]
    allowed_origins = ["*"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}

# Upload static files to S3
# Note: In production, use CI/CD pipeline instead

# Upload CSS file
resource "aws_s3_object" "style_css" {
  bucket       = aws_s3_bucket.static_assets.id
  key          = "style.css"
  source       = "${path.module}/../static/style.css"
  content_type = "text/css"
  etag         = filemd5("${path.module}/../static/style.css")
}

# Upload JavaScript file
resource "aws_s3_object" "script_js" {
  bucket       = aws_s3_bucket.static_assets.id
  key          = "script.js"
  source       = "${path.module}/../static/script.js"
  content_type = "application/javascript"
  etag         = filemd5("${path.module}/../static/script.js")
}

# Upload architecture diagram placeholder
resource "aws_s3_object" "architecture_png" {
  bucket       = aws_s3_bucket.static_assets.id
  key          = "architecture.png"
  content      = "Placeholder for our actual architecture diagram"
  content_type = "text/plain"
}

# S3 Bucket Lifecycle Rules (Optional)
# Automatically delete old files to save money
# resource "aws_s3_bucket_lifecycle_configuration" "static_assets" {
#   bucket = aws_s3_bucket.static_assets.id
#
#   rule {
#     id     = "delete-old-logs"
#     status = "Enabled"
#
#     filter {
#       prefix = "logs/"
#     }
#
#     expiration {
#       days = 30
#     }
#   }
# }
