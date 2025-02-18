#? Alpine Raspberry Pi (BCM2710-based)
#? -----------------------------------
#?

all: rpi-alpine

release: rpi-alpine-release

.PHONY: rpi-alpine
rpi-alpine: build/platform/rpi/disk.img #? Build the example Alpine Raspberry Pi firmware and disk image

.PHONY: rpi-alpine-release
rpi-alpine-release: #? Copy versioned firmware and disk images to the "release" directory
rpi-alpine-release: \
		build/platform/rpi/rootfs.sqfs \
		build/platform/rpi/disk.img
	mkdir -p release
	cp build/platform/rpi/rootfs.sqfs release/rpi-alpine-image-$(RELEASE_VERSION).bin
	cp build/platform/rpi/disk.img release/rpi-alpine-disk-$(RELEASE_VERSION).img

.PHONY: rpi-alpine-clean
rpi-alpine-clean: #? Remove build artifacts
	rm -rf build/platform/rpi

#?

#
# u-boot bootloader
#

# Bootloader build configuration
build/platform/rpi/u-boot/.config: \
		common/u-boot/filesystems.kconfig \
		platform/rpi/u-boot.kconfig

#
# Linux kernel
#

# Kernel build configuration
build/platform/rpi/linux/.config: \
		common/linux/filesystems.kconfig \
		platform/rpi/linux.kconfig

#
# Root filesystem
#

# Build the kernel before the rootfs container. The linux/install directory
# is included in the container's build context.
build/platform/rpi/rootfs.tar: \
		build/common/alpine/rootfs \
		build/platform/rpi/linux/install

build/platform/rpi/rootfs.sqfs: #? Firmware image containing the rootfs and kernel

#
# SD card image
#

build/platform/rpi/disk/config.tar: \
	build/common/alpine/base

build/platform/rpi/disk/boot.tar: \
	build/platform/rpi/u-boot/install \
	build/platform/rpi/linux/install \
	build/platform/rpi/firmware.src

# Disk image with u-boot bootloader, symmetric A/B rootfs, config overlay,
# and user data
build/platform/rpi/disk.img: #? Disk image that can be written to an SD card and run on various BCM2710-based Raspberry Pi models
build/platform/rpi/disk.img: \
		build/platform/rpi/disk/boot.fat \
		build/platform/rpi/rootfs.sqfs.pad \
		build/platform/rpi/disk/config.ext4 \
		build/platform/rpi/disk/userdata.ext4
	makrocosm-disk "$@" create 1G
	makrocosm-disk "$@" table msdos
	makrocosm-disk "$@" partition boot build/platform/rpi/disk/boot.fat
	makrocosm-disk "$@" partition imageA build/platform/rpi/rootfs.sqfs.pad
	makrocosm-disk "$@" partition imageB build/platform/rpi/rootfs.sqfs.pad
	makrocosm-disk "$@" partition config build/platform/rpi/disk/config.ext4
	makrocosm-disk "$@" partition userdata build/platform/rpi/disk/userdata.ext4

#?
