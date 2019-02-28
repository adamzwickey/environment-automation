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
  -var "dns_suffix=${GCP_DNS_ZONE_DNS_NAME}" \
  -var "ssl_cert=${SSL_CERT}" \
  -var "ssl_private_key=${SSL_PRIVATE_KEY}" \
  -var "global_lb=1" \
  -var "zones=${AZ_LIST}" \
  -var "create_gcs_buckets=${CREATE_GCS_BUCKETS}" \
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
pks_api_lb=$(echo $output_json | jq --raw-output '.pks_api_load_balancer_name.value')
pks_cluster1_lb=$(echo $output_json | jq --raw-output '.pks_cluster1_load_balancer_name.value')
env_name=$(echo $output_json | jq --raw-output '.env_name.value')
infra_subnet=$(echo $output_json | jq --raw-output '.infra_network_name.value')
buildpacks_bucket=$(echo $output_json | jq --raw-output '.buildpacks_bucket.value')
resources_bucket=$(echo $output_json | jq --raw-output '.resources_bucket.value')
packages_bucket=$(echo $output_json | jq --raw-output '.packages_bucket.value')
droplets_bucket=$(echo $output_json | jq --raw-output '.droplets_bucket.value')

wget https://github.com/cloudfoundry-incubator/credhub-cli/releases/download/2.2.1/credhub-linux-2.2.1.tgz
tar -zxvf credhub-linux-2.2.1.tgz
./credhub --version
./credhub set --name="${PREFIX}/om_public_ip" --type="value" --value="${pub_ip_opsman}"
./credhub set --name="${PREFIX}/bosh_public_ip" --type="value" --value="${pub_ip_bosh}"
./credhub set --name="${PREFIX}/bosh_lb" --type="value" --value="${bosh_lb}"
./credhub set --name="${PREFIX}/pks_api_lb" --type="value" --value="${pks_api_lb}"
./credhub set --name="${PREFIX}/pks_cluster1_lb" --type="value" --value="${pks_cluster1_lb}"
./credhub set --name="${PREFIX}/env_name" --type="value" --value="${env_name}"
./credhub set --name="${PREFIX}/infra_subnet" --type="value" --value="${infra_subnet}"
./credhub set --name="${PREFIX}/ssl_certificate" --type="value" --value="${SSL_CERT}"
./credhub set --name="${PREFIX}/ssl_private_key" --type="value" --value="${SSL_PRIVATE_KEY}"
./credhub set --name="${PREFIX}/buildpacks_bucket" --type="value" --value="${buildpacks_bucket}"
./credhub set --name="${PREFIX}/resources_bucket" --type="value" --value="${resources_bucket}"
./credhub set --name="${PREFIX}/packages_bucket" --type="value" --value="${packages_bucket}"
./credhub set --name="${PREFIX}/droplets_bucket" --type="value" --value="${droplets_bucket}"
