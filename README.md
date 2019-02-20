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
BOSH_BOOTSTRAP_IP=$(gcloud compute addresses describe bosh-bootstrap --region $NETWORK_SUBNET_REGION | grep address: | awk '{print $2}')
