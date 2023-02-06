package test

import (
	"os"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
)

func TestVPC(t *testing.T) {

	// Copy the examples directory we'll use for testing to a template location. We have to do this for a few reasons:
	//  - if we run `terragrunt apply` from `development/us-east-2/vpc` once, it will work great. But if we try again,
	//    it will fail due to trying to copy a bunch of hidden .terragrunt-cache files left over in the `examples/`
	//    directory from the first run.
	//  - we have to do copy the `tests/`, `examples/`, and a helper script to the from our `terragrunt.hcl` in the VPC
	//    module that runs the tests, because that's where the before_hooks run from.
	//  - the issue with that is, apparently Go has had issues resolving paths inside of hidden folders. I initially
	//    was hardcoding the TerraformDir to get around this, but then discovered the first issue.
	//    https://github.com/golang/go/issues/54221.
	//  - the VPC module itself has a TON of before_hooks in it which are a super hack, could all be wrapped in up
	//    a script or something.

	// Taken from https://github.com/gruntwork-io/terratest/blob/master/modules/test-structure/test_structure.go#L56-L68
	// Root folder where terraform files should be (relative to the test folder)
	rootFolder := ".."

	// Relative path to terraform module being tested from the root folder
	terraformFolderRelativeToRoot := "examples/us-west-2/vpc"

	// temporary location that has to not be in a hidden folder?
	terraformFolderDest, err := os.MkdirTemp("", "example-terragrunt-testing-tmp")
	if err != nil {
		panic(err)
	}

	// clean the temp location up to store the test and module
	defer os.Remove(terraformFolderDest)

	// Copy the terraform folder to a temp folder
	tempTestFolder := test_structure.CopyTerraformFolderToDest(t, rootFolder, terraformFolderRelativeToRoot, terraformFolderDest)

	// Make sure to use the temp test folder in the terraform options
	terraformOptions := &terraform.Options{
		TerraformDir:    tempTestFolder,
		TerraformBinary: "terragrunt",
	}

	defer terraform.TgDestroyAllE(t, terraformOptions)

	defer os.Remove(terraformFolderDest)

	terraform.TgApplyAllE(t, terraformOptions)

	test_region := terraform.Output(t, terraformOptions, "aws_region")
	assert.Equal(t, "us-west-2", test_region)
}
