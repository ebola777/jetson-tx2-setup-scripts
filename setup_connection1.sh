#!/bin/bash
# This script copies SSH public key from your computer to all the Jetson
# devices. This script uses get_ip.sh instead of get_valid_ip.sh because
# get_valid_ip.sh only works after this process.

# Get the constants
source ./constants.sh
# Get IPs
bash ./get_ips.sh
# Ask user whether to continue
echo 'This script is going to copy SSH public keys to each IP listed above'
read -r -p "Continue? [Y/n] " response
if [[ ($response =~ ^[nN]$) ]]; then
	exit 1
fi
# Copy the SSH public key to each IP with the help of SSHPass
success_ips=()
while IFS= read -r ip; do
	# Print the separator
	printf '%20s\n' | tr ' ' -
	# Print the current IP
	echo "IP: $ip"
	# Specify the host
	host="$USERNAME@$ip"
	# Execute the script on the device
	sshpass -p "$PASSWORD" ssh -T "$host" <<- SSH_EOF
		# Backup the SSH config file
		cp -n "/home/$USERNAME/.ssh/authorized_keys" "/home/$USERNAME/.ssh/authorized_keys.old"
	SSH_EOF
	# Copy the SSH public key to the host
	sshpass -p "$PASSWORD" ssh-copy-id -o StrictHostKeyChecking=no "$host"
	return_val=$?
	if [ "$return_val" == 0 ]; then
		# Add the IP to the successful IP list
		success_ips+=("$ip")
	fi
done < "$FILENAME_IP"
# List the IPs to which keys are added successfully
echo 'Successful IP list:'
for success_ip in "${success_ips[@]}"; do
	echo "$success_ip"
done
# Clean up
bash ./cleanup.sh