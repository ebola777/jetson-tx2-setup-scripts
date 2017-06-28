#!/bin/bash
# This script copies SSH public key from the server device to all the client
# devices. Because SSHPass is not installed by default, it will install first,
# then uninstall it in the end.

# Get the constants
source ./constants.sh
# Get valid IPs
bash ./get_valid_ips.sh
# Ask user whether to continue
echo 'This script is going to copy SSH public keys to each IP listed above'
read -r -p "Continue? [Y/n] " response
if [[ ($response =~ ^[nN]$) ]]; then
	exit 1
fi
# Install the required tools on the server
server="$USERNAME@$SERVER_IP"
ssh -T "$server" <<- SSH_EOF
	# Switch to the root
	echo "$PASSWORD" | sudo -S su
	# Install
	sudo apt-get update
	echo 'Y' | sudo -S apt-get install sshpass
SSH_EOF
# Copy the SSH public key to each client from the server
success_ips=()
while IFS= read -r ip; do
	# Skip the server
	if [ "$ip" == "$SERVER_IP" ]; then
		continue
	fi
	# Print the separator
	printf '%20s\n' | tr ' ' -
	# Print the client
	client="$USERNAME@$ip"
	echo "Client: $client"
	# Execute the script on the client
	sshpass -p "$PASSWORD" ssh -T "$client" <<- SSH_EOF
		# Switch to the root
		echo "$PASSWORD" | sudo -S su
		# Backup the SSH config file
		sudo cp -n "/home/$USERNAME/.ssh/authorized_keys" "/home/$USERNAME/.ssh/authorized_keys.old"
	SSH_EOF
	# Execute the script on the server
	ssh -T "$server" <<- SSH_EOF
		# Switch to the root
		echo "$PASSWORD" | sudo -S su
		# Copy SSH public key to the client
		sshpass -p "$PASSWORD" ssh-copy-id -o StrictHostKeyChecking=no "$client"
	SSH_EOF
done < "$FILENAME_IP"
# Uninstall the required tools on the server
ssh -T "$server" <<- SSH_EOF
	# Switch to the root
	echo "$PASSWORD" | sudo -S su
	# Uninstall
	echo 'Y' | sudo -S apt-get --purge autoremove sshpass
SSH_EOF
# Clean up
bash ./cleanup.sh