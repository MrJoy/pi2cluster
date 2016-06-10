#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

BASE_DIR=$(
  cd "$(dirname "$(readlink "$0" || echo "$0")")/.."
  /bin/pwd
)

# TODO: Set up locale/keyboard, time zone, etc.
echo "INFO: Updating OS, adding/removing packages."
sudo snappy update ubuntu-core pi2
sudo snappy install docker
sudo snappy remove webdm
sudo snappy purge webdm
