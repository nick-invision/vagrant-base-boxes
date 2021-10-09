#!/usr/bin/bash

vagrantfile="package.Vagrantfile"
nvram_dest="macos.nvram"
nvram_key="BIOS NVRAM File=\""

# get virtualbox machine id
id=$(cat ./.vagrant/machines/default/virtualbox/id)

# find location of virtualbox NVRAM file
vminfo=$(VBoxManage showvminfo $id --machinereadable | grep "$nvram_key")

# trim leading key and trailing " from path
nvram_path=${vminfo#"$nvram_key"}
nvram_path=${nvram_path%\"}

# copy nvram file to this directory
echo "Copying NVRAM from $nvram_path to $nvram_dest"
cp "$nvram_path" "$nvram_dest"

# package to include both nvram file and vagrantfile
vagrant package --include $nvram_dest --vagrantfile $vagrantfile