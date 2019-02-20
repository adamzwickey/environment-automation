# environment-automation

## Preparing the IaaS
### GCP
- Using gcloud shell:
. create network and subnet
NETWORK_NAME=bosh-bootstrap
NETWORK_SUBNET=bosh-bootstrap-subnet
NETWORK_SUBNET_CIDR=10.0.0.0/24
NETWORK_SUBNET_REGION=us-east1

gcloud compute networks create $NETWORK_NAME \
    --subnet-mode=custom \
    --bgp-routing-mode=regional
gcloud compute networks subnets create $NETWORK_SUBNET \
    --network $NETWORK_NAME \
    --range=$NETWORK_SUBNET_CIDR \
    --region $NETWORK_SUBNET_REGION

. create fw rules
gcloud compute firewall-rules create all-internal \
    --network $NETWORK_NAME  \
    --allow all \
    --source-ranges $NETWORK_SUBNET_CIDR
gcloud compute firewall-rules create bosh \
    --network $NETWORK_NAME  \
    --allow=tcp:25555,tcp:8443,tcp:4222,tcp:6868,tcp:22 \
    --target-tags bosh,bosh-bootstrap \
    --source-ranges 0.0.0.0/0    

. create bosh public IP
gcloud compute addresses create bosh-bootstrap \
    --region $NETWORK_SUBNET_REGION \
export BOSH_BOOTSTRAP_PUBLIC_IP=$(gcloud compute addresses describe bosh-bootstrap --region $NETWORK_SUBNET_REGION | grep address: | awk '{print $2}')

## Deploy BOSH and Concourse
### GCP
NETWORK_SUBNET_CIDR=10.0.0.0/24
NETWORK_SUBNET_GW=10.0.0.1
BOSH_BOOTSTRAP_IP=10.0.0.2
GCP_PROJECT=fe-azwickey
GCP_CREDENTIALS_JSON=~/cloudfoundry/homelab/gcp/FE-azwickey-44b8446078ff.json
GCP_ZONE=$NETWORK_SUBNET_REGION-b
JUMPBOX_KEY=$(cat ~/.ssh/id_rsa.pub)

. deploy and alias bosh
bosh create-env bosh-deployment/bosh.yml \
 --state=state/state.json \
 --vars-store=creds/bosh-bootstrap-creds.yml \
 -o bosh-deployment/jumpbox-user.yml \
 -o bosh-deployment/uaa.yml \
 -o bosh-deployment/credhub.yml \
 -o bosh-deployment/gcp/cpi.yml \
 -o bosh-deployment/local-dns.yml \
 -o bosh-deployment/external-ip-not-recommended.yml \
 -o bosh-deployment/external-ip-not-recommended-uaa.yml \
 -v director_name=bosh-bootstrap \
 -v internal_cidr=$NETWORK_SUBNET_CIDR \
 -v internal_gw=$NETWORK_SUBNET_GW \
 -v internal_ip=$BOSH_BOOTSTRAP_IP \
 -v external_ip=$BOSH_BOOTSTRAP_PUBLIC_IP \
 --var-file gcp_credentials_json=$GCP_CREDENTIALS_JSON \
 -v project_id=$GCP_PROJECT \
 -v zone=$GCP_ZONE \
 -v tags=\[bosh\] \
 -v network=$NETWORK_NAME \
 -v subnetwork=$NETWORK_SUBNET \
 -v jumpbox_ssh.public_key="$JUMPBOX_KEY"

source ./bosh-bootstrap-login.sh

 . Deploy Concourse

 
