variable "pipeline_name" {
  description = "The CodePipeline project name"
  type        = string
}

variable "pipeline_build_timeout" {
  description = "CodePipeline build timeout"
  type        = number
  default     = 5
}

variable "create_pipeline_bucket" {
  description = "Whether to create a new S3 bucket or use the one defined through `pipeline_bucket`"
  type        = bool
  default     = true
}

variable "pipeline_bucket" {
  description = "If provided, the CodePipeline will use this bucket to store artifacts"
  type        = string
  default     = ""
}

variable "pipeline_source_owner" {
  description = "The Source stage action owner"
  type        = string
  default     = "ThirdParty"
}

variable "pipeline_source_provider" {
  description = "The Source stage action provider"
  type        = string
  default     = "GitHub"
}

variable "pipeline_source_version" {
  description = "The Source stage action version"
  type        = string
  default     = "1"
}

variable "pipeline_source_configuration" {
  description = "The Source stage action configuration"
  type        = map
  default     = {}
}

variable "pipeline_apply_approval" {
  type    = bool
  default = true
}

variable "pipeline_terraform_version" {
  type    = string
  default = "0.12.9"
}

variable "pipeline_terraform_environment_variables" {
  type    = map
  default = {}
}

variable "pipeline_plan_stage_buildspec" {
  type    = string
  default = <<BUILDSPEC
  version: 0.2
  phases:
    install:
      runtime-versions:
        golang: 1.12
      commands:
        - curl -o /tmp/terraform.zip "https://releases.hashicorp.com/terraform/$${TERRAFORM_VERSION}/terraform_$${TERRAFORM_VERSION}_linux_amd64.zip"
        - unzip /tmp/terraform.zip -d /usr/bin/
    pre_build:
      commands:
        - terraform init -input=false
    build:
      commands:
        - terraform plan -input=false -out=tfplan
  artifacts:
    files:
      - '**/*'
  BUILDSPEC
}

variable "pipeline_apply_stage_buildspec" {
  type    = string
  default = <<BUILDSPEC
  version: 0.2
  phases:
    install:
      runtime-versions:
        golang: 1.12
      commands:
        - curl -o /tmp/terraform.zip "https://releases.hashicorp.com/terraform/$${TERRAFORM_VERSION}/terraform_$${TERRAFORM_VERSION}_linux_amd64.zip"
        - unzip /tmp/terraform.zip -d /usr/bin/
    build:
      commands:
        - terraform apply -input=false -auto-approve tfplan
  BUILDSPEC
}
