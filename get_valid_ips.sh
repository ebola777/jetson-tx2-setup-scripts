#!/bin/bash
# This script differs from get_ip.sh. It checks the kernel version on the
# device. It's considered valid only if the kernel version matches
# TARGET_KERNEL_VERSION. You can use the command uname -mrs to find out. It
# will run get_ip.sh first, use the IP list from FILENAME_IP, then overwrite
# valid IP list to FILENAME_IP.

# Get constants
source ./constants.sh
# Get IPs
bash ./get_ips.sh
# Test connection and verify kernel info
valid_ips=()
while IFS= read -r ip; do
	# Determine host
	host="$USERNAME@$ip"
	# Check kernel version of the remote machine
	kernel_version=$(ssh $host "uname -mrs" </dev/null)
	if [ "$kernel_version" == "$TARGET_KERNEL_VERSION" ]; then
		valid_ips+=("$ip")
	fi
done < "$FILENAME_IP"
# Save valid IPs to file
printf "%s\n" "${valid_ips[@]}" > "$FILENAME_IP"
# List valid IPs
echo 'Valid IP list:'
for valid_ip in "${valid_ips[@]}"; do
	echo "$valid_ip"
done