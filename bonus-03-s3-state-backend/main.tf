resource "aws_s3_bucket" "tf_backend_state_bucket" {
  bucket = var.unique_bucket_name
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_versioning" "tf_backend_state_bucket_versioning" {
  bucket = aws_s3_bucket.tf_backend_state_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tf_backend_state_bucket_encryption" {
  bucket = aws_s3_bucket.tf_backend_state_bucket.id

  # Enable server-side encryption with Amazon S3 managed keys (SSE-S3)
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "AES256"
    }
  }
}

# for locking state changes

# resource "aws_dynamodb_table" "tf_remote_state_locking" {
#   hash_key = "LockID"
#   name = "terraform-s3-backend-locking"
#   attribute {
#     name = "LockID"
#     type = "S"
#   }
#   billing_mode = "PAY_PER_REQUEST"
# }