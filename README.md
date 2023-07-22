# OpenWRT-proxmox
script for installing an OpenWrt vm onto a proxmox server

This script should work provided you have ssh key-based authentication setup for the root user to your OpenWRT VM. If not, you might have trouble using ssh to execute commands on the VM. As I mentioned before, you might need to install the sshpass utility with apt-get install sshpass.

Again, as mentioned in the previous script, replace the placeholders like $VM_IP, $PROXMOX_NODE, and others with your actual values. Please ensure you are running this script as a user with sufficient permissions.
