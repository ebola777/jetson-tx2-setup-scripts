#!/bin/bash
# This script copies SSH public key to each device from your computer by using
# SSHPass and ssh-copy-id. This script uses get_ip.sh instead of
# get_valid_ip.sh because get_valid_ip.sh only works after this process.

# Get constants
source ./constants.sh
# Get IPs
bash ./get_ips.sh
# Ask user whether to continue
echo 'This script is going to copy SSH public keys to each IP listed above'
read -r -p "Continue? [Y/n] " response
if [[ ($response =~ ^[nN]$) ]]; then
	exit 1
fi
# Copy SSH public key to each IP with the help of SSHPass
success_ips=()
while IFS= read -r ip; do
	# Print separator
	printf '%20s\n' | tr ' ' -
	# Print current IP
	echo "IP: $ip"
	# Specify host
	host="$USERNAME@$ip"
	# Copy SSH public key to the host
	sshpass -p "$PASSWORD" ssh-copy-id -o StrictHostKeyChecking=no "$host"
	return_val=$?
	if [ "$return_val" == 0 ]; then
		# Add IP to successful IP list
		success_ips+=("$ip")
	fi
done < "$FILENAME_IP"
# List IPs to which keys are added successfully
echo 'Successful IP list:'
for success_ip in "${success_ips[@]}"; do
	echo "$success_ip"
done
# Clean up
bash ./cleanup.sh