#!/bin/bash
# This script gets all IPs found in IP_RANGE by ping test by the tool Nmap. 
# Results will be saved to FILENAME_NMAP. Then the results will be parsed by
# the tool XMLStarlet and saved to FILENAME_IP.

# Get constants
source ./constants.sh
# Use Nmap to scan LAN
nmap -oX "$FILENAME_NMAP" "$NMAP_OPTIONS" "$IP_RANGE"
# Parse Nmap output and get alive IPs by XMLStarlet
xmlstarlet sel -t -v '//host/address/@addr' "$FILENAME_NMAP" > \
	"$FILENAME_IP"
# Add newline to the output file
sed -i -e '$a\' "$FILENAME_IP"
# List IPs
echo 'IP list:'
while IFS= read -r ip; do
	echo "$ip"
done < "$FILENAME_IP"