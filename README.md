# environment-automation

## Preparing the IaaS
### GCP
Using a shell with GCloud CLI Execute the following:

- Create the network and subnet
```bash
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
```

- Create needed firewall rules
```bash
gcloud compute firewall-rules create all-internal \
    --network $NETWORK_NAME  \
    --allow all \
    --source-ranges $NETWORK_SUBNET_CIDR
gcloud compute firewall-rules create bosh \
    --network $NETWORK_NAME  \
    --allow=tcp:25555,tcp:8443,tcp:8844,tcp:4222,tcp:6868,tcp:22 \
    --target-tags bosh,bosh-bootstrap \
    --source-ranges 0.0.0.0/0    
gcloud compute firewall-rules create concourse \
    --network $NETWORK_NAME  \
    --allow=tcp:8080 \
    --target-tags concourse-web \
    --source-ranges 0.0.0.0/0
```

- Create a Bosh public IP
```bash
gcloud compute addresses create bosh-bootstrap \
    --region $NETWORK_SUBNET_REGION
export BOSH_BOOTSTRAP_PUBLIC_IP=$(gcloud compute addresses describe bosh-bootstrap --region $NETWORK_SUBNET_REGION | grep address: | awk '{print $2}')
```

## Deploy BOSH and Concourse
### GCP

- Prep your env vars
```bash
NETWORK_SUBNET_CIDR=10.0.0.0/24
NETWORK_SUBNET_GW=10.0.0.1
BOSH_BOOTSTRAP_IP=10.0.0.2
GCP_PROJECT=fe-azwickey
GCP_CREDENTIALS_JSON=~/cloudfoundry/homelab/gcp/FE-azwickey-44b8446078ff.json
GCP_ZONE=$NETWORK_SUBNET_REGION-b
JUMPBOX_KEY=$(cat ~/.ssh/id_rsa.pub)
```

- Deploy and alias bosh
```bash
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
```

- Prepare GCP environment for concourse
```bash
NETWORK_SUBNET_REGION=us-east1
CONCOURSE_USERNAME=admin
CONCOURSE_PASSWORD=TOP-SECRET
CONCOURSE_FQDNS=concourse.FQDNS
CONCOURSE_WORKERS=3
CREDHUB_CLIENT_SECRET=$(bosh int ./creds/bosh-bootstrap-creds.yml --path /credhub_admin_client_secret)
CREDHUB_CA=$(bosh int ./creds/bosh-bootstrap-creds.yml --path /credhub_ca/ca)

gcloud compute addresses create concourse \
    --region $NETWORK_SUBNET_REGION
CONCOURSE_EXTERNAL_IP=$(gcloud compute addresses describe concourse --region $NETWORK_SUBNET_REGION | grep address: | awk '{print $2}')

DNS_ZONE=zwickey-base
gcloud dns record-sets transaction start --zone $DNS_ZONE
gcloud dns record-sets transaction add $CONCOURSE_EXTERNAL_IP --name=$CONCOURSE_FQDNS --ttl=300 --type=A --zone=$DNS_ZONE
gcloud dns record-sets transaction execute --zone $DNS_ZONE
```

- Deploy Concourse
```bash
cat concourse-bosh-deployment/cluster/concourse.yml | yaml-patch -o concourse-ops/add-network.yml > concourse-result.yml

bosh deploy -d concourse concourse-result.yml \
   -l concourse-bosh-deployment/versions.yml \
   --vars-store creds/concourse-creds.yml \
   -o concourse-bosh-deployment/cluster/operations/basic-auth.yml \
   -o concourse-bosh-deployment/cluster/operations/scale.yml \
   -o concourse-bosh-deployment/cluster/operations/credhub.yml \
   -o concourse-ops/public-network.yml \
   -o concourse-ops/ssl-credhub.yml \
   --var local_user.username=$CONCOURSE_USERNAME \
   --var local_user.password=$CONCOURSE_PASSWORD \
   --var external_ip=$CONCOURSE_EXTERNAL_IP \
   --var external_url=http://$CONCOURSE_FQDNS:8080 \
   --var network_name=default \
   --var web_vm_type=default \
   --var db_vm_type=default \
   --var db_persistent_disk_type=db \
   --var worker_vm_type=concourse \
   --var deployment_name=concourse \
   --var web_instances=1 \
   --var worker_instances=$CONCOURSE_WORKERS \
   --var credhub_url=https://$BOSH_BOOTSTRAP_IP:8844 \
   --var credhub_client_id=credhub-admin \
   --var credhub_client_secret=$CREDHUB_CLIENT_SECRET \
   --var credhub_ca_cert=$CREDHUB_CA
```
