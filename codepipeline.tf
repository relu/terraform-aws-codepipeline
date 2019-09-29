resource "aws_s3_bucket" "pipeline_bucket" {
  count  = var.create_pipeline_bucket ? 1 : 0
  bucket = "${var.pipeline_name}-terraform-pipeline-artifacts"
  acl    = "private"
}

data "aws_kms_alias" "pipeline_s3_kms" {
  name = "alias/aws/s3"
}

data "aws_iam_policy_document" "pipeline_assume_role_policy" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "pipeline_role" {
  name               = "${var.pipeline_name}-role"
  assume_role_policy = data.aws_iam_policy_document.pipeline_assume_role_policy.json
}

data "aws_iam_policy_document" "pipeline_role_policy" {
  statement {
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetBucketVersioning",
      "s3:PutObject",
    ]

    resources = [
      "arn:aws:s3:::${local.pipeline_bucket}",
      "arn:aws:s3:::${local.pipeline_bucket}/*",
    ]
  }

  statement {
    actions = [
      "codebuild:BatchGetBuilds",
      "codebuild:StartBuild",
    ]

    resources = [
      "*"
    ]
  }
}

resource "aws_iam_role_policy" "pipeline_role_policy" {
  role   = aws_iam_role.pipeline_role.name
  policy = data.aws_iam_policy_document.pipeline_role_policy.json
}

resource "aws_codepipeline" "pipeline" {
  name     = var.pipeline_name
  role_arn = aws_iam_role.pipeline_role.arn

  artifact_store {
    location = local.pipeline_bucket
    type     = "S3"

    encryption_key {
      id   = data.aws_kms_alias.pipeline_s3_kms.arn
      type = "KMS"
    }
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = var.pipeline_source_owner
      provider         = var.pipeline_source_provider
      version          = var.pipeline_source_version
      output_artifacts = ["source_output"]

      configuration = var.pipeline_source_configuration
    }
  }

  stage {
    name = "Plan"

    action {
      name             = "Execute"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["plan_output"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.pipeline_plan_stage_project.name
      }
    }
  }

  stage {
    name = "Apply"

    dynamic "action" {
      for_each = var.pipeline_apply_approval ? [0] : []
      content {
        name      = "Approve"
        category  = "Approval"
        owner     = "AWS"
        provider  = "Manual"
        version   = "1"
        run_order = 1
      }
    }

    action {
      name            = "Execute"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      input_artifacts = ["plan_output"]
      version         = "1"
      run_order       = 5

      configuration = {
        ProjectName = aws_codebuild_project.pipeline_apply_stage_project.name
      }
    }
  }
}

data "aws_iam_policy_document" "pipeline_plan_stage_assume_role_policy" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "pipeline_plan_stage_role" {
  name               = "${var.pipeline_name}-plan-stage-role"
  assume_role_policy = data.aws_iam_policy_document.pipeline_plan_stage_assume_role_policy.json
}

data "aws_iam_policy_document" "pipeline_plan_stage_role_policy" {
  statement {
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetBucketVersioning",
      "s3:PutObject",
    ]

    resources = [
      "arn:aws:s3:::${local.pipeline_bucket}",
      "arn:aws:s3:::${local.pipeline_bucket}/*",
    ]
  }

  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = [
      "*"
    ]
  }
}

resource "aws_iam_role_policy" "pipeline_plan_stage_role_policy" {
  role   = aws_iam_role.pipeline_plan_stage_role.name
  policy = data.aws_iam_policy_document.pipeline_plan_stage_role_policy.json
}

resource "aws_iam_role_policy_attachment" "pipeline_plan_stage_readonly_policy_attachment" {
  role       = aws_iam_role.pipeline_plan_stage_role.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

resource "aws_codebuild_project" "pipeline_plan_stage_project" {
  name         = "${var.pipeline_name}-plan-stage"
  description  = "${var.pipeline_name} Plan stage"
  service_role = aws_iam_role.pipeline_plan_stage_role.arn

  source {
    type      = "CODEPIPELINE"
    buildspec = var.pipeline_plan_stage_buildspec
  }

  artifacts {
    type                = "CODEPIPELINE"
    artifact_identifier = "plan_output"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:2.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

    dynamic "environment_variable" {
      for_each = var.pipeline_terraform_environment_variables
      iterator = env

      content {
        name  = env.key
        value = env.value
      }
    }
    environment_variable {
      name  = "TERRAFORM_VERSION"
      value = var.pipeline_terraform_version
    }
  }
}

data "aws_iam_policy_document" "pipeline_apply_stage_assume_role_policy" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "pipeline_apply_stage_role" {
  name               = "${var.pipeline_name}-apply-stage-role"
  assume_role_policy = data.aws_iam_policy_document.pipeline_apply_stage_assume_role_policy.json
}

data "aws_iam_policy_document" "pipeline_apply_stage_role_policy" {
  statement {
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetBucketVersioning",
    ]

    resources = [
      "arn:aws:s3:::${local.pipeline_bucket}",
      "arn:aws:s3:::${local.pipeline_bucket}/*",
    ]
  }

  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = [
      "*"
    ]
  }
}

resource "aws_iam_role_policy" "pipeline_apply_stage_role_policy" {
  role   = aws_iam_role.pipeline_apply_stage_role.name
  policy = data.aws_iam_policy_document.pipeline_apply_stage_role_policy.json
}

resource "aws_iam_role_policy_attachment" "pipeline_apply_stage_readonly_policy_attachment" {
  role       = aws_iam_role.pipeline_apply_stage_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_codebuild_project" "pipeline_apply_stage_project" {
  name         = "${var.pipeline_name}-apply-stage"
  description  = "${var.pipeline_name} Apply stage"
  service_role = aws_iam_role.pipeline_apply_stage_role.arn

  source {
    type      = "CODEPIPELINE"
    buildspec = var.pipeline_apply_stage_buildspec
  }

  artifacts {
    type                = "CODEPIPELINE"
    artifact_identifier = "plan_output"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:2.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

    dynamic "environment_variable" {
      for_each = var.pipeline_terraform_environment_variables
      iterator = env

      content {
        name  = env.key
        value = env.value
      }
    }
    environment_variable {
      name  = "TERRAFORM_VERSION"
      value = var.pipeline_terraform_version
    }
  }
}
