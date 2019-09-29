output "pipeline_name" {
  description = "CodePipeline project name"
  value       = var.pipeline_name
}

output "pipeline_terraform_version" {
  description = "Terraform version"
  value       = var.pipeline_terraform_version
}

output "pipeline_apply_require_approval" {
  description = "Require approval before apply"
  value       = var.pipeline_apply_require_approval
}

output "pipeline_artifacts_bucket" {
  description = "Pipeline artifacts bucket"
  value       = local.pipeline_bucket
}

output "pipeline_codepipeline_id" {
  description = "CodePipeline pipeline id"
  value       = aws_codepipeline.pipeline.id
}

output "pipeline_codepipeline_arn" {
  description = "CodePipeline pipeline arn"
  value       = aws_codepipeline.pipeline.arn
}

output "pipeline_codepipeline_role_name" {
  description = "CodePipeline pipeline role name"
  value       = aws_iam_role.pipeline_role.name
}

output "pipeline_codebuild_plan_project_id" {
  description = "CodeBuild Plan project id"
  value       = aws_codebuild_project.pipeline_plan_stage_project.id
}

output "pipeline_codebuild_plan_project_arn" {
  description = "CodeBuild Plan project arn"
  value       = aws_codebuild_project.pipeline_plan_stage_project.arn
}

output "pipeline_codebuild_plan_project_role_name" {
  description = "CodeBuild Plan project role name"
  value       = aws_iam_role.pipeline_plan_stage_role.name
}

output "pipeline_codebuild_apply_project_id" {
  description = "CodeBuild Apply project id"
  value       = aws_codebuild_project.pipeline_apply_stage_project.id
}

output "pipeline_codebuild_apply_project_arn" {
  description = "CodeBuild Apply project arn"
  value       = aws_codebuild_project.pipeline_apply_stage_project.arn
}

output "pipeline_codebuild_apply_project_role_name" {
  description = "CodeBuild Apply project role name"
  value       = aws_iam_role.pipeline_apply_stage_role.name
}
