terraform {
  source = "git@github.com:iangrunt/terraform-fake-modules.git//modules/aws/vpc?ref=main"
}

locals {
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  region      = local.region_vars.locals.region
}

inputs = {
  cidr_block = "10.222.0.0/18"

  tags = {
    "region_all_caps" = upper(local.region)
    "region_reversed" = strrev(local.region)
    "Terragrunt"      = "true"
    "Terraform"       = "true"
  }
}
