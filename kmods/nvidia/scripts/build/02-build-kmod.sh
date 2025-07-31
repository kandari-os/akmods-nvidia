#!/bin/sh
set -euo pipefail

# Default to system kernel if not explicitly passed
KERNEL_VERSION="${1:-$(rpm -q --qf "%{VERSION}-%{RELEASE}.%{ARCH}" kernel-devel)}"

echo "🔧 Target kernel: $KERNEL_VERSION"

# Install required runtime packages
echo "📦 Installing kernel-core and kernel-devel..."
dnf install -y kernel-core-${KERNEL_VERSION} kernel-devel-${KERNEL_VERSION} akmod-nvidia

# Trigger akmods build
echo "🛠️ Running akmods to build kernel module..."
akmods --force --kernel "$KERNEL_VERSION"

# Generate module dependency info
echo "📚 Running depmod..."
depmod -a "$KERNEL_VERSION"

# Archive the built modules
echo "📁 Copying built modules to /built-modules..."
mkdir -p /built-modules
cp -r "/lib/modules/${KERNEL_VERSION}" /built-modules/

echo "✅ NVIDIA kernel module for $KERNEL_VERSION built and copied."
