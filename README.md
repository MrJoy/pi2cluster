# pi2cluster

These scripts facilitate setting up a cluster of Raspberry Pi 2 nodes in a normalized way.

At present they are mostly built up around using Snappy Core Ubuntu 15.04.

It is assumed that the Pi will have an external HD attached via USB, will not be using any of the special I/O features, and will have a console accessible via HDMI / USB keyboard.


## Setup

1. Download the Snappy Core Ubuntu 15.04 image for Raspberry Pi into `image/snappy-15.04`.
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
/boot/uboot/pi2cluster/bin/setup.sh <group> <unit>
sudo reboot now
```

You should be able to reach the host at: `pi2g<group>u<unit>.local` (0-padding each value to 2 digits!), e.g. `pi2g01u01.local` once it reboots.
