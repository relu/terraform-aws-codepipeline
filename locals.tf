locals {
  pipeline_bucket = var.create_pipeline_bucket ? aws_s3_bucket.pipeline_bucket.0.bucket : var.pipeline_bucket
}
