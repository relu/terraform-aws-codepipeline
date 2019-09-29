module "example" {
  source = "../"

  pipeline_name = "example"
  pipeline_source_configuration = {
    Owner  = "relu"
    Repo   = "terraform-aws-codepipeline"
    Branch = "master"
  }

  pipeline_terraform_project_path = "./example"
}
