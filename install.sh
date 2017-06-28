#!/bin/bash
# This script will run all the setup_*.sh files in the directory.

# Run all the setup scripts
bash ./setup_connection1.sh
bash ./setup_connection2.sh
bash ./setup_hostname.sh
bash ./setup_nfs.sh
# Show the finish message
echo 'Installation has finished'