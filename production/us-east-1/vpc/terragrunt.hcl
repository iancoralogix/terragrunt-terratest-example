terraform {
}

include "root" {
  path = find_in_parent_folders()
}

include "global_parameters" {
  path   = "${dirname(find_in_parent_folders())}/_envcommon/vpc/global_parameters.hcl"
  expose = true
}

inputs = {
  name        = "gruntwork"
  environment = "production"
}
