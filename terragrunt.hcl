# ---------------------------------------------------------------------------------------------------------------------
# TERRAGRUNT CONFIGURATION
# Terragrunt is a thin wrapper for Terraform that provides extra tools for working with multiple Terraform modules,
# remote state, and locking: https://github.com/gruntwork-io/terragrunt
# ---------------------------------------------------------------------------------------------------------------------

locals {
  # Automatically load project-level variables
  project_vars = read_terragrunt_config(find_in_parent_folders("project.hcl"))

  # Automatically load region-level variables
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  # Extract the variables we need for easy access
  aws_region   = local.region_vars.locals.aws_region

  default_tags = {
    ManagedBy   = "terraform"
    Project     = local.project_vars.locals.project_name
    Environment = local.environment_vars.locals.environment
  }
}


remote_state {
  backend = "s3"

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }

  config = {
    bucket = ""
    key    = "project/${path_relative_to_include()}/terraform.tfstate"
    region = ""

    profile = ""

    encrypt                  = false
    skip_bucket_versioning   = true
    skip_bucket_ssencryption = true
  }
}


generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF
  terraform {
    required_providers {
      aws = {
        source  = "hashicorp/aws"
        version = ">= 3.2"
      }
    }
  }


  provider "aws" {
    region  = "${local.aws_region}"
    profile = ""
  }
  EOF
}


generate "variables" {
  path = "variables.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF
  variable "project_name" {}
  variable "aws_region" {}
  variable "environment" {}
  variable "default_tags" { type = map(string) }
  EOF
}


# ---------------------------------------------------------------------------------------------------------------------
# GLOBAL PARAMETERS
# These variables apply to all configurations in this subfolder. These are automatically merged into the child
# `terragrunt.hcl` config via the include block.
# ---------------------------------------------------------------------------------------------------------------------

# Configure root level variables that all resources can inherit. This is especially helpful with multi-account configs
# where terraform_remote_state data sources are placed directly into the modules.
inputs = merge(
  local.project_vars.locals,
  local.region_vars.locals,
  local.environment_vars.locals,
  {
    default_tags = local.default_tags
  },
)