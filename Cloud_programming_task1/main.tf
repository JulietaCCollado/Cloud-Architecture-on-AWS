# Defines the IAM role for the Lambda function
resource "aws_iam_role" "lambda_role" {
  name = "lambda_execution_role"

  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Service = "lambda.amazonaws.com" }
        Action    = "sts:AssumeRole"
      }
    ]
  })
}

# Defines the IAM policy for S3 access
resource "aws_iam_policy" "s3_policy" {
  name        = "S3FullAccessPolicy"
  description = "Policy to allow full access to S3"
  
  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "s3:*",
          "s3-object-lambda:*"
        ]
        Resource = "*"
      }
    ]
  })
}

# Attach the S3 policy to the IAM role
resource "aws_iam_role_policy_attachment" "attach_s3_policy" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.s3_policy.arn
}


# Defines Lambda function
resource "aws_lambda_function" "lambda_function" {
  function_name    = "my_lambda_function_name"  
  role             = aws_iam_role.lambda_role.arn
  runtime          = "nodejs18.x"
  handler          = "index.handler"
  filename         = "./lambda_function.zip"
  source_code_hash = filebase64sha256("./lambda_function.zip")
}

# Defines S3 Bucket for Lambda function
resource "aws_s3_bucket" "s3_bucket_lambda" {
  bucket = "my-unique-bucket-name-lambda"  
  acl    = "private"
}

# Configures Lambda permission to access S3 Bucket
resource "aws_lambda_permission" "s3_permission" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_function.arn
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::my-unique-bucket-name-lambda"
}

# Defines CloudFront distribution
resource "aws_cloudfront_distribution" "cloudfront_distribution" {
  origin {
    domain_name = aws_s3_bucket.s3_bucket_lambda.bucket_regional_domain_name
    origin_id   = "S3Origin"
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = "S3Origin"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  enabled             = true
  is_ipv6_enabled     = true

  # Adds a viewer_certificate block to enable HTTPS
  viewer_certificate {
    cloudfront_default_certificate = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}

# Output statement to display the URL of the Lambda function, S3 Bucket, and CloudFront distribution
output "lambda_function_url" {
  value = aws_lambda_function.lambda_function.invoke_arn
}

output "s3_bucket_url" {
  value = aws_s3_bucket.s3_bucket_lambda.bucket_regional_domain_name
}

output "cloudfront_url" {
  value = aws_cloudfront_distribution.cloudfront_distribution.domain_name
}
