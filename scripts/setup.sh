#!/usr/bin/env bash

set -oeux pipefail

ARCH="$(rpm -E '%_arch')"
RELEASE="$(rpm -E '%fedora')"

sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/fedora-cisco-openh264.repo
sed -i 's@enabled=0@enabled=1@g' /etc/yum.repos.d/fedora-updates-archive.repo

mkdir -p /var/lib/alternatives

rpm-ostree install \
  kernel-devel \
  kernel-devel-matched

rpm-ostree install \
  akmods \
  mock

if [[ ! -s "/tmp/certs/private_key.priv" ]]; then
    echo "WARNING: Using test signing key. Run './generate-akmods-key' for production builds."
    cp /tmp/certs/private_key.priv{.local,}
    cp /tmp/certs/public_key.der{.local,}
fi

install -Dm644 /tmp/certs/public_key.der   /etc/pki/akmods/certs/public_key.der
install -Dm644 /tmp/certs/private_key.priv /etc/pki/akmods/private/private_key.priv

chmod 1777 /tmp /var/tmp

mkdir -p /var/cache/rpms/{kmods,kandari}