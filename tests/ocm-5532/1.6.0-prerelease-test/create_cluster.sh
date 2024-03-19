#!/usr/bin/env bash

script_dir_path=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)

source "${script_dir_path}"/prepare_env

terraform init -upgrade
terraform apply -auto-approve

if [ "$?" != "0" ]; then
    echo "Error while applying TF"
    exit 1
fi

rosa create operator-roles -c ${CLUSTER_NAME} -m auto -y
rosa create oidc-provider -c ${CLUSTER_NAME} -m auto -y
