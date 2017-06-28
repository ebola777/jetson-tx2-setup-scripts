#!/bin/bash
# This script copies SSH public key to each client device from the server
# device. Because SSHPass is not installed by default, it will install first,
# then uninstall it in the end.

# Get constants
source ./constants.sh
# Get valid IPs
bash ./get_valid_ips.sh
# Ask user whether to continue
echo 'This script is going to set up OpenMPI'
read -r -p "Continue? [Y/n] " response
if [[ ($response =~ ^[nN]$) ]]; then
	exit 1
fi
# Install required tools on the server
server="$USERNAME@$SERVER_IP"
ssh -T "$server" <<- SSH_EOF
	# Switch to root
	echo "$PASSWORD" | sudo -S su
	# Install
	sudo apt-get update
	echo 'Y' | sudo -S apt-get install sshpass
SSH_EOF
# Copy SSH public key to each client from the server
success_ips=()
while IFS= read -r ip; do
	# Skip the server
	if [ "$ip" == "$SERVER_IP" ]; then
		continue
	fi
	# Print separator
	printf '%20s\n' | tr ' ' -
	# Print the client
	client="$USERNAME@$ip"
	echo "Client: $client"
	# Execute script on server
	ssh -T "$server" <<- SSH_EOF
		# Switch to root
		echo "$PASSWORD" | sudo -S su
		# Copy SSH public key to the client
		sshpass -p "$PASSWORD" ssh-copy-id -o StrictHostKeyChecking=no "$client"
	SSH_EOF
done < "$FILENAME_IP"
# Uninstall required tools on the server
ssh -T "$server" <<- SSH_EOF
	# Switch to root
	echo "$PASSWORD" | sudo -S su
	# Uninstall
	echo 'Y' | sudo -S apt-get --purge autoremove sshpass
SSH_EOF
# Clean up
bash ./cleanup.sh