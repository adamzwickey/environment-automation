# environment-automation

## Preparing the IaaS
### GCP
Using a shell with GCloud CLI Execute the following:

- Create the network and subnet
```bash
export NETWORK_NAME=bosh-bootstrap
export NETWORK_SUBNET=bosh-bootstrap-subnet
export NETWORK_SUBNET_CIDR=10.0.0.0/26
export NETWORK_SUBNET_REGION=us-east1
export CONTROL_PLANE_FQDNS=controlplane.public.cloud.zwickey.net

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
export DNS_ZONE=zwickey-base
gcloud dns record-sets transaction start --zone $DNS_ZONE
gcloud dns record-sets transaction add $BOSH_BOOTSTRAP_PUBLIC_IP --name=$CONTROL_PLANE_FQDNS --ttl=300 --type=A --zone=$DNS_ZONE
gcloud dns record-sets transaction execute --zone $DNS_ZONE
```

## Deploy BOSH and Concourse
### GCP

- Prep your env vars
```bash
export NETWORK_SUBNET_CIDR=10.0.0.0/26
export NETWORK_SUBNET_GW=10.0.0.1
export BOSH_BOOTSTRAP_IP=10.0.0.2
export GCP_PROJECT=fe-azwickey
export GCP_CREDENTIALS_JSON=~/cloudfoundry/homelab/gcp/FE-azwickey-44b8446078ff.json
export GCP_ZONE=$NETWORK_SUBNET_REGION-b
export JUMPBOX_KEY=$(cat ~/.ssh/id_rsa.pub)
export CONTROLPLANE_CERT=~/cloudfoundry/homelab/certs/controlplane.public.cloud.zwickey.net/fullchain.pem
export CONTROLPLANE_KEY=~/cloudfoundry/homelab/certs/controlplane.public.cloud.zwickey.net/privkey.pem
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
 -o bosh-ops/ssl.yml \
 -v director_name=bosh-bootstrap \
 -v internal_cidr=$NETWORK_SUBNET_CIDR \
 -v internal_gw=$NETWORK_SUBNET_GW \
 -v internal_ip="$BOSH_BOOTSTRAP_IP" \
 -v external_ip=$BOSH_BOOTSTRAP_PUBLIC_IP \
 -v controlplane_fqdns=$CONTROL_PLANE_FQDNS \
 --var-file gcp_credentials_json=$GCP_CREDENTIALS_JSON \
 --var-file ca_key=$CONTROLPLANE_KEY \
 --var-file ca_cert=$CONTROLPLANE_CERT \
 -v project_id=$GCP_PROJECT \
 -v zone=$GCP_ZONE \
 -v tags=\[bosh\] \
 -v network=$NETWORK_NAME \
 -v subnetwork=$NETWORK_SUBNET \
 -v jumpbox_ssh.public_key="$JUMPBOX_KEY"

source ./bin/bosh-bootstrap-login.sh
source ./bin/credhub-login.sh
```

- Prepare GCP environment for concourse
```bash
export NETWORK_SUBNET_REGION=us-east1
export CONCOURSE_USERNAME=admin
export CONCOURSE_PASSWORD=TOP-SECRET
export CONCOURSE_FQDNS=concourse.fqdns
export CONCOURSE_WORKERS=1
export CREDHUB_CLIENT_SECRET=$(bosh int ./creds/bosh-bootstrap-creds.yml --path /credhub_admin_client_secret)
export CREDHUB_CA=$(bosh int ./creds/bosh-bootstrap-creds.yml --path /credhub_ca/certificate)

gcloud compute addresses create concourse \
    --region $NETWORK_SUBNET_REGION
export CONCOURSE_EXTERNAL_IP=$(gcloud compute addresses describe concourse --region $NETWORK_SUBNET_REGION | grep address: | awk '{print $2}')

export DNS_ZONE=zwickey-base
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
