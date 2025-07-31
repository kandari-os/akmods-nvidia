#!/bin/sh

set -ouex pipefail
source /tmp/akmods/info/nvidia-vars

dnf -y install \
    /tmp/akmods/rpms/nvidia-addons-*.rpm

# Enable nvidia-container-toolkit repo
sed -i 's@enabled=0@enabled=1@g' /etc/yum.repos.d/nvidia-container-toolkit.repo

# Install Nvidia drivers
dnf -y install \
    xorg-x11-drv-nvidia-${NVIDIA_FULL_VERSION} \
    xorg-x11-drv-nvidia-cuda-${NVIDIA_FULL_VERSION} \
    nvidia-container-toolkit \
    nvidia-vaapi-driver \
    /tmp/akmods/rpms/kmod-nvidia-${KERNEL_VERSION}-${NVIDIA_AKMOD_VERSION}.fc${RELEASE}.rpm
