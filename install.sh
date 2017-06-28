#!/bin/bash
# This script will run all the setup_*.sh files in the directory.

bash ./setup_connection1.sh
bash ./setup_connection2.sh
bash ./setup_nfs.sh
bash ./setup_hostname.sh