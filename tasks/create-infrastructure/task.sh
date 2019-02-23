#!/bin/bash
set -eu

root=$PWD

export GOOGLE_CREDENTIALS=${GCP_SERVICE_ACCOUNT_KEY}
export GOOGLE_PROJECT=${GCP_PROJECT_ID}
export GOOGLE_REGION=${GCP_REGION}

terraform init environment-automation/terraform

terraform plan \
  -var "project=${GCP_PROJECT_ID}" \
  -var "region=${GCP_REGION}" \
  -var "dns_zone_name=${GCP_DNS_ZONE_NAME}" \
  -var "dns_zone_dns_name=${GCP_DNS_ZONE_DNS_NAME}" \
  -var "pks_cluster_name=${PKS_CLUSTER_NAME}" \
  -out terraform.tfplan \
  -state terraform-state/terraform.tfstate \
  environment-automation/terraform

terraform apply \
  -state-out $root/create-infrastructure-output/terraform.tfstate \
  -parallelism=5 \
  terraform.tfplan

cd $root/create-infrastructure-output
output_json=$(terraform output -json -state=terraform.tfstate)

#Store relevant vars in credhub
pub_ip_opsman=$(echo $output_json | jq --raw-output '.ops_manager_ip.value')
env_name=$(echo $output_json | jq --raw-output '.env_name.value')
infra_subnet=$(echo $output_json | jq --raw-output '.infra_network_name.value')

credhub --version
credhub set --name="${PREFIX}/om_public_ip" --type="value" --value="${pub_ip_opsman}"
credhub set --name="${PREFIX}/env_name" --type="value" --value="${env_name}"
credhub set --name="${PREFIX}/infra_subnet" --type="value" --value="${infra_subnet}"
