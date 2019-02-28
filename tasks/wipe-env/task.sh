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
  -var "dns_zone_name=dontcare" \
  -var "dns_zone_dns_name=dontcare" \
  -var "pks_cluster_name=dontcare" \
  -var "buckets_location=dontcare" \
  -var "dns_suffix=dontcare" \
  -var "ssl_cert=dontcare" \
  -var "ssl_private_key=dontcare" \
  -var "global_lb=1" \
  -var "zones=dontcare" \
  -var "create_gcs_buckets=dontcare" \
  -state-out $root/wipe-output/terraform.tfstate \
  environment-automation/terraform
