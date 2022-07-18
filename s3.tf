####################################################
########## Frontend Web CDN Bucket #################
####################################################
resource "aws_s3_bucket" "web-frontend" {
  bucket = "${var.ProjectName}-web-frontend"
  tags = local.common_tags
}

resource "aws_s3_bucket_website_configuration" "web-frontend" {
  bucket = aws_s3_bucket.web-frontend.bucket

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_policy" "web-frontend_s3_policy" {
  bucket = aws_s3_bucket.web-frontend.id
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Deny",
      "Principal": "*",
      "Action": "*",
      "Resource": [
        "${aws_s3_bucket.web-frontend.arn}",
        "${aws_s3_bucket.web-frontend.arn}/*"
      ],
      "Condition": {
        "Bool": {
          "aws:SecureTransport": "false"
        }
      }
    },
    {
        "Effect": "Allow",
        "Principal": {
            "AWS": "arn:aws:iam::cloudfront:user/CloudFront Origin Access Identity ${aws_cloudfront_origin_access_identity.oai.id}"
        },
        "Action": "s3:GetObject",
        "Resource": "${aws_s3_bucket.web-frontend.arn}/*"
    }
  ]
}
POLICY
}

resource "aws_s3_bucket_public_access_block" "s3_bucket_level_public_block-web-frontend" {
  bucket = aws_s3_bucket.web-frontend.id

  block_public_acls   = true
  block_public_policy = true
  ignore_public_acls  = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "versioning_web-frontend_s3" {
  bucket = aws_s3_bucket.web-frontend.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "web-frontend" {
  bucket = aws_s3_bucket.web-frontend.bucket

  rule {
    id = "s3-data-retention"

    filter {
      prefix = "/"
    }

    noncurrent_version_expiration {
      noncurrent_days = 90
      newer_noncurrent_versions = 5
    }

    status = "Enabled"
  }
}

####################################################
################## ALB Logs Bucket #################
####################################################
resource "aws_s3_bucket" "alb-logs" {
  bucket = "${var.ProjectName}-${var.env}-alb-logs"
  tags = local.common_tags
}

resource "aws_s3_bucket_policy" "alb-logs_s3_policy" {
  bucket = aws_s3_bucket.alb-logs.id
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${var.elb-account-id}:root"
      },
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::${aws_s3_bucket.alb-logs.id}/${var.ProjectName}-alb/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
    },
    {
        "Effect": "Allow",
        "Principal": {
            "Service": "logdelivery.elb.amazonaws.com"
        },
        "Action": "s3:PutObject",
        "Resource": "arn:aws:s3:::${aws_s3_bucket.alb-logs.id}/${var.ProjectName}-alb/AWSLogs/${data.aws_caller_identity.current.account_id}/*",
        "Condition": {
            "StringEquals": {
                "s3:x-amz-acl": "bucket-owner-full-control"
            }
        }
    }
  ]
}
POLICY
}

resource "aws_s3_bucket_public_access_block" "s3_bucket_level_public_block-alb-logs" {
  bucket = aws_s3_bucket.alb-logs.id

  block_public_acls   = true
  block_public_policy = true
  ignore_public_acls  = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "versioning_alb-logs_s3" {
  bucket = aws_s3_bucket.alb-logs.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "alb-logs" {
  bucket = aws_s3_bucket.alb-logs.bucket

  rule {
    id = "s3-data-retention"

    filter {
      prefix = "/"
    }

    noncurrent_version_expiration {
      noncurrent_days = 90
      newer_noncurrent_versions = 5
    }

    status = "Enabled"
  }
}