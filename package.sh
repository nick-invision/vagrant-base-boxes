#!/bin/bash

# much of this comes from https://github.com/ramsey/macos-vagrant-box/blob/master/create-box.sh

set -e

# paths
work_dir="$1"
checksum="$2"
metadata_file_path="${work_dir}/metadata.json"
box_path="$(pwd)/${work_dir}/package.box"

# validations
if [ -z $work_dir ]; then
  echo "Usage: ./package.sh <vagrantfile-directory>"
  exit 1
fi

if ! command -v sha256sum &> /dev/null
then
    echo "sha256sum could not be found. Try 'brew install coreutils' then update your .<shell>rc file PATH to include /usr/local/opt/coreutils/libexec/gnubin:"
    exit 1
fi

if [ -z "$VAGRANT_CLOUD_TOKEN" ]; then
  echo "VAGRANT_CLOUD_TOKEN environment variable must be set"
  exit 1
fi

if [ ! -f "$metadata_file_path" ]; then
  echo "Ensure ${metadata_file_path} exists"
  exit 1
fi

if [ ! -f "${box_path}" ]; then
    echo "Could not find the packaged box at ${box_path}. Did you forget to call 'vagrant package'?"
    exit 1
fi

# box details
box_name=$(jq -r .box.name ${metadata_file_path})
box_description=$(jq -r .box.description ${metadata_file_path})
version=$(jq -r .release.version ${metadata_file_path})
description=$(jq -r .release.description ${metadata_file_path})

org="nick-invision"
org_box="${org}/${box_name}"
provider="virtualbox"

echo
echo "Box"
echo "  Name:             ${org_box}"
echo "  Description:      ${box_description}"
echo "  Provider:         ${provider}"
echo "Release"
echo "  Version:          ${version}"
echo "  Description:      ${description}"

echo
read -p "Are these values correct? (y/N) " proceed
echo

if [[ "${proceed}" != "y" && "${proceed}" != "Y" ]]; then
    echo "Exiting, since you indicated the values are incorrect."
    exit 1
fi

echo "Proceeding..."
echo

cd $work_dir

if [ -z $checksum ]; then
  sha256=$(sha256sum -b -z "${box_path}")
  checksum=$(cut -d' ' -f1 <<< "${sha256}")
fi

echo "Checksum: ${checksum}"

if ! vagrant cloud box show $org_box &> /dev/null
then
    echo "Box $org_box not found on Vagrant Cloud, creating..."
    vagrant cloud box create \
      --no-private \
      --short-description "${box_description}" \
      "${org_box}"
fi

vagrant cloud version create \
    -d "${description}" \
    "${org_box}" \
    "${version}"

vagrant cloud provider create \
    --checksum "${checksum}" \
    --checksum-type "sha256" \
    "${org_box}" \
    "${provider}" \
    "${version}"

vagrant cloud provider upload \
    "${org_box}" \
    "${provider}" \
    "${version}" \
    "${box_path}"