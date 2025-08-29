#!/usr/bin/env bash
set -oeux pipefail

OUTPUT_DIR="/rpms"
CACHE_DIR="/var/cache/rpms"

mkdir -p "$OUTPUT_DIR"

echo "Searching for RPMs in: $CACHE_DIR"

for rpm in "$CACHE_DIR"/*.rpm; do
    [ -e "$rpm" ] || continue  # skip if no RPMs found
    echo "Copying: $rpm"
    cp -a "$rpm" "$OUTPUT_DIR/"

    echo "Provides:"
    rpm -qp "$rpm" --provides | sed 's/^/  /'

    echo "Requires:"
    rpm -qp "$rpm" --requires | sed 's/^/  /'
    echo
done

echo "All RPMs copied to: $OUTPUT_DIR"
ls -lh "$OUTPUT_DIR"
