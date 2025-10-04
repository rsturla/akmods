#!/bin/sh

set -ouex pipefail

# Check if a build context was provided
if [ $# -lt 1 ]; then
    echo "Usage: $0 <build-context-path>"
    exit 1
fi

BUILD_CONTEXT="$1"

dnf install -y --enablerepo=terra \
  "$BUILD_CONTEXT"/rpms/kmod-v4l2loopback-*.rpm \
  v4l2loopback-kmod-common

# Copy akmods certs
mkdir -p /etc/pki/akmods/certs/
cp "${BUILD_CONTEXT}"/certs/* /etc/pki/akmods/certs/
