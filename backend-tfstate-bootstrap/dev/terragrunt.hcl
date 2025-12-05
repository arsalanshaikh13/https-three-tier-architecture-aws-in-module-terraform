

# backend-tfstate-bootstrap/terragrunt.hcl
terraform {
  # source = "${get_repo_root()}/modules/backend-tfstate-bootstrap"
  source = "tfr://gitlab.com/arsalanshaikh13/tf-modules-panda-user-data/aws//backend-tfstate-bootstrap?version=1.1.0-accepting-files"
  # Notice the git:: prefix and the https protocol
  # source = "git::https://gitlab.com/arsalanshaikh13/tf-modules-panda-user-data.git//modules/backend-tfstate-bootstrap?ref=main"
  # source = "git::ssh://git@gitlab.com/arsalanshaikh13/tf-modules-panda-user-data.git//modules/backend-tfstate-bootstrap?ref=main"
  # source = "git::https://github.com/arsalanshaikh13/https-three-tier-architecture-aws-in-module-terraform.git//modules/backend-tfstate-bootstrap?ref=v1-terragrunt"
  # source = "git::ssh://git@github.com/arsalanshaikh13/https-three-tier-architecture-aws-in-module-terraform.git//modules/backend-tfstate-bootstrap?ref=v1-terragrunt"



  # Run automatically before any other folder
  before_hook "pre_plan" {
    commands = ["plan"]
    execute  = ["bash", "-c", "echo '✅ Terraform backend bucket and DynamoDB planned successfully'"]
  }
  before_hook "pre_apply" {
    commands = ["apply"]
    execute  = ["bash", "-c", "echo '✅ Terraform backend bucket and DynamoDB is being created'"]
  }
  after_hook "post_apply" {
    commands = ["apply"]
    execute  = ["bash", "-c", "echo '✅ Terraform backend bucket and DynamoDB is created successfully '"]
  }
  after_hook "post_backend_destroy" {
    commands = ["destroy"]
    execute  = ["bash", "-c", "echo '✅ Terraform backend bucket and DynamoDB deleted successfully'"]
  }

}

locals {

  config_hcl          = read_terragrunt_config("${get_repo_root()}/configuration/dev/config.hcl")
  region              = local.config_hcl.locals.region
  backend_bucket_name = local.config_hcl.locals.backend_bucket_name
  dynamodb_table      = local.config_hcl.locals.dynamodb_table
  environment         = local.config_hcl.locals.environment

  # terraform_required_version    = local.config_hcl.locals.terraform_required_version
  # aws_provider_version      = local.config_hcl.locals.aws_provider_version
  provider_version = local.config_hcl.locals.provider_version
}

# Automatically generate provider.tf for all subfolders
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
terraform {
  required_version = "${local.provider_version["terraform"]}"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "${local.provider_version["aws"]}"
    }
  }
}

provider "aws" {
  region = "${local.region}"
}
EOF
}


inputs = {
  backend_bucket_name = local.backend_bucket_name
  dynamodb_table      = local.dynamodb_table
  region              = local.region
  environment         = local.environment
}