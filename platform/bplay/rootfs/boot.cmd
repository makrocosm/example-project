# Firmware image boot script
# Expected variables:
#   intf - e.g. mmc, blkmap
#   bootimg - depends on intf
#   root - Linux kernel device to use as rootfs
#   bootpart - a/b/*none*

setenv fdtfile "k3-am625-beagleplay.dtb"

echo Firmware version:
cat ${intf} ${bootimg} /etc/version

echo Loading kernel ...
load ${intf} ${bootimg} ${kernel_addr_r} /boot/Image

echo Preparing device tree ${fdtfile} ...
load ${intf} ${bootimg} ${fdt_addr_r} /boot/${fdtfile}

setenv bootargs ${extra_bootargs} root=${root} rootwait rootfstype=squashfs bootpart=${bootpart}

booti ${kernel_addr_r} - ${fdt_addr_r}
