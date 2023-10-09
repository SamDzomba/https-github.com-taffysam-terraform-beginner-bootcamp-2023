
resource "random_string" "bucket_name" {
  length  = 32
  special = false
}

resource "aws_s3_bucket" "bootcamp3" {
 bucket = "77e8fc20-5f21-4b38-872b-ab8adfb49ed5"
}

resource "aws_s3_bucket" "website_bucket" {
  bucket = var.bucket_name
  tags = {
    Useruuid = var.user_uuid
  }
}

data "aws_caller_identity" "current" {}


#resource "aws_s3_bucket" "static_website" {
#  bucket = aws_s3_bucket.bucket_name
#}

#resource "aws_s3_bucket" "bootcamp" {
#  bucket = "87e8fc20-5f21-4b38-872b-ab8adfb49ed5"
#}

#resource "aws_s3_bucket" "bootcamp2" {
#  bucket = "22e8fc20-5f21-4b38-872b-ab8adfb49ed5"
#}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_website_configuration
resource "aws_s3_bucket_website_configuration" "website_configuration" {
bucket = "87e8fc20-5f21-4b38-872b-ab8adfb49ed5"

index_document {
    suffix = "index.html"
 }

error_document {
    key = "error.html"
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_object
resource "aws_s3_object" "index_html" {
  bucket = "87e8fc20-5f21-4b38-872b-ab8adfb49ed5"
  key    = "index.html"
  source = var.index_html_file_path
  
  #source = "${path.root}/public.index.html"
  
 # The filemd5() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the md5() function and the file() function:
  etag = file(var.index_html_file_path)
  # etag = filemd5("path/to/file")
}

resource "aws_s3_object" "error_html" {
  bucket = "87e8fc20-5f21-4b38-872b-ab8adfb49ed5"
  key    = "error.html"
  source = var.error_html_file_path
}
  
resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.website_bucket.bucket_name
  policy = jsonencode({
    "Version" = "2012-10-17",
    "Statement" = [
      {
        "Effect" = "Allow",
        "Principal" = {
          "Service" = "cloudfront.amazonaws.com"
        },
        "Action" = "s3:GetObject",
        "Resource" = "arn:aws:s3:::${aws_s3_bucket.website_bucket.id}/*",
        "Condition" = {
          "StringEquals" = {
            "AWS:SourceArn" = "arn:aws:cloudfront::${data.aws_caller_identity.current.account_id}:distribution/${aws_cloudfront_distribution.s3_distribution.id}"
          }
        }
      }
    ]
  })
}

resource "aws_cloudfront_distribution" "website_distribution" {
  
}