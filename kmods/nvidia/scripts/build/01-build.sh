#!/usr/bin/env bash
set -oeux pipefail

RELEASE="$(rpm -E '%fedora.%_arch')"

# Install NVIDIA driver packages
dnf install -y \
    akmod-nvidia-470xx \
    xorg-x11-drv-nvidia-470xx-{cuda,devel,kmodsrc,power}

# Gather versions
KERNEL_VERSION="$(rpm -q kernel --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}')"
NVIDIA_AKMOD_VERSION="$(rpm -q akmod-nvidia --queryformat '%{VERSION}-%{RELEASE}')"
NVIDIA_LIB_VERSION="$(rpm -q xorg-x11-drv-nvidia --queryformat '%{VERSION}-%{RELEASE}')"
NVIDIA_FULL_VERSION="$(rpm -q xorg-x11-drv-nvidia --queryformat '%{EPOCH}:%{VERSION}-%{RELEASE}.%{ARCH}')"

akmods --force --kernels "${KERNEL_VERSION}" --kmod "nvidia"

# Build NVIDIA addons
ADDONS_DIR="/tmp/rpm-specs/nvidia-addons"
mkdir -p ${ADDONS_DIR}/rpmbuild/{BUILD,RPMS,SOURCES,SPECS,SRPMS,tmp}

curl -Lo ${ADDONS_DIR}/rpmbuild/SOURCES/nvidia-container-toolkit.repo \
    https://nvidia.github.io/libnvidia-container/stable/rpm/nvidia-container-toolkit.repo
curl -Lo ${ADDONS_DIR}/rpmbuild/SOURCES/nvidia-container.pp \
    https://raw.githubusercontent.com/NVIDIA/dgx-selinux/master/bin/RHEL9/nvidia-container.pp

mv /tmp/files/* ${ADDONS_DIR}/rpmbuild/SOURCES/ || true
sed -i "s@gpgcheck=0@gpgcheck=1@" ${ADDONS_DIR}/rpmbuild/SOURCES/nvidia-container-toolkit.repo

install -D /etc/pki/akmods/certs/public_key.der ${ADDONS_DIR}/rpmbuild/SOURCES/public_key.der

rpmbuild -ba \
    --define "_topdir ${ADDONS_DIR}/rpmbuild" \
    --define '%_tmppath %{_topdir}/tmp' \
    ${ADDONS_DIR}/../nvidia-addons.spec

mkdir -p /var/cache/rpms
cp ${ADDONS_DIR}/rpmbuild/RPMS/noarch/*.rpm /var/cache/rpms || true

# Save build vars for downstream
cat <<EOF > /var/cache/akmods/nvidia-vars
KERNEL_VERSION=${KERNEL_VERSION}
RELEASE=${RELEASE}
NVIDIA_PACKAGE_NAME=nvidia
NVIDIA_FULL_VERSION=${NVIDIA_FULL_VERSION}
NVIDIA_AKMOD_VERSION=${NVIDIA_AKMOD_VERSION}
NVIDIA_LIB_VERSION=${NVIDIA_LIB_VERSION}
EOF
