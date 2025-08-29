#!/bin/sh

set -oeux pipefail

# Install RPM Fusion repos
dnf install -y \
  "https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm" \
  "https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"

# Update repo metadata
dnf -y update rpmfusion-free-release rpmfusion-nonfree-release