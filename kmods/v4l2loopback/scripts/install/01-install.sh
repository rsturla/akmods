#!/bin/sh

set -ouex pipefail

dnf install -y /tmp/akmods/rpms/v4l2loopback-*.rpm
