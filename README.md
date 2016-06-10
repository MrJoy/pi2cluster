# pi2cluster

These scripts facilitate setting up a cluster of Raspberry Pi 2 nodes in a normalized way.

At present they are mostly built up around using Snappy Core Ubuntu 15.04.

It is assumed that the Pi will have an external HD attached via USB, will not be using any of the special I/O features, and will have a console accessible via HDMI / USB keyboard.

The external drive will be formatted as `ext4` if not already formatted to it, and set to mount to `/mnt/external` automatically.

Over time this will expand and generalize to support other devices, other OSs, and other configurations as my own dabbling expands.


## Setup

1. Download the [HypriotOS 0.8.0 image](https://downloads.hypriot.com/hypriotos-rpi-v0.8.0.img.zip), unzip it, and put it into `image/hypriotos-0.8.0`.
1. Download the [Snappy Core Ubuntu 15.04 image](http://people.canonical.com/~platform/snappy/raspberrypi2/ubuntu-15.04-snappy-armhf-rpi2.img.xz) for Raspberry Pi, run it through `unxz`, and put it into `image/snappy-15.04`.
    * `brew install unxz`
2. Edit `boot/common/config/authorized_keys` to have your preferred SSH public key.
3. Edit `boot/common/config.txt` to disable the block at the end marked as disable-for-debugging, and to adjust any relevant video settings.


## Example Workflow

```bash
# WARNING: You should use `diskutil list` to identify which device the SD card
# WARNING: was assigned to, and use that!  The `r` in the name is for `raw`,
# WARNING: and is generally REALLY important for getting decent write
# WARNING: throughput here.
#
# Also note that you'll be prompted for your password as `sudo` is used here!
time rake sd:unmount hypriotos:init sd:copy sd:eject DEVICE=/dev/rdisk4; say 'Done!'

# If you're iterating on the setup scripts / boot process and you have an imaged MMC card at hand:
rake sd:copy sd:eject DEVICE=/dev/rdisk4
```

Default users:

| OS        | Username | Password |
|-----------|----------|----------|
| Snappy    | ubuntu   | ubuntu   |
| HypriotOS | pirate   | hypriot  |

Then, boot up a Pi with the relevant MMC card, log in, and run the following:

```bash
# The following will attempt to mount `/dev/sda1` as an `ext4` volume.  If it
# cannot mount it, it will attempt to format the drive!
/boot/uboot/pi2cluster/bin/setup.sh <group> <unit>
sudo reboot now
```

You should be able to reach the host at: `pi2g<group>u<unit>.local` (0-padding each value to 2 digits!), e.g. `pi2g01u01.local` once it reboots.

You should also be able to SSH in without a password (just with your SSH key and passphrase) as `ubuntu`, and have password-less `sudo` access.

Automate away from here.
