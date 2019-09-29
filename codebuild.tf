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

    dynamic "environment_variable" {
      for_each = var.codebuild_environment_variables
      iterator = env

      content {
        name  = env.key
        value = env.value
      }
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

    dynamic "environment_variable" {
      for_each = var.codebuild_environment_variables
      iterator = env

      content {
        name  = env.key
        value = env.value
      }
    }
  }
}
