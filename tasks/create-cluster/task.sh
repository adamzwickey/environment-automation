#!/bin/bash
# Source: https://github.com/pivotalservices/concourse-pipeline-samples/blob/master/tasks/pcf/pks/configure-pks-cli-user/task.sh
set -eu

export ROOT_DIR=`pwd`

mv $ROOT_DIR/pks-cli/$PKS_CLI_PREFIX $ROOT_DIR/pks
chmod u+x $ROOT_DIR/pks

echo "Note - pre-requisite for this task to work:"
echo "- Your PKS API endpoint [${PKS_SYSTEM_DOMAIN}] should be routable and accessible from the Concourse worker(s) network."

echo "Connecting to PKS API [${PKS_SYSTEM_DOMAIN}]..."

set +e
check_dns_lookup=$(nslookup ${PKS_SYSTEM_DOMAIN})
if [ "$?" != "0" ]; then
  echo "Warning!! Unable to resolve ${PKS_SYSTEM_DOMAIN}"
  echo "Error!! Cannot proceed with cluster creation without being able to resolve ${PKS_SYSTEM_DOMAIN} to external IP: $PKS_UAA_SYSTEM_DOMAIN_IP"
  echo ""
  exit -1
fi
set -e

# login to PKS API
$ROOT_DIR/pks login -a $PKS_SYSTEM_DOMAIN -u $PKS_CLI_USERNAME -p $PKS_CLI_PASSWORD -k
pks_output=$($ROOT_DIR/pks clusters)
pks_status=$(echo $?)
if [ "$pks_status" != "0" ]; then
  echo "Problem interacting with PKS : $pks_status"
fi

cluster_check_output=$($ROOT_DIR/pks cluster $PKS_CLUSTER_NAME | grep UUID)
pks_status=$(echo $?)
if [ "$pks_status" != "0" ]; then
  echo "Creating PKS cluster : ${PKS_CLUSTER_NAME}"
  $ROOT_DIR/pks create-cluster $PKS_CLUSTER_NAME -e $PKS_CLUSTER_NAME.$PKS_SYSTEM_DOMAIN -p $PKS_CLUSTER_PLAN -n $PKS_CLUSTER_NODES
fi

finished=false
while ! $finished; do

  cluster_state=$($ROOT_DIR/pks cluster demo | grep "Last Action State:" | awk -F : '{print $2}' | tr -d "[:blank:]")
  echo "Cluster State: $cluster_state"

  if [ "$cluster_state" == "succeeded" ]; then
    $ROOT_DIR/pks cluster demo
    finished=true
    exit 0
  fi

  if [ "$cluster_state" == "failed" ]; then
    $ROOT_DIR/pks cluster demo
    exit -1
  fi
  sleep 20s
done
