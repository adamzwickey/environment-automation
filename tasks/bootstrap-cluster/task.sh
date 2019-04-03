#!/bin/bash
# Source: https://github.com/pivotalservices/concourse-pipeline-samples/blob/master/tasks/pcf/pks/configure-pks-cli-user/task.sh
set -eu
export ROOT_DIR=`pwd`
apt-get update -y && apt-get install -y curl jq

mv $ROOT_DIR/pks-cli/$PKS_CLI_PREFIX $ROOT_DIR/pks
chmod u+x $ROOT_DIR/pks

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

export ROOT_DIR=`pwd`
export CLOUD_SDK_REPO="cloud-sdk-xenial"
echo "deb http://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
apt-get update -y && apt-get install -y google-cloud-sdk

echo $GCP_SERVICE_ACCOUNT_KEY > credential_key.json
gcloud auth activate-service-account --key-file=credential_key.json
gcloud config set project $GCP_PROJECT_ID

#Get cluster UUID
cluster_uuid=$(pks cluster demo | grep UUID | awk -F : '{print $2}' | tr -d "[:blank:]")
echo "Cluster UUID: $cluster_uuid"
