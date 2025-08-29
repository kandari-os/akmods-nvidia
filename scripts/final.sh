#!/usr/bin/env bash

set -oeux pipefail

OUTPUT_DIR="/rpms"
CACHE_DIR="/var/cache/rpms"

mkdir -p "$OUTPUT_DIR"

echo "🔍 Searching for built RPMs in: $CACHE_DIR"
echo

find "$CACHE_DIR" -name '*.rpm' | while read -r rpm; do
    echo "📦 Found: $rpm"
    cp -a "$rpm" "$OUTPUT_DIR/"

    echo "   ├─ Provides:"
    rpm -qp "$rpm" --provides | sed 's/^/   │   /'

    echo "   └─ Requires:"
    rpm -qp "$rpm" --requires | sed 's/^/       /'
    echo
done

echo "✅ RPMs copied to: $OUTPUT_DIR"
ls -lh "$OUTPUT_DIR"
