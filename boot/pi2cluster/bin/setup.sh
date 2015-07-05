#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

BASE_DIR=$(
  cd "$(dirname "$(readlink "$0" || echo "$0")")/.."
  /bin/pwd
)

# TODO: Make sure current user is `pi`.  Or maybe require this run as root to
# TODO: avoid the need for sudo and the awkwardness that imposes wrt I/O
# TODO: redirections?

# TODO: This whole process is sloppy as hell and dangerous if there's a way for
# TODO: anyone to get onto the box while it's running.  We should turn `sshd`
# TODO: off at startup as a *minimum*.

GROUP=${1:-}
UNIT=${2:-}
ERROR=0
if [ "$GROUP" == "" ]; then ERROR=1; fi
if [ "$UNIT" == "" ]; then ERROR=1; fi
if [ "$ERROR" == "1" ]; then
  echo "USAGE: setup.sh <group number> <unit number>"
  exit 1
fi

# TODO: Maybe ping the network to ensure this is unique?
#
# TODO: What's the graceful/proper way to set the damn hostname?
GROUP=$(printf "%02d" $GROUP)
UNIT=$(printf "%02d" $UNIT)
NEW_HOSTNAME="pi2g${GROUP}u${UNIT}.local"
echo "INFO: Setting hostname to '${NEW_HOSTNAME}'."
cat /etc/hosts | perl -pse "s/^(127\.0\.0\.1.*?)$/\1\t${NEW_HOSTNAME}/sm" > /tmp/hosts
sudo sh -c "cat /tmp/hosts > /etc/hosts"
sudo hostname ${NEW_HOSTNAME}


# TODO: Don't format if it's already formatted.
# TODO: Don't mount if it's already mounted / set up in `/etc/mtab`.
MOUNT_DEVICE=/dev/sda1
MOUNT_TARGET=/mnt/external/
echo "INFO: Setting up ${MOUNT_DEVICE} with an ext4 volume, and mounting it to ${MOUNT_TARGET}"
if [ ! -d $MOUNT_TARGET ]; then
  sudo mkdir -p $MOUNT_TARGET
fi
if [ $(grep ${MOUNT_DEVICE} /etc/fstab | wc -l) == 0 ]; then
  sudo sh -c "echo ${MOUNT_DEVICE} ${MOUNT_TARGET} ext4 rw,relatime,data=ordered,journal=ordered 0 0 >> /etc/fstab"
fi
if ! sudo mount $MOUNT_DEVICE $MOUNT_TARGET; then
  sudo mkfs.ext4 $MOUNT_DEVICE
else
  echo "INFO: Looks like ${MOUNT_TARGET} already set up.  Assuming setup went well and skipping FS setup."
fi


echo "INFO: Ensuring SSH configuration is reasonable and has only the key included with us."
AK_FILE=~/.ssh/authorized_keys
mkdir -p ~/.ssh
chmod 700 ~/.ssh
cp -f $BASE_DIR/config/authorized_keys $AK_FILE
chmod 600 $AK_FILE


echo "INFO: Ensuring sshd configuration is robust."
# sudo cp -f $BASE_DIR/config/raspbian/sshd_config /etc/ssh/sshd_config
# TODO: rm /etc/ssh/ssh_host_* && dpkg-reconfigure openssh-server


echo "INFO: Coercing password for pi user to predetermined value."
# TODO: Filter/replace for just `pi` user.
#
# TODO: Perhaps just set up a random string?
# sudo cp -f $BASE_DIR/config/raspbian/{group,gshadow,passwd,shadow} /etc/
# sudo chmod 600 /etc/{gshadow,shadow}
# sudo chmod 644 /etc/{group,passwd}


# echo "INFO: Signaling sshd to pick up changes."
# sudo killall -HUP sshd

# TODO: Set up locale/keyboard, time zone, etc.

# TODO: Remove unneeded packages.  Add desired packages.
