#!/bin/bash
# Source: https://github.com/pivotalservices/concourse-pipeline-samples/blob/master/tasks/pcf/pks/configure-pks-cli-user/task.sh
set -eu

export ROOT_DIR=`pwd`

# Stop On-Demand SIs and PKS clusters

# Stop everything BUT cf

# Stop cf
