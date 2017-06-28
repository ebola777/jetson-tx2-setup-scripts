#!/bin/bash
# This script cleans up temporary files.

# Get the constants
source ./constants.sh
# Remove temporary files
rm "$FILENAME_NMAP"
rm "$FILENAME_IP"