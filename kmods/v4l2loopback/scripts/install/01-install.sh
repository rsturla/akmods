#!/bin/sh

set -ouex pipefail

dnf install -y --enablerepo=terra \
  /tmp/akmods/rpms/kmod-v4l2loopback-*.rpm
