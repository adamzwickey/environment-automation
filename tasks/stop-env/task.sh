#!/bin/bash
# Source: https://github.com/pivotalservices/concourse-pipeline-samples/blob/master/tasks/pcf/pks/configure-pks-cli-user/task.sh
set -eu
export ROOT_DIR=`pwd`
apt-get update -y && apt-get install -y curl jq

curl -L $BOSH_CLI_URL -o $ROOT_DIR/bosh
chmod u+x $ROOT_DIR/bosh

curl -L $OM_CLI_URL -o $ROOT_DIR/om
chmod u+x $ROOT_DIR/om

eval "$($ROOT_DIR/om \
       -t https://$OPSMAN_DOMAIN_OR_IP_ADDRESS \
       -u $OPSMAN_USERNAME \
       -p $OPSMAN_PASSWORD \
       --skip-ssl-validation \
       bosh-env)"
$ROOT_DIR/bosh login
export BOSH_NON_INTERACTIVE=true

# Stop On-Demand SIs and PKS clusters
service_instances=($($ROOT_DIR/bosh deployments | grep service-instance | awk '{print $1}'))
echo "Stopping Service Instances:"
length=${#service_instances[@]}
for ((i = 0; i != length; i++)); do
   echo "$i: ${service_instances[i]}"
   $ROOT_DIR/bosh -n stop --hard -d ${service_instances[i]}
done

# Stop everything BUT cf
deployments=($($ROOT_DIR/om \
              -t https://$OPSMAN_DOMAIN_OR_IP_ADDRESS \
              -u $OPSMAN_USERNAME \
              -p $OPSMAN_PASSWORD \
              --skip-ssl-validation \
              curl -p /api/v0/deployed/products \
              2>/dev/null \
              | jq -rc '.[] .guid' \
              | grep -v "cf-"
              | grep -v "bosh"))
echo "Stopping all deployments but CF:"
length=${#deployments[@]}
for ((i = 0; i != length; i++)); do
   echo "Stopping $i: ${deployments[i]}"
   $ROOT_DIR/bosh -n stop --hard -d ${deployments[i]}
done

# Stop cf
cf_deployment=($($ROOT_DIR/om \
              -t https://$OPSMAN_DOMAIN_OR_IP_ADDRESS \
              -u $OPSMAN_USERNAME \
              -p $OPSMAN_PASSWORD \
              --skip-ssl-validation \
              curl -p /api/v0/deployed/products \
              2>/dev/null \
              | jq -rc '.[] .guid' \
              | grep "cf-" \
              | wc -l ))
if [ "$cf_deployment" == "1" ]; then
  cf=($($ROOT_DIR/om \
                -t https://$OPSMAN_DOMAIN_OR_IP_ADDRESS \
                -u $OPSMAN_USERNAME \
                -p $OPSMAN_PASSWORD \
                --skip-ssl-validation \
                curl -p /api/v0/deployed/products \
                2>/dev/null \
                | jq -rc '.[] .guid' \
                | grep "cf-" ))
  echo "Stopping CF deployment: $cf"
  $ROOT_DIR/bosh -n stop --hard -d ${cf}
fi
