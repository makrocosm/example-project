#? Alpine Raspberry Pi (BCM2710-based)
#? -----------------------------------
#?

all: alpine-rpi

release: alpine-rpi-release

.PHONY: alpine-rpi
alpine-rpi: build/alpine/rpi/disk.img #? Build the example Alpine Raspberry Pi firmware and disk image

.PHONY: alpine-rpi-release
alpine-rpi-release: #? Copy versioned firmware and disk images to the "release" directory
alpine-rpi-release: \
		build/alpine/rpi/rootfs.sqfs \
		build/alpine/rpi/disk.img
	mkdir -p release
	cp build/alpine/rpi/rootfs.sqfs release/alpine-rpi-image-$(RELEASE_VERSION).bin
	cp build/alpine/rpi/disk.img release/alpine-rpi-disk-$(RELEASE_VERSION).img

.PHONY: alpine-rpi-clean
alpine-rpi-clean: #? Remove build artifacts
	rm -rf build/alpine/rpi

#?

#
# u-boot bootloader
#

# Bootloader build configuration
build/alpine/rpi/u-boot/.config: \
		alpine/common/u-boot/filesystems.kconfig \
		alpine/rpi/u-boot.kconfig

#
# Linux kernel
#

# Kernel build configuration
build/alpine/rpi/linux/.config: \
		alpine/common/linux/filesystems.kconfig \
		alpine/rpi/linux.kconfig

#
# Root filesystem
#

# Build the kernel before the rootfs container. The linux/install directory
# is included in the container's build context.
build/alpine/rpi/rootfs.tar: \
		build/alpine/common/rootfs \
		build/alpine/rpi/linux/install

build/alpine/rpi/rootfs.sqfs: #? Firmware image containing the rootfs and kernel

#
# SD card image
#

build/alpine/rpi/disk/config.tar: \
	build/alpine/common/base

build/alpine/rpi/disk/boot.tar: \
	build/alpine/rpi/u-boot/install \
	build/alpine/rpi/linux/install \
	build/alpine/rpi/firmware.src

# Disk image with u-boot bootloader, symmetric A/B rootfs, config overlay,
# and user data
build/alpine/rpi/disk.img: #? Disk image that can be written to an SD card and run on various BCM2710-based Raspberry Pi models
build/alpine/rpi/disk.img: \
		build/alpine/rpi/disk/boot.fat \
		build/alpine/rpi/rootfs.sqfs.pad \
		build/alpine/rpi/disk/config.ext4 \
		build/alpine/rpi/disk/userdata.ext4
	makrocosm-disk "$@" create 1G
	makrocosm-disk "$@" table msdos
	makrocosm-disk "$@" partition boot build/alpine/rpi/disk/boot.fat
	makrocosm-disk "$@" partition imageA build/alpine/rpi/rootfs.sqfs.pad
	makrocosm-disk "$@" partition imageB build/alpine/rpi/rootfs.sqfs.pad
	makrocosm-disk "$@" partition config build/alpine/rpi/disk/config.ext4
	makrocosm-disk "$@" partition userdata build/alpine/rpi/disk/userdata.ext4

#?
