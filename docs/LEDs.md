# Built-in LEDs

LED control is done here: `/sys/devices/soc/soc:leds/leds/ledX`

Apparently valid values for `trigger` on Raspberry Pi 2:

* `none`
* `mmc0`
* `timer`
* `oneshot`
* `heartbeat`
* `backlight`
* `gpio`
* `cpu0`
* `cpu1`
* `cpu2`
* `cpu3`
* `default-on`
* `input`
