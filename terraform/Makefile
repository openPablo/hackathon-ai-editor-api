#!/usr/bin/env make
.PHONY: apply-prod apply-acc plan-acc plan-prod

plan-acc:
		@terraform init
		@terraform workspace select acc
		@terraform plan -var-file vars/acc.tfvars
plan-prod:
		@terraform init
		@terraform workspace select prod
		@terraform plan -var-file vars/prod.tfvars
apply-prod:
		@terraform init
		@terraform workspace select prod
		@terraform apply -var-file vars/prod.tfvars
apply-acc:
		@terraform init
		@terraform workspace select acc
		@terraform apply -var-file vars/acc.tfvars
