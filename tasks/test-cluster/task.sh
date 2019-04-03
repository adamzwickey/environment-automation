#!/bin/bash
# Source: https://github.com/pivotalservices/concourse-pipeline-samples/blob/master/tasks/pcf/pks/configure-pks-cli-user/task.sh
set -eu
export ROOT_DIR=`pwd`
apt-get update -y && apt-get install -y curl jq

mv $ROOT_DIR/pks-cli/$PKS_CLI_PREFIX $ROOT_DIR/pks
chmod u+x $ROOT_DIR/pks

#Finally We test it
apt-get install -y apt-transport-https
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | tee -a /etc/apt/sources.list.d/kubernetes.list
apt-get update
apt-get install -y kubectl

$ROOT_DIR/pks login -a $PKS_SYSTEM_DOMAIN -u $PKS_CLI_USERNAME -p $PKS_CLI_PASSWORD -k
$ROOT_DIR/pks get-credentials $PKS_CLUSTER_NAME
kubectl cluster-info
