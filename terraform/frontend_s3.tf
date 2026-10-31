# ===================== Frontend S3 Bucket ===================== 

resource "aws_s3_bucket" "frontend_s3" {
    bucket = "${local.environment}.${local.domain}"
    force_destroy = true  # Allow deletion of non-empty bucket
    
    tags = {
        Name        = "${var.app_name}-${local.environment}-frontend-s3-bucket"
        Environment = local.environment
    }
}

# ===================== Frontend S3 Bucket =====================



# ===================== Frontend S3 Bucket Configurations =====================

resource "aws_s3_bucket_versioning" "frontend_s3_versioning" {
    bucket = aws_s3_bucket.frontend_s3.id
    versioning_configuration {
        status = "Disabled"
    }
}

resource "aws_s3_bucket_public_access_block" "frontend_s3_public_access_block" {
    bucket = aws_s3_bucket.frontend_s3.id
    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "frontend_s3_ownership_controls" {
    bucket = aws_s3_bucket.frontend_s3.id
    rule {
        object_ownership = "BucketOwnerEnforced"
    }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "frontend_s3_encryption" {
    bucket = aws_s3_bucket.frontend_s3.id
    rule {
        apply_server_side_encryption_by_default {
            sse_algorithm = "AES256"
        }
    }
}

resource "aws_s3_bucket_website_configuration" "frontend_s3_website" {
    bucket = aws_s3_bucket.frontend_s3.id
    index_document {
        suffix = "index.html"
    }
    error_document {
        key = "error.html"
    }
}

# ===================== Frontend S3 Bucket Configurations =====================



# ===================== Frontend S3 Bucket Policies =====================

data "aws_iam_policy_document" "frontend_s3_policy_document" {
  statement {
    sid     = "AllowSpecificCloudFrontOnly"
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.frontend_s3.arn}/*"]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values = [aws_cloudfront_distribution.s3_distribution.arn]
    }
  }
}

resource "aws_s3_bucket_policy" "frontend_s3_policy" {
  bucket = aws_s3_bucket.frontend_s3.id
  policy = data.aws_iam_policy_document.frontend_s3_policy_document.json
}

# ===================== Frontend S3 Bucket Policies =====================
