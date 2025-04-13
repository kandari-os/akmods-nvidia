#!/bin/sh

set -oeux pipefail

rpm-ostree install \
  "https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm" \
  "https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"

rpm-ostree install \
  rpmfusion-free-release \
  rpmfusion-nonfree-release \
  --uninstall rpmfusion-free-release-$(rpm -E %fedora)-1.noarch \
  --uninstall rpmfusion-nonfree-release-$(rpm -E %fedora)-1.noarch

