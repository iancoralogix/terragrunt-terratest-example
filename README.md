### Terratest running inside terragrunt

This repo is a working example of how to run Terratest via a Terragrunt `plan` or `apply` using `before_hook`s. It also includes some of the patterns followed at Gruntwork for layout out infrastructure-as-code.

### Quick start
```
cd development
aws-vault exec %YOUR_PROFILE% -- terragrunt run-all apply
```

And you should see the `go test` run occur, which will create a Virtual Private Cloud (VPC) in `us-west-2`, do a check, and then destroy itself before doing the actual Terragrunt `apply`.

### Background
The module `development/us-east-2/vpc` calls a few `before_hook`s to set up doing a `go test` inside what exists in the`tests/` directory which only has a single test for the VPC module. The Terraform modules called are all fake, and just use a `null_resource`. The purpose is to similate behaviors and outputs allowing for quick iterations on these types of examples without waiting for actual Amazon Web Servce (AWS) resoures to build. See more here: https://github.com/iangrunt/terraform-fake-modules.

The example works like this:

- Terragrunt is runs the configuration in `development/us-east-2/vpc` as either a `plan` or `apply`.
- The `terragrunt.hcl` file in `development/us-east-2/vpc` calls `before_hook`s to set up the test. Those hooks do the following:
  - Copy the `test/` directory in the root of this repository to the local Terragrunt cache. Specifically  `development/us-east-2/vpc/.terragrunt_cache` where all these `before_hook`s operate. Keep that in mind when writing these.
  - Copy the `examples/` directory into the current working directory, the Terragrunt cache. This is the actual Terragrunt and Terraform code that gets tested!
  - Copy the `scripts/` directroy as there's a little helper script in there that does the `go test` run. `go test` can't run directly from a `before_hook` because (?) `go test` is tricky to run recursively with `...` and needs to run in the actual module directory with the tests in it.
  - Copy the `_envcommon` directory to ineherit the global configurations of this repo.
  - Copy the root `terragrunt.hcl` directory to inherit the global values of this repo and not deal with having to write `provider` configurations.
- One set up in the current working directroy, the `.terragrunt_cache`, another `before_hook` calls that helper script that kicks off the tests.
- When the test completes, more `before_hooks` run and clean up _only the files and directories that Terragrunt copied into it_ and leave the rest of the usual stuff alone.
  - All this set up helps for smooth testing on a local machine or with a static runner. If ran on ephemeral workers this wouldn't be an issue, but if it didn't do that cleanup, it would throw errors on the next run of a Terragrunt `plan` or `apply`. Specifically, errors on the OS trying to copy some .git/* files. Not worth debugging, and easier just to `rm` the cruft, which also guarantees changes you make in the root of the directory are visible and always fresh.

The Terratest test function documentation in the code itself, as it's less relevant to the purpose of this example.
