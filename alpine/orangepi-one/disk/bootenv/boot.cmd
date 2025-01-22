mmc rescan
setenv bootpart 2
load mmc ${mmc_bootdev}:${bootpart} ${kernel_addr_r} /boot/zImage
load mmc ${mmc_bootdev}:${bootpart} ${fdt_addr_r} /boot/sun8i-h3-orangepi-one.dtb
setenv bootargs console=ttyS0,115200 earlyprintk root=/dev/mmcblk0p2 rootwait panic=10
bootz ${kernel_addr_r} - ${fdt_addr_r}
