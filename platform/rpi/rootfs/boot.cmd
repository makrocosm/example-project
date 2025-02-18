# Firmware image boot script
# Expected variables:
#   intf - e.g. mmc, blkmap
#   bootimg - depends on intf
#   root - Linux kernel device to use as rootfs
#   bootpart - a/b/*none*

# Testing on a Raspberry Pi 3 Model B Rev v1.2 (board revision 0xA02082)
# with the bcm2711_defconfig Linux kernel did not work with the automatically
# chosen broadcom/bcm2837-rpi-3-b.dtb device tree.
# The device tree cannot be applied (fdt addr fails).
# The BCM2710 device tree for the Raspberry Pi 3 Model B does work.
if test "${board_revision}" = "0xA02082"; then
  setenv fdtfile "broadcom/bcm2710-rpi-3-b.dtb"
fi

echo Firmware version:
cat ${intf} ${bootimg} /etc/version

echo Loading kernel ...
load ${intf} ${bootimg} ${kernel_addr_r} /boot/Image

echo Preparing device tree ${fdtfile} ...
setexpr fdtov_addr_r ${fdt_addr_r} + 0x20000
load ${intf} ${bootimg} ${fdt_addr_r} /boot/${fdtfile}
load ${intf} ${bootimg} ${fdtov_addr_r} /boot/overlays/disable-bt.dtbo
fdt addr ${fdt_addr_r}
fdt resize 0x20000
fdt apply ${fdtov_addr_r}

setenv bootargs ${extra_bootargs} root=${root} rootwait rootfstype=squashfs bootpart=${bootpart}

booti ${kernel_addr_r} - ${fdt_addr_r}
