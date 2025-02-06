#? Alpine Orange Pi One
#? --------------------
#?

all: alpine-orangepi-one

release: alpine-orangepi-one-release

.PHONY: alpine-orangepi-one
alpine-orangepi-one: build/alpine/orangepi-one/disk.img #? Build the example Alpine Orange Pi One firmware and disk image

.PHONY: alpine-orangepi-one-vm
alpine-orangepi-one-vm: #? Boot disk.img in a virtual machine
	$(AT)qemu-system-arm \
  	-machine orangepi-pc \
  	-nic user \
  	-nographic \
		-sd build/alpine/orangepi-one/disk.img

.PHONY: alpine-orangepi-one-release
alpine-orangepi-one-release: #? Copy versioned firmware and disk images to the "release" directory
alpine-orangepi-one-release: \
		build/alpine/orangepi-one/rootfs.sqfs \
		build/alpine/orangepi-one/disk.img
	mkdir -p release
	cp build/alpine/orangepi-one/rootfs.sqfs release/alpine-orangepi-one-image-$(RELEASE_VERSION).bin
	cp build/alpine/orangepi-one/disk.img release/alpine-orangepi-one-disk-$(RELEASE_VERSION).img

.PHONY: alpine-orangepi-one-clean
alpine-orangepi-one-clean: #? Remove build artifacts
	rm -rf build/alpine/orangepi-one

#?

#
# u-boot bootloader
#

# Bootloader build configuration
build/alpine/orangepi-one/u-boot/.config: \
		alpine/common/u-boot/filesystems.kconfig

# Bootloader patches
build/alpine/orangepi-one/u-boot.src: \
		alpine/orangepi-one/u-boot/0001-fs-squashfs-Only-use-export-table-if-available.patch

#
# Linux kernel
#

# Kernel build configuration
build/alpine/orangepi-one/linux/.config: \
		alpine/common/linux/filesystems.kconfig

#
# Root filesystem
#

# Build the kernel before the rootfs container. The linux/install directory
# is included in the container's build context.
build/alpine/orangepi-one/rootfs.tar: \
		build/alpine/common/rootfs \
		build/alpine/orangepi-one/linux/install

build/alpine/orangepi-one/rootfs.sqfs: #? Firmware image containing the rootfs and kernel

#
# SD card image
#

# Disk image with u-boot bootloader, symmetric A/B rootfs, config overlay,
# and user data
build/alpine/orangepi-one/disk.img: #? Disk image that can be booted in the VM, or written to an SD card and run on an Orange Pi One
build/alpine/orangepi-one/disk.img: \
		build/alpine/orangepi-one/u-boot/install \
		build/alpine/orangepi-one/disk/bootenv.fat \
		build/alpine/orangepi-one/rootfs.sqfs.pad \
		build/alpine/orangepi-one/disk/config.ext4 \
		build/alpine/orangepi-one/disk/userdata.ext4
	makrocosm-disk "$@" create 1G
	makrocosm-disk "$@" table msdos
	makrocosm-disk "$@" write build/alpine/orangepi-one/u-boot/install/u-boot-sunxi-with-spl.bin 8K
	PARTITION_OFFSET=1M makrocosm-disk "$@" partition bootenv build/alpine/orangepi-one/disk/bootenv.fat
	makrocosm-disk "$@" partition imageA build/alpine/orangepi-one/rootfs.sqfs.pad
	makrocosm-disk "$@" partition imageB build/alpine/orangepi-one/rootfs.sqfs.pad
	makrocosm-disk "$@" partition config build/alpine/orangepi-one/disk/config.ext4
	makrocosm-disk "$@" partition userdata build/alpine/orangepi-one/disk/userdata.ext4

#?
