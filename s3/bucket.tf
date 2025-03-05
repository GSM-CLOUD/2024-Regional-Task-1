resource "aws_s3_bucket" "s3_bucket" {
  bucket = "${var.prefix}-s3-gsm99-bucket"
  force_destroy = true
  tags = {
    "Name" = "${var.prefix}-s3-gsm99-bucket"
  }
}

resource "aws_s3_bucket_public_access_block" "s3_public_access" {
  bucket                  = aws_s3_bucket.s3_bucket.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "s3_bucket_policy" {
  bucket = aws_s3_bucket.s3_bucket.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.s3_bucket.arn}/*"
      }
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.s3_public_access]
}

resource "aws_s3_object" "user-app" {
  bucket = aws_s3_bucket.s3_bucket.id
  key = "user.zip"
  source = "${path.module}/app/user.zip"
  content_type = "application/zip"
}

resource "aws_s3_object" "token-app" {
  bucket = aws_s3_bucket.s3_bucket.id
  key = "token.zip"
  source = "${path.module}/app/token.zip"
  content_type = "application/zip"
}