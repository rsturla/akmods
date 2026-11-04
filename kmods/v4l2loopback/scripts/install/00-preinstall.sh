#!/bin/sh

set -ouex pipefail

# Create a backup of current repos
cp -a /etc/yum.repos.d /tmp/yum.repos.d

# Fedora 45 moved the default repository files from /etc/yum.repos.d to
# /usr/share/dnf5/repos.d. Copy the files we change into /etc so that the
# backup and restore stay in one directory.
for repo in fedora-cisco-openh264.repo fedora-updates-archive.repo; do
  if [ ! -f "/etc/yum.repos.d/${repo}" ] && [ -f "/usr/share/dnf5/repos.d/${repo}" ]; then
    cp -a "/usr/share/dnf5/repos.d/${repo}" /etc/yum.repos.d/
  fi
done

# Configure repos
sed -i 's@enabled=0@enabled=1@g' /etc/yum.repos.d/fedora-{cisco-openh264,updates-archive}.repo
dnf -y install \
  --nogpgcheck --repofrompath \
  'terra,https://repos.fyralabs.com/terra$releasever' terra-release
if [ ! -f /etc/yum.repos.d/terra.repo ] && [ -f /usr/share/dnf5/repos.d/terra.repo ]; then
  cp -a /usr/share/dnf5/repos.d/terra.repo /etc/yum.repos.d/
fi
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/terra.repo
