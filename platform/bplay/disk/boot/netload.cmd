# Network load script
# This script loads ${bootfile} from the TFTP server and then defers to the
# boot script /boot/boot.scr on that partition.
#
# You must set ipaddr and serverip variables appropriately before running
# this script. This can be done using the `dhcp` command.

echo Makrocosm Example Project - BeaglePlay

# Move the ramdisk location higher otherwise the uncompressed kernel runs over it
setenv ramdisk_addr_r 0x4000000

# Fetch the sqfs image and mount it as a block device
tftpboot ${ramdisk_addr_r} ${bootfile} || reset
setenv ramdisk_size 0x${filesize}
blkmap create netboot
setexpr fileblks ${filesize} + 0x1ff
setexpr fileblks ${fileblks} / 0x200
blkmap map netboot 0 ${fileblks} mem ${fileaddr}
blkmap get netboot dev devnum

# Prepare the environment before running the firmware image's boot script
setenv intf blkmap
setenv bootimg ${devnum}
setenv bootpart
setenv root /dev/ram0
setenv extra_bootargs ${extra_bootargs} initrd=${ramdisk_addr_r},${ramdisk_size}

echo Booting image from network ...
if load ${intf} ${bootimg} ${bootscriptaddr} /boot/boot.scr; then
  source ${bootscriptaddr}
fi
