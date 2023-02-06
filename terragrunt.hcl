# This terragrunt.hcl is not run directly, instead you should run terragrunt from inside of the development
# or production directories. The purpose of this file being here is so find_in_parent_folders() will work
# without having to pass into any parameters, among many other things.

# Look up a few directories until we find a region.hcl
locals {
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  region      = local.region_vars.locals.region
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "aws" {
  region = "${local.region}"
}
EOF
}
