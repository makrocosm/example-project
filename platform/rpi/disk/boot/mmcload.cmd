# SD card load script
# This script selects which partition to boot from and then defers to the
# boot script /boot/boot.scr on that partition.

echo Makrocosm Example Project - Raspberry Pi ${board_name}
setenv intf mmc

if test $bootpart = b; then
  echo Booting image B ...
  setenv bootimg ${mmc_bootdev}:3
  setenv root /dev/mmcblk0p3
else
  echo Booting image A ...
  setenv bootimg ${mmc_bootdev}:2
  setenv root /dev/mmcblk0p2
fi

if load ${intf} ${bootimg} ${bootscriptaddr} /boot/boot.scr; then
  source ${bootscriptaddr}
fi
