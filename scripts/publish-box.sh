#!/bin/bash

# much of this comes from https://github.com/ramsey/macos-vagrant-box/blob/master/create-box.sh

set -e

# paths
work_dir="$1"
metadata_file_path="${work_dir}/metadata.json"
box_path="$(pwd)/${work_dir}/package.box"
s3_bucket="vagrant-public-boxes"

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
provider=$(jq -r .box.provider ${metadata_file_path})
version=$(jq -r .release.version ${metadata_file_path})
description=$(jq -r .release.description ${metadata_file_path})

org="nick-invision"
org_box="${org}/${box_name}"

echo
echo "Box"
echo "  Name:             ${org_box}"
echo "  Description:      ${box_description}"
echo "  Provider:         ${provider}"
echo "Release"
echo "  Version:          ${version}"
echo "  Description:      ${description}"
if [[ -n "${checksum}" ]]; then
  echo "  Checksum:         ${checksum}"
fi


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

# curl \
#   --header "Authorization: Bearer $VAGRANT_CLOUD_TOKEN" \
#   --request DELETE \
#   "https://app.vagrantup.com/api/v1/box/${org}/${box_name}"

if ! vagrant cloud box show $org_box &> /dev/null
then
    printf "\n\nCreating box $org_box...\n"
    curl \
      --header "Content-Type: application/json" \
      --header "Authorization: Bearer $VAGRANT_CLOUD_TOKEN" \
      https://app.vagrantup.com/api/v1/boxes \
      --data "{ \"box\": { \"username\": \"${org}\", \"name\": \"${box_name}\", \"short_description\": \"${box_description}\", \"is_private\": false } }"
fi

printf "\n\nCreating new version...\n"
curl \
  --header "Content-Type: application/json" \
  --header "Authorization: Bearer $VAGRANT_CLOUD_TOKEN" \
  "https://app.vagrantup.com/api/v1/box/${org}/${box_name}/versions" \
  --data "{ \"version\": { \"version\": \"$version\", \"description\": \"$description\" } }"

printf "\n\nCreating provider...\n"
curl \
  --header "Content-Type: application/json" \
  --header "Authorization: Bearer $VAGRANT_CLOUD_TOKEN" \
  "https://app.vagrantup.com/api/v1/box/${org}/${box_name}/version/${version}/providers" \
  --data "{ \"provider\": { \"name\": \"${provider}\", \"checksum_type\":\"sha256\", \"checksum\":\"$checksum\" } }"

printf "\n\nExtracting the upload URL from the response...\n"
response=$(curl \
    --header "Authorization: Bearer $VAGRANT_CLOUD_TOKEN" \
 https://app.vagrantup.com/api/v1/box/${org}/${box_name}/version/${version}/provider/${provider}/upload)
upload_path=$(echo "$response" | jq .upload_path)

printf "\n\nUploading to %s...\n" "${upload_path}"
cmd="curl \"${upload_path}\" --request PUT --upload-file \"$box_path\""
printf "\n\ncommand:\n\n%s\n\n" "${cmd}"
"${cmd}"

# s3_path="${s3_bucket}/${box_name}/${version}/${provider}"
# printf "\n\nUploading to %s...\n" "${s3_path}"
# aws s3 cp ./package.box "s3://${s3_path}/" --region us-east-1 --endpoint-url "https://s3-accelerate.amazonaws.com"

printf "\n\nReleasing the version...\n"
curl \
  --header "Authorization: Bearer $VAGRANT_CLOUD_TOKEN" \
  "https://app.vagrantup.com/api/v1/box/${org}/${box_name}/version/${version}/release" \
  --request PUT