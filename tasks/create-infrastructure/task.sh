#!/bin/bash
set -eu

root=$PWD

terraform init environment-automation/terraform

terraform plan \
  -var "project=${GCP_PROJECT_ID}" \
  -var "region=${GCP_REGION}" \
  -var "service_account_key=${GCP_SERVICE_ACCOUNT_KEY}" \
  -out terraform.tfplan \
  -state terraform-state/terraform.tfstate \
  environment-automation/terraform

terraform apply \
  -state-out $root/create-infrastructure-output/terraform.tfstate \
  -parallelism=5 \
  terraform.tfplan
