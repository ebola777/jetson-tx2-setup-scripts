#!/bin/bash
# This script will install and configure NFS on every device. The server device
# will be installed nfs-kernel-server and set the configuration file
# /etc/exports; the other clients will be installed nfs-common and set the
# configuration file /etc/fstab. The corresponding commands will be issued
# for the changes to take effect without rebooting the system on the server. The
# clients will be rebooted for the changes to take effect.

# Get the constants
source ./constants.sh
# Get valid IPs
bash ./get_valid_ips.sh
# Ask user whether to continue
echo 'This script is going to set up NFS in each IP listed above'
read -r -p "Continue? [Y/n] " response
if [[ ($response =~ ^[nN]$) ]]; then
	exit 1
fi
# Connect to each IP and set up NFS
while IFS= read -r ip; do
	# Print the separator
	printf '%20s\n' | tr ' ' -
	# Print the current IP
	echo "IP: $ip"
	# Determine the host
	host="$USERNAME@$ip"
	if [ "$ip" == "$SERVER_IP" ]; then
		# Server
		# Execute the script on the server
		ssh -T "$host" <<- SSH_EOF
			# Switch to the root
			echo "$PASSWORD" | sudo -S su
			# Create the cloud folder
			mkdir /home/$USERNAME/cloud
			# Install the package
			sudo apt-get update
			echo 'Y' | sudo -S apt-get install nfs-kernel-server
			# Backup the config file
			sudo cp -n '/etc/exports' '/etc/exports.old'
			# Write the config file
			sudo tee '/etc/exports' <<- EOF
				/home/$USERNAME/cloud $IP_RANGE(rw,sync,no_subtree_check,no_root_squash)
			EOF
			# Reload the config
			sudo exportfs -ra
			sudo service nfs-kernel-server restart
		SSH_EOF
	else
		# Client
		# Execute the script on the client
		ssh -T "$host" <<- SSH_EOF
			# Switch to the root
			echo "$PASSWORD" | sudo -S su
			# Create the cloud folder
			mkdir /home/$USERNAME/cloud
			# Install the package
			sudo apt-get update
			echo 'Y' | sudo -S apt-get install nfs-common
			# Backup the config file
			sudo cp -n '/etc/fstab' '/etc/fstab.old'
			# Write the config file
			sudo tee '/etc/fstab' <<- EOF
				$SERVER_IP:/home/$USERNAME/cloud /home/$USERNAME/cloud auto noauto,x-systemd.automount 0 0
			EOF
			# Reboot the client
			sudo reboot
		SSH_EOF
	fi
done < "$FILENAME_IP"
# Clean up
bash ./cleanup.sh