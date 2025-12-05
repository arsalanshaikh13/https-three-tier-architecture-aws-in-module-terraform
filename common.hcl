locals {
  # Determine environment based on path
  environment = (
    length(regexall(".*/terraform_dev/.*", get_terragrunt_dir())) > 0 ? "dev" :
    length(regexall(".*/terraform_prod/.*", get_terragrunt_dir())) > 0 ? "prod" :
    "unknown"
  )
  
  # Load environment-specific config
  config_hcl          = read_terragrunt_config("${get_repo_root()}/configuration/${local.environment}/config.hcl")
  region              = local.config_hcl.locals.region
  backend_bucket_name = local.config_hcl.locals.backend_bucket_name
  dynamodb_table      = local.config_hcl.locals.dynamodb_table
  provider_version    = local.config_hcl.locals.provider_version
}

# Generate backend configuration
generate "backend" {
  path      = "backend.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  backend "s3" {
    bucket         = "${local.backend_bucket_name}"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "${local.region}"
    dynamodb_table = "${local.dynamodb_table}"
    encrypt        = true
    use_lockfile   = true
  }
}
EOF
}

# Generate provider configuration
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