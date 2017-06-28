#!/bin/bash
# NOTE: You need to manually reboot the client devices for changes to take
# effect.
# This script will install and configure NFS on every device. The server device
# will be installed nfs-kernel-server and set the configuration file
# /etc/exports; the other clients will be installed nfs-common and set the
# configuration file /etc/fstab. Then the corresponding commands will be issued
# for the changes to take effect without rebooting the system. You may want to
# restart the systems to verify.

# Get constants
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
	# Print separator
	printf '%20s\n' | tr ' ' -
	# Print current IP
	echo "IP: $ip"
	# Determine host
	host="$USERNAME@$ip"
	if [ "$ip" == "$SERVER_IP" ]; then
		# Server
		# Execute script on remote
		ssh -T "$host" <<- SSH_EOF
			# Switch to root
			echo "$PASSWORD" | sudo -S su
			# Create cloud folder
			mkdir /home/ubuntu/cloud
			# Install the package
			sudo apt-get update
			echo 'Y' | sudo -S apt-get install nfs-kernel-server
			# Write config
			sudo tee '/etc/exports' <<- EOF
				/home/ubuntu/cloud $IP_RANGE(rw,sync,no_subtree_check,no_root_squash)
			EOF
			# Reload the config
			sudo exportfs -ra
			sudo service nfs-kernel-server restart
		SSH_EOF
	else
		# Client
		# Execute script on remote
		ssh -T "$host" <<- SSH_EOF
			# Switch to root
			echo "$PASSWORD" | sudo -S su
			# Create cloud folder
			mkdir /home/ubuntu/cloud
			# Install the package
			sudo apt-get update
			echo 'Y' | sudo -S apt-get install nfs-common
			# Write config
			sudo tee '/etc/fstab' <<- EOF
				$SERVER_IP:/home/ubuntu/cloud /home/ubuntu/cloud auto noauto,x-systemd.automount 0 0
			EOF
			# Reload the config
			sudo mount -a
		SSH_EOF
	fi
done < "$FILENAME_IP"
# Clean up
bash ./cleanup.sh