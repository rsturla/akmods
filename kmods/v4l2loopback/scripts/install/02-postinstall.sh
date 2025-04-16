#!/bin/sh

set -ouex pipefail

# Restore the original repo configuration
rm /etc/yum.repos.d/*
cp -a /tmp/yum.repos.d/* /etc/yum.repos.d/
rm -rf /tmp/yum.repos.d
