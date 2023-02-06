SHELL := /usr/bin/env bash

export

.PHONY: .
help:
	@echo "Available targets:"
	@grep -E '^[a-zA-Z/_-]+%?:.*? .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m%s\n", $$1, $$2}'

.PHONY: .
tests/run: ## run all the Terratest tests in this repo, wrap command in aws-vault.
	cd tests && go mod tidy &&  go test

.PHONY: .
pre: ## shorthand for pre-commit run --all-files.
	pre-commit run --all-files

.PHONY: .
terragrunt/apply: ## run the development env to see the Terratest run in the VPC module, wrap command in aws-vault.
	cd development && terragrunt run-all apply --terragrunt-non-interactive

.PHONY: .
terragrunt/destroy: ## destroy the development env to see the Terratest run in the VPC module, wrap command in aws-vault.
	cd development && terragrunt run-all destroy --terragrunt-non-interactive

.PHONY: .
terragrunt/clean: ## clean up all the .terragrunt_cache dirs.
	find . -type d -name ".terragrunt-cache" -prune -exec rm -rf {} \;
