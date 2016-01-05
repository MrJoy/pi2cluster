# pi2cluster

These scripts facilitate setting up a cluster of Raspberry Pi 2 nodes in a normalized way.

At present they are mostly built up around using Snappy Core Ubuntu 15.04.

It is assumed that the Pi will have an external HD attached via USB, will not be using any of the special I/O features, and will have a console accessible via HDMI / USB keyboard.

The external drive will be formatted as `ext4` if not already formatted to it, and set to mount to `/mnt/external` automatically.

Over time this will expand and generalize to support other devices, other OSs, and other configurations as my own dabbling expands.


## Setup

1. Download the [Snappy Core Ubuntu 15.04 image](http://people.canonical.com/~platform/snappy/raspberrypi2/ubuntu-15.04-snappy-armhf-rpi2.img.xz) for Raspberry Pi, run it through `unxz`, and put it into `image/snappy-15.04`.
    * `brew install unxz`
2. Edit `boot/pi2cluster/authorized_keys` to have your preferred SSH public key.
3. Edit `boot/pi2cluster/config.txt` to disable the block at the end marked as disable-for-debugging, and to adjust any relevant video settings.


## Example Workflow

```bash
# WARNING: You should use `diskutil list` to identify which device the SD card
# WARNING: was assigned to, and use that!  The `r` in the name is for `raw`,
# WARNING: and is generally REALLY important for getting decent write
# WARNING: throughput here.
rake sd:unmount ubuntu:init sd:copy sd:eject DEVICE=/dev/rdisk2; say 'Done!'
```

Then, boot up a Pi with the relevant MMC card, log in as `ubuntu` (password: `ubuntu`), and run the following:

```bash
# The following will attempt to mount `/dev/sda1` as an `ext4` volume.  If it
# cannot mount it, it will attempt to format the drive!
/boot/uboot/pi2cluster/bin/setup.sh <group> <unit>
sudo reboot now
```

You should be able to reach the host at: `pi2g<group>u<unit>.local` (0-padding each value to 2 digits!), e.g. `pi2g01u01.local` once it reboots.

You should also be able to SSH in without a password (just with your SSH key and passphrase) as `ubuntu`, and have password-less `sudo` access.

Automate away from here.
