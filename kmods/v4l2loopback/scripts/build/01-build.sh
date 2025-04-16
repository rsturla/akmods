#!/bin/sh

set -oeux pipefail

RELEASE="$(rpm -E '%fedora.%_arch')"

# Build NVIDIA drivers
dnf install -y \
  akmod-v4l2loopback-*.fc${RELEASE}

KERNEL_VERSION="$(rpm -q kernel-core --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}')"

akmods --force --kernels "${KERNEL_VERSION}" --kmod "v4l2loopback"

modinfo /usr/lib/modules/${KERNEL_VERSION}/extra/v4l2loopback/v4l2loopback.ko.xz >/dev/null ||
  (find /var/cache/akmods/v4l2loopback/ -name \*.log -print -exec cat {} \; && exit 1)

mkdir -p /var/cache/rpms

for rpm in $(find /var/cache/akmods/ -type f -name \*.rpm); do
  cp "${rpm}" /var/cache/rpms/
done

find /var/cache/rpms
