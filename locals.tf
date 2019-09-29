locals {
  pipeline_bucket = var.create_pipeline_bucket ? aws_s3_bucket.pipeline_bucket.0.bucket : var.pipeline_bucket
  codebuild_environment_variables = {
    TERRAFORM_VERSION   = var.pipeline_terraform_version
    TERRAFORM_DIRECTORY = var.pipeline_terraform_project_path
    TF_CLI_ARGS         = "-no-color -input=false"
  }
}
