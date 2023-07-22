#!/bin/bash

# Define variables
VM_ID=123
VM_NAME="OpenWRT"
VM_MEMORY=256
VM_CPU=1
VM_DISK_SIZE="512M"
VM_NET="model=virtio,bridge=vmbr0"
STORAGE_NAME="local-lvm"
VM_IP="10.10.27.151"
PROXMOX_NODE="PVE"

# Create new VM
qm create $VM_ID --name $VM_NAME --memory $VM_MEMORY --net0 $VM_NET --cores $VM_CPU --ostype l26 --sockets 1

# Remove default hard drive
qm set $VM_ID --scsi0 none

# Lookup the latest stable version number
regex='<strong>Current Stable Release - OpenWrt ([^/]*)<\/strong>'
response=$(curl -s https://openwrt.org)
[[ $response =~ $regex ]]
stableVersion="${BASH_REMATCH[1]}"

# Download openwrt image
wget -O openwrt.img.gz https://downloads.openwrt.org/releases/$stableVersion/targets/x86/64/openwrt-$stableVersion-x86-64-generic-ext4-combined.img.gz

# Extract the openwrt img
gunzip ./openwrt.img.gz

# Rename the extracted img
mv ./openwrt*.img ./openwrt.raw

# Increase the raw disk to 512 MB
qemu-img resize -f raw ./openwrt.raw $VM_DISK_SIZE

# Import the disk to the openwrt vm
qm importdisk $VM_ID openwrt.raw $STORAGE_NAME

# Attach imported disk to VM
qm set $VM_ID --virtio0 $STORAGE_NAME:vm-$VM_ID-disk-0.raw

# Set boot disk
qm set $VM_ID --bootdisk virtio0

# Start the VM
qm start $VM_ID

# SSH into the VM, change IP address, and install Luci
sshpass -p "" ssh -o StrictHostKeyChecking=no root@$VM_IP << EOF
uci set network.lan.ipaddr='$VM_IP'
service network restart
opkg update
opkg install luci
EOF
