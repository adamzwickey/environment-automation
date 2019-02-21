#!/bin/bash
set -eu

root=$PWD

export GOOGLE_CREDENTIALS=${GCP_SERVICE_ACCOUNT_KEY}
export GOOGLE_PROJECT=${GCP_PROJECT_ID}
export GOOGLE_REGION=${GCP_REGION}

terraform init environment-automation/terraform

echo "Deleting provisioned infrastructure..."
terraform destroy -force \
  -state $root/terraform-state/*.tfstate \
  -var "project=dontcare" \
  -var "region=dontcare" \
  -state-out $root/wipe-output/terraform.tfstate \
  environment-automation/terraform
