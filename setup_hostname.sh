#!/bin/bash
# This script will rename every hostname of the device. The server device will
# be renamed to tegra-server; other client devices will be renamed to tegra-1,
# tegra-2, and so on. If you want a different naming schema, please change
# HOSTNAME_PREFIX, HOSTNAME_SERVER_SUFFIX, and HOSTNAME_CLIENT_SUFFIX.

# Get the constants
source ./constants.sh
# Get valid IPs
bash ./get_valid_ips.sh
# Ask user whether to continue
echo 'This script is going to set up hostname in each IP listed above'
read -r -p "Continue? [Y/n] " response
if [[ ($response =~ ^[nN]$) ]]; then
	exit 1
fi
# Connect to each IP and edit host files
client_id=1
while IFS= read -r ip; do
	# Print the separator
	printf '%20s\n' | tr ' ' -
	# Print the current IP
	echo "IP: $ip"
	# Determine the host
	host="$USERNAME@$ip"
	# Determine the hostname
	HOSTNAME="$HOSTNAME_PREFIX"
	if [ "$ip" == "$SERVER_IP" ]; then
		HOSTNAME="${HOSTNAME}${HOSTNAME_SERVER_SUFFIX}"
	else
		HOSTNAME="${HOSTNAME}${HOSTNAME_CLIENT_SUFFIX}${client_id}"
		((client_id += 1))
	fi
	echo "The host name is $HOSTNAME"
	# Execute the script on the device
	ssh -T "$host" <<- SSH_EOF
		# Switch to the root
		echo "$PASSWORD" | sudo -S su
		# Backup the host files
		sudo cp '/etc/hostname' '/etc/hostname.old'
		sudo cp '/etc/hosts' '/etc/hosts.old'
		# Write the host files
		sudo tee '/etc/hostname' <<- EOF
			$HOSTNAME
		EOF
		sudo tee '/etc/hosts' <<- EOF
			127.0.0.1 localhost
			127.0.1.1 $HOSTNAME
		EOF
		# Set the hostname temporarily
		sudo hostnamectl set-hostname "$HOSTNAME"
	SSH_EOF
done < "$FILENAME_IP"
# Clean up
bash ./cleanup.sh