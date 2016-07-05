#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

BASE_DIR=$(
  cd "$(dirname "$(readlink "$0" || echo "$0")")/.."
  /bin/pwd
)

# TODO: This whole process is sloppy as hell and dangerous if there's a way for
# TODO: anyone to get onto the box while it's running.  We should turn `sshd`
# TODO: off at startup as a *minimum*.

# TODO: Make this conditional to platforms where we need it (Snappy):
# GROUP=${1:-}
# UNIT=${2:-}
# ERROR=0
# if [ "$GROUP" == "" ]; then ERROR=1; fi
# if [ "$UNIT" == "" ]; then ERROR=1; fi
# if [ "$ERROR" == "1" ]; then
#   echo "USAGE: setup.sh <group number> <unit number>"
#   exit 1
# fi

# # TODO: Maybe ping the network to ensure this is unique?
# #
# # TODO: What's the graceful/proper way to set the damn hostname?
# GROUP=$(printf "%02d" "$GROUP")
# UNIT=$(printf "%02d" "$UNIT")
# NEW_HOSTNAME="pi2g${GROUP}u${UNIT}.local"
# echo "INFO: Setting hostname to '${NEW_HOSTNAME}'."
# perl -pse "s/^(127\.0\.0\.1\s+)(.*?)$/\1${NEW_HOSTNAME}\t\2/sm" < /etc/hosts > /tmp/hosts
# sudo sh -c "cat /tmp/hosts > /etc/hosts"
# sudo hostname "${NEW_HOSTNAME}"


# TODO: Don't format if it's already formatted.
# TODO: Template the service file so this stays in sync...
MOUNT_DEVICE=/dev/sda1
MOUNT_TARGET=/mnt/external/
echo "INFO: Setting up ${MOUNT_DEVICE} with an ext4 volume, and mounting it to ${MOUNT_TARGET}"
if [ ! -e /etc/systemd/system/mnt-external.mount ]; then
  sudo cp -f "$BASE_DIR/config/mnt-external.mount" /etc/systemd/system/mnt-external.mount
  sudo chmod 644 /etc/systemd/system/mnt-external.mount
  sudo systemctl enable mnt-external.mount
  sudo systemctl daemon-reload
fi

if ! sudo systemctl start mnt-external.mount; then
  sudo mkfs.ext4 $MOUNT_DEVICE
  sudo systemctl start mnt-external.mount
else
  echo "INFO: Looks like ${MOUNT_TARGET} already set up.  Assuming setup went well and skipping FS setup."
fi

echo "INFO: Ensuring SSH configuration is reasonable and has only the key included with us."
AK_FILE=~/.ssh/authorized_keys
mkdir -p ~/.ssh
chmod 700 ~/.ssh
cp -f "$BASE_DIR/config/authorized_keys" $AK_FILE
chmod 600 $AK_FILE
cat /etc/ssh/sshd_config |
  perl -pse 's/(#\s*)?(PermitRootLogin)(.*?)$/\2 no/' |
  perl -pse 's/(#\s*)?(PasswordAuthentication)(.*?)$/\2 no/' |
  perl -pse 's/(#\s*)?(RSAAuthentication)(.*?)$/\2 yes/' |
  perl -pse 's/(#\s*)?(PubkeyAuthentication)(.*?)$/\2 yes/' > /tmp/sshd_config
sudo sh -c "cat /tmp/sshd_config > /etc/ssh/sshd_config"

echo "INFO: Signaling sshd to pick up changes."
sudo pkill --signal HUP sshd

if [ -e "$BASE_DIR/bin/post.sh" ]; then
  "$BASE_DIR/bin/post.sh"
fi
