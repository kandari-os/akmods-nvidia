#!/bin/sh

set -oeux pipefail

RELEASE="$(rpm -E '%fedora.%_arch')"

# Build NVIDIA drivers
dnf5 install -y \
    akmod-nvidia \
    xorg-x11-drv-nvidia \
    xorg-x11-drv-nvidia-cuda \
    xorg-x11-drv-nvidia-devel \
    xorg-x11-drv-nvidia-kmodsrc \
    xorg-x11-drv-nvidia-power \
    kernel-devel \
 && dnf5 clean all


KERNEL_VERSION="$(rpm -q kernel --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}')"
NVIDIA_AKMOD_VERSION="$(basename "$(rpm -q "akmod-nvidia" --queryformat '%{VERSION}-%{RELEASE}')" ".fc${RELEASE%%.*}")"
NVIDIA_LIB_VERSION="$(basename "$(rpm -q "xorg-x11-drv-nvidia" --queryformat '%{VERSION}-%{RELEASE}')" ".fc${RELEASE%%.*}")"
NVIDIA_FULL_VERSION="$(rpm -q "xorg-x11-drv-nvidia" --queryformat '%{EPOCH}:%{VERSION}-%{RELEASE}.%{ARCH}')"

akmods --force --kernels "${KERNEL_VERSION}" --kmod "nvidia"

# Build nvidia-addons
ADDONS_DIR="/tmp/rpm-specs/nvidia-addons"
mkdir -p ${ADDONS_DIR}/rpmbuild/{BUILD,RPMS,SOURCES,SPECS,SRPMS,tmp}
curl -Lo ${ADDONS_DIR}/rpmbuild/SOURCES/nvidia-container-toolkit.repo https://nvidia.github.io/libnvidia-container/stable/rpm/nvidia-container-toolkit.repo
curl -Lo ${ADDONS_DIR}/rpmbuild/SOURCES/nvidia-container.pp https://raw.githubusercontent.com/NVIDIA/dgx-selinux/master/bin/RHEL9/nvidia-container.pp
mv /tmp/files/* ${ADDONS_DIR}/rpmbuild/SOURCES/

sed -i "s@gpgcheck=0@gpgcheck=1@" ${ADDONS_DIR}/rpmbuild/SOURCES/nvidia-container-toolkit.repo

install -D /etc/pki/akmods/certs/public_key.der ${ADDONS_DIR}/rpmbuild/SOURCES/public_key.der

rpmbuild -ba \
    --define "_topdir ${ADDONS_DIR}/rpmbuild" \
    --define '%_tmppath %{_topdir}/tmp' \
    ${ADDONS_DIR}/../nvidia-addons.spec

mkdir -p /var/cache/rpms
cp ${ADDONS_DIR}/rpmbuild/RPMS/noarch/*.rpm /var/cache/rpms


# Create a file with the variables needed for the next steps
cat <<EOF > /var/cache/akmods/nvidia-vars
KERNEL_VERSION=${KERNEL_VERSION}
RELEASE=${RELEASE}
NVIDIA_PACKAGE_NAME=nvidia
NVIDIA_MAJOR_VERSION=${KMOD_VERSION}
NVIDIA_FULL_VERSION=${NVIDIA_FULL_VERSION}
NVIDIA_AKMOD_VERSION=${NVIDIA_AKMOD_VERSION}
NVIDIA_LIB_VERSION=${NVIDIA_LIB_VERSION}
REPOSITORY_TYPE=${REPOSITORY_TYPE}
EOF