terraform {
  source = "git@github.com:iangrunt/terraform-fake-modules.git//modules/aws/eks?ref=main"
}

locals {
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  region      = local.region_vars.locals.region
}


dependency "vpc" {
  config_path = "${get_terragrunt_dir()}/../vpc"

  mock_outputs_allowed_terraform_commands = ["validate"]
  mock_outputs = {
    id = "vpc-fake123"
  }
}

inputs = {

  vpc_id = dependency.vpc.outputs.id

  tags = {
    "region_all_caps" = upper(local.region)
    "region_reversed" = strrev(local.region)
    "Terragrunt"      = "true"
    "Terraform"       = "true"
  }
}
