# Raspberry Pi platform notes

## Build

The bootloader, kernel, and userspace are all compiled as 64-bit.
This build uses the `rpi_arm64` defconfig from upstream u-boot, and the
`bcm2711` defconfig from the Raspberry Pi Linux kernel.
This kernel supports a variety of Raspberry Pi 3 and Raspberry Pi 4
variants. Check [this table for reference](https://www.raspberrypi.com/documentation/computers/linux_kernel.html#cross-compiled-build-configuration).

The following variants have been tested:

  - Raspberry Pi 4 Model B Rev 1.1 (BCM2711)
  - Raspberry Pi 3 Model B Rev 1.2 (BCM2837)

## Boot

The Raspberry Pi's [config.txt](https://www.raspberrypi.com/documentation/computers/config_txt.html)
on the first FAT partition of the SD card controls early boot.
It is configured to run `u-boot.bin` with some extra configuration for
a console on UART0 (TX GPIO 14 & RX GPIO15) @ 115200 baud.

u-boot will run the `bootcmd` variable which is set by default to
`run mmcload`.
`mmcload` runs the `mmcload.scr` script which checks the `bootpart` variable
and selects the associated firmware image partition on the SD card to boot.

If you interrupt u-boot before it runs `bootcmd`, you can boot a firmware
image over the network from a TFTP server. Set `ipaddr` and `serverip`
appropriately (or run the `dhcp` command) and then execute
`run netload` which will fetch the firmware image named `${bootfile}` and
boot it.

For example:


```
setenv ipaddr 192.168.0.10
setenv serverip 192.168.0.1
run netload
```

or

```
setenv autoload no
dhcp
run netload
```

Note that networking is not available in u-boot on the Raspberry Pi 3
which has USB ethernet networking.

The firmware image is `rootf.sqfs` and contains the root filesystem, kernel,
device trees, and u-boot script `boot.scr` which the previous `run mmcload`
and `run netload` use to load and boot the kernel with device tree and root
device set.
