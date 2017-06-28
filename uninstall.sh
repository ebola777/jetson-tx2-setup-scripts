#!/bin/bash
# This script will undo all the post configurations. It assumes
# setup_connection1.sh has been run successfully so that get_valid_ips.sh can
# work properly. If you haven't done so, please run setup_connection1.sh before
# running this script.

# Get the constants
source ./constants.sh
# Get valid IPs
bash ./get_valid_ips.sh
# Ask user whether to continue
echo 'This script is going to uninstall in each IP listed above'
read -r -p "Continue? [Y/n] " response
if [[ ($response =~ ^[nN]$) ]]; then
	exit 1
fi
# Connect to each IP and uninstall
while IFS= read -r ip; do
	# Print the separator
	printf '%20s\n' | tr ' ' -
	# Print the current IP
	echo "IP: $ip"
	# Determine the host
	host="$USERNAME@$ip"
	# Determine the hostname
	# Execute the script on the device
	ssh -T "$host" <<- SSH_EOF
		# Switch to the root
		echo "$PASSWORD" | sudo -S su
		# Restore the SSH config file
		sudo mv "/home/$USERNAME/.ssh/authorized_keys.old" "/home/$USERNAME/.ssh/authorized_keys"
		# Remove NFS packages
		if [ "$ip" == "$SERVER_IP" ]; then
			echo 'Y' | sudo -S apt-get --purge autoremove nfs-kernel-server
		else
			echo 'Y' | sudo -S apt-get --purge autoremove nfs-common
		fi
		# Restore the NFS config files
		if [ "$ip" == "$SERVER_IP" ]; then
			sudo mv '/etc/exports.old' '/etc/exports'
		else
			sudo mv '/etc/fstab.old' '/etc/fstab'
		fi
		# Restore the host files
		sudo mv '/etc/hostname.old' '/etc/hostname'
		sudo mv '/etc/hosts.old' '/etc/hosts'
		# Set the hostname temporarily
		sudo hostnamectl set-hostname "$HOSTNAME_ORIGINAL"
		# Reboot the device
		sudo reboot
	SSH_EOF
done < "$FILENAME_IP"
# Clean up
bash ./cleanup.sh