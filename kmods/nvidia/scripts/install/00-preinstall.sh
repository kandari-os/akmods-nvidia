#!/bin/sh

set -ouex pipefail
source /tmp/akmods/info/nvidia-vars

# Create a backup of current repos
cp -a /etc/yum.repos.d /tmp/yum.repos.d

# Configure repos
sed -i 's@enabled=0@enabled=1@g' /etc/yum.repos.d/fedora-{cisco-openh264,updates-archive}.repo