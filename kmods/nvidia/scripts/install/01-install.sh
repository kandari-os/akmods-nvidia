#!/bin/sh

set -oue pipefail
source /tmp/akmods/info/nvidia-vars

# Install local NVIDIA addon RPMs
dnf install -y /tmp/akmods/rpms/nvidia-addons-*.rpm

# Enable nvidia-container-toolkit repo
sed -i 's@enabled=0@enabled=1@g' /etc/yum.repos.d/nvidia-container-toolkit.repo

# Install NVIDIA drivers, toolkit, and kernel module RPM
dnf install -y \
    xorg-x11-drv-nvidia-470xx-${NVIDIA_FULL_VERSION} \
    nvidia-container-toolkit \
    /tmp/akmods/rpms/kmod-nvidia-470xx-${KERNEL_VERSION}-${NVIDIA_AKMOD_VERSION}.fc${RELEASE}.rpm
