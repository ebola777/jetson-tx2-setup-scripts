#!/bin/bash
# This script will be executed first in any functional script.

# User defined constants
readonly IP_RANGE='192.168.0.0/24'
readonly SERVER_IP='192.168.0.100'
readonly NMAP_OPTIONS='-sn'
readonly USERNAME='ubuntu'
readonly PASSWORD='ubuntu'
readonly TARGET_KERNEL_VERSION='Linux 3.10.96-tegra aarch64'
readonly HOSTNAME_PREFIX='tegra-'
readonly HOSTNAME_SERVER_SUFFIX='server'
readonly HOSTNAME_CLIENT_SUFFIX=''
# Temporary files
readonly FILENAME_NMAP='tmp-nmap-output.xml'
readonly FILENAME_IP='tmp-ip.log'