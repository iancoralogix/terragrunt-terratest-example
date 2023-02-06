terraform {
  before_hook "copy_test_directory_to_cwd" {
    commands = ["apply", "plan"]
    execute  = ["cp", "-r", "${local.test_directory}", "."]
  }

  before_hook "copy_examples_directory_to_cwd" {
    commands = ["apply", "plan"]
    execute  = ["cp", "-r", "${local.examples_directory}", "."]
  }

  before_hook "copy_scripts_directory_to_cwd" {
    commands = ["apply", "plan"]
    execute  = ["cp", "-r", "${local.scripts_directory}", "."]
  }

  before_hook "copy_envcommon_directory_to_cwd" {
    commands = ["apply", "plan"]
    execute  = ["cp", "-r", "${local.envcommon_directory}", "."]
  }

  before_hook "copy_terragrunt_file_to_cwd" {
    commands = ["apply", "plan"]
    execute  = ["cp", "${local.root_terragrunt_file}", "."]
  }

  before_hook "run_tests" {
    commands = ["apply", "plan"]
    execute  = ["bash", "scripts/terragrunt_before_hooks_test_helper.sh"]
  }

  before_hook "rm_test_directory_from_cwd" {
    commands = ["apply", "plan"]
    execute  = ["rm", "-rf", "tests"]
  }

  before_hook "rm_examples_directory_from_cwd" {
    commands = ["apply", "plan"]
    execute  = ["rm", "-rf", "examples"]
  }

  before_hook "rm_scripts_directory_from_cwd" {
    commands = ["apply", "plan"]
    execute  = ["rm", "-rf", "scripts"]
  }

  before_hook "rm_envcommon_directory" {
    commands = ["apply", "plan"]
    execute  = ["rm", "-rf", "_envcommon"]
  }

  before_hook "rm_terragrunt_file" {
    commands = ["apply", "plan"]
    execute  = ["rm", "terragrunt.hcl"]
  }
}

locals {
  test_directory       = "${dirname(find_in_parent_folders())}/tests"
  examples_directory   = "${dirname(find_in_parent_folders())}/examples"
  scripts_directory    = "${dirname(find_in_parent_folders())}/scripts"
  envcommon_directory  = "${dirname(find_in_parent_folders())}/_envcommon"
  root_terragrunt_file = "${dirname(find_in_parent_folders())}/terragrunt.hcl"
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
  environment = "development"
}
