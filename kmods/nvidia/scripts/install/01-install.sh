#!/bin/sh

set -ouex pipefail
source /tmp/akmods/info/nvidia-vars

ARCH=$(uname -m)

dnf -y install \
    /tmp/akmods/rpms/nvidia-addons-*.rpm

# Enable nvidia-container-toolkit repo
sed -i 's@enabled=0@enabled=1@g' /etc/yum.repos.d/nvidia-container-toolkit.repo
sed -i 's@enabled=0@enabled=1@g' /etc/yum.repos.d/negativo17-fedora-nvidia.repo

# Install Nvidia drivers
dnf -y install \
    libnvidia-fbc \
    libva-nvidia-driver \
    nvidia-driver \
    nvidia-modprobe \
    nvidia-persistenced \
    nvidia-driver-cuda \
    nvidia-settings \
    nvidia-container-toolkit '\
    nvidia-vaapi-driver \
    /tmp/akmods/rpms/kmod-nvidia-${KERNEL_VERSION}-${NVIDIA_AKMOD_VERSION}.fc${RELEASE}.rpm