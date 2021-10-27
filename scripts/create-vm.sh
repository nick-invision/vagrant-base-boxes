name="bigsur"
ostype="MacOS_64"
cpus="4"
memory="8192"
vram="128"
storage_controller="SATA"

VBoxManage unregistervm $name --delete

VBoxManage createvm --name $name --ostype $ostype --register

VBoxManage modifyvm $name \
  --cpus $cpus \
  --memory $memory \
  --vram $vram \
  --pae on \
  --boot1 none \
  --boot2 none \
  --boot3 none \
  --boot4 none \
  --firmware efi \
  --rtcuseutc on \
  --chipset ich9 \
  --mouse usbtablet \
  --keyboard usb \
  --audiocontroller hda \
  --audiocodec stac9221 \
  --audio none \
  --nic1 nat

VBoxManage storagectl "$name" --name $storage_controller --add sata --bootable on --hostiocache on
VBoxManage storageattach "$name" --storagectl $storage_controller --port 1 --hotpluggable-on --type hdd --nonrotational on
VBoxManage storageattach "${name}" --storagectl $storage_controller --port 2 --type dvddrive