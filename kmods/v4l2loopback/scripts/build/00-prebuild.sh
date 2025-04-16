#!/bin/sh

set -oeux pipefail

dnf -y install \
  --nogpgcheck --repofrompath \
  'terra,https://repos.fyralabs.com/terra$releasever' terra-release
