# terraform-aws-codepipeline

A Terraform module used to create Terraform Automation pipelines using AWS CodePipeline.

## Usage example


```hcl
module "example" {
  source = "git::https://github.com/relu/terraform-aws-codepipeline.git?ref=v1.0.0"

  pipeline_name = "example"
  pipeline_source_configuration = {
    Owner  = "yourname"
    Repo   = "your-terraform-repo"
    Branch = "master"
  }
}
```

## Doc generation

Code formatting and documentation for variables and outputs is generated using
[pre-commit-terraform
hooks](https://github.com/antonbabenko/pre-commit-terraform) which uses
[terraform-docs](https://github.com/segmentio/terraform-docs).

Follow [these
instructions](https://github.com/antonbabenko/pre-commit-terraform#how-to-install)
to install pre-commit locally.

And install `terraform-docs` with `go get github.com/segmentio/terraform-docs`
or `brew install terraform-docs`.

## License

MIT Licensed. See
[LICENSE](https://github.com/relu/terraform-aws-codepipeline/tree/master/LICENSE)
for full details.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| create\_pipeline\_bucket | Whether to create a new S3 bucket or use the one defined through `pipeline_bucket` | bool | `"true"` | no |
| pipeline\_apply\_require\_approval | Whether to require approval on the Apply stage | bool | `"true"` | no |
| pipeline\_apply\_stage\_buildspec | The Apply stage buildspec | string | `"  version: 0.2\n  phases:\n    install:\n      runtime-versions:\n        golang: 1.12\n      commands:\n        - curl -o /tmp/terraform.zip \"https://releases.hashicorp.com/terraform/$${TERRAFORM_VERSION}/terraform_$${TERRAFORM_VERSION}_linux_amd64.zip\"\n        - unzip /tmp/terraform.zip -d /usr/bin/\n    build:\n      commands:\n        - cd $${TERRAFORM_DIRECTORY}\n        - terraform apply -auto-approve tfplan\n  "` | no |
| pipeline\_apply\_stage\_role\_policy\_arn | Policy to attach to the Apply stage CodeBuild role assumed during execution | string | `"arn:aws:iam::aws:policy/AdministratorAccess"` | no |
| pipeline\_bucket | If provided, the CodePipeline will use this bucket to store artifacts | string | `""` | no |
| pipeline\_build\_timeout | CodePipeline build timeout | number | `"5"` | no |
| pipeline\_name | The CodePipeline project name | string | n/a | yes |
| pipeline\_plan\_stage\_buildspec | The Plan stage buildspec | string | `"  version: 0.2\n  phases:\n    install:\n      runtime-versions:\n        golang: 1.12\n      commands:\n        - curl -o /tmp/terraform.zip \"https://releases.hashicorp.com/terraform/$${TERRAFORM_VERSION}/terraform_$${TERRAFORM_VERSION}_linux_amd64.zip\"\n        - unzip /tmp/terraform.zip -d /usr/bin/\n    pre_build:\n      commands:\n        - cd $${TERRAFORM_DIRECTORY}\n        - terraform init\n    build:\n      commands:\n        - terraform plan -out=tfplan\n  artifacts:\n    files:\n      - '**/*'\n  "` | no |
| pipeline\_plan\_stage\_role\_policy\_arn | Policy to attach to the Plan stage CodeBuild role assumed during execution | string | `"arn:aws:iam::aws:policy/ReadOnlyAccess"` | no |
| pipeline\_source\_configuration | The Source stage action configuration | map | `{}` | no |
| pipeline\_source\_owner | The Source stage action owner | string | `"ThirdParty"` | no |
| pipeline\_source\_provider | The Source stage action provider | string | `"GitHub"` | no |
| pipeline\_source\_version | The Source stage action version | string | `"1"` | no |
| pipeline\_terraform\_environment\_variables | Environment variables available to terraform during execution | map | `{}` | no |
| pipeline\_terraform\_project\_path | Relative path to the terraform project. Change this if your terraform project is not located at the root. | string | `"."` | no |
| pipeline\_terraform\_version | The Terraform version | string | `"0.12.9"` | no |

## Outputs

| Name | Description |
|------|-------------|
| pipeline\_apply\_require\_approval | Require approval before apply |
| pipeline\_artifacts\_bucket | Pipeline artifacts bucket |
| pipeline\_codebuild\_apply\_project\_arn | CodeBuild Apply project arn |
| pipeline\_codebuild\_apply\_project\_id | CodeBuild Apply project id |
| pipeline\_codebuild\_apply\_project\_role\_name | CodeBuild Apply project role name |
| pipeline\_codebuild\_plan\_project\_arn | CodeBuild Plan project arn |
| pipeline\_codebuild\_plan\_project\_id | CodeBuild Plan project id |
| pipeline\_codebuild\_plan\_project\_role\_name | CodeBuild Plan project role name |
| pipeline\_codepipeline\_arn | CodePipeline pipeline arn |
| pipeline\_codepipeline\_id | CodePipeline pipeline id |
| pipeline\_codepipeline\_role\_name | CodePipeline pipeline role name |
| pipeline\_name | CodePipeline project name |
| pipeline\_terraform\_version | Terraform version |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
