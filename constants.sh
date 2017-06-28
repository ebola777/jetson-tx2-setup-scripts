#!/bin/bash
# It contains the global constants for other scripts to use. This script will be
# executed first in any functional script.

# User defined constants
readonly IP_RANGE='192.168.0.0/24'
readonly SERVER_IP='192.168.0.100'
readonly NMAP_OPTIONS=(-sn -PS22 -n)
readonly USERNAME='nvidia'
readonly PASSWORD='nvidia'
readonly TARGET_KERNEL_VERSION='Linux 4.4.15-tegra aarch64'
readonly HOSTNAME_PREFIX='tegra-'
readonly HOSTNAME_SERVER_SUFFIX='server'
readonly HOSTNAME_CLIENT_SUFFIX=''
readonly HOSTNAME_ORIGINAL='tegra-ubuntu'
# Temporary files
readonly FILENAME_NMAP='tmp-nmap-output.xml'
readonly FILENAME_IP='tmp-ip.log'