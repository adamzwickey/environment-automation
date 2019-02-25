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
  -var "buckets_location=${GCP_REGION}" \
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
pub_ip_bosh=$(echo $output_json | jq --raw-output '.bosh_load_balancer_address.value')
bosh_lb=$(echo $output_json | jq --raw-output '.bosh_load_balancer_name.value')
env_name=$(echo $output_json | jq --raw-output '.env_name.value')
infra_subnet=$(echo $output_json | jq --raw-output '.infra_network_name.value')

wget https://github.com/cloudfoundry-incubator/credhub-cli/releases/download/2.2.1/credhub-linux-2.2.1.tgz
tar -zxvf credhub-linux-2.2.1.tgz
./credhub --version
./credhub set --name="${PREFIX}/om_public_ip" --type="value" --value="${pub_ip_opsman}"
./credhub set --name="${PREFIX}/bosh_public_ip" --type="value" --value="${pub_ip_bosh}"
./credhub set --name="${PREFIX}/bosh_lb" --type="value" --value="${bosh_lb}"
./credhub set --name="${PREFIX}/env_name" --type="value" --value="${env_name}"
./credhub set --name="${PREFIX}/infra_subnet" --type="value" --value="${infra_subnet}"
