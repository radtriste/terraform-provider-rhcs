#!/usr/bin/env bash

script_dir_path=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)

case_nb=$1

if [ -z ${case_nb} ]; then
    echo "Please provder case number"
    exit 1
fi

new_path="${script_dir_path}/ocp-${case_nb}"

cp -r "${script_dir_path}"/0_default "${new_path}"

cd "${new_path}"

sed -i "s|tr-tf-default|tr-tf-${case_nb}|g" main.tf
