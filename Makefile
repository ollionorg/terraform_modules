.PHONY: help new prep plan apply destroy clean


help:
	@echo "\
This makefile is intended to provide a bootstrap for Terraform workflow.\n\
It should only be used for Terraform versions 0.11 and later, as it\n\
automates the management of 'workspaces' with respect to Enterprise\n\
environments.\n\
\n\
The variable 'env' must be passed to most commands in order to specify\n\
a specific environment to operate on. This is done to provide a level\n\
of isolation in order to prevent environment collision. Environments\n\
are given their own statefiles via 'workspaces' and are managed via\n\
their own terraform variables file '<env>.tfvars'.\n\
\n\
Most commands mirror the builtin Terraform functions, such as: plan,\n\
apply, and destroy. The 'new' command is a shortcut for 'workspace new'\n\
and the 'clean' command is a convienence command for cleaning a local\n\
development environment of temporary files.\n\
\n\
Usage: make <help new plan apply destroy clean> (env=<environment>)\n\
  make help\n\
  make new env=<environment> region=<aws_region>\n\
  make plan env=<environment>\n\
  make apply env=<environment>\n\
  make destroy env=<environment>\n\
  make clean"


new:
	@if [ "$(env)" = "" ]; then echo "ERROR: You must specify an environment" && exit 1; fi;
	@if [ "$(region)" = "" ]; then echo "ERROR: You must specify a region" && exit 1; fi;
	terraform workspace new $(env)
	@echo 'region = "$(region)"' > $(env).tfvars

prep:
	@if [ "$(env)" = "" ]; then echo "ERROR: You must specify an environment" && exit 1; fi;
	rm -rf .terraform
	terraform init
	terraform get -update

plan: prep
	terraform workspace select $(env)
	terraform plan -var-file="$(env).tfvars"

apply: prep
	terraform workspace select $(env)
	terraform apply -var-file="$(env).tfvars" -auto-approve

destroy: prep
	terraform workspace select $(env)
	terraform destroy -var-file="$(env).tfvars"

clean: 
	rm -f  terraform.tfplan
	rm -f  destroy.tfplan
	rm -f  terraform.tfstate
	rm -rf terraform.tfstate.*
	rm -rf .terraform
