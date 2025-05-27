#? Alpine BeagleBoard.org BeaglePlay
#? ---------------------------------
#?

all: bplay-alpine

release: bplay-alpine-release

.PHONY: bplay-alpine
bplay-alpine: build/platform/bplay/disk.img #? Build the example Alpine BeaglePlay firmware and disk image

.PHONY: bplay-alpine-release
bplay-alpine-release: #? Copy versioned firmware and disk images to the "release" directory
bplay-alpine-release: \
		build/platform/bplay/rootfs.sqfs \
		build/platform/bplay/disk.img
	mkdir -p release
	cp build/platform/bplay/rootfs.sqfs release/bplay-alpine-image-$(RELEASE_VERSION).bin
	cp build/platform/bplay/disk.img release/bplay-alpine-disk-$(RELEASE_VERSION).img

.PHONY: bplay-alpine-clean
bplay-alpine-clean: #? Remove build artifacts
	rm -rf build/platform/bplay

#?

#
# u-boot bootloader (R5)
#

# Bootloader build configuration
build/platform/bplay/bootloader/r5/u-boot/.config: \
		common/u-boot/filesystems.kconfig

build/platform/bplay/bootloader/r5/u-boot/install: \
	build/platform/bplay/bootloader/ti-linux-firmware.src

build/platform/bplay/disk/boot.tar: build/platform/bplay/bootloader/r5/u-boot/install

#
# u-boot bootloader (A53)
#

# Bootloader build configuration
build/platform/bplay/bootloader/a53/u-boot/.config: \
		common/u-boot/filesystems.kconfig \
	  platform/bplay/bootloader/a53/u-boot.kconfig

build/platform/bplay/bootloader/a53/u-boot/install: \
	build/platform/bplay/bootloader/ti-linux-firmware.src \
	build/platform/bplay/bootloader/trusted-firmware-a.exec \
	build/platform/bplay/bootloader/optee.exec

build/platform/bplay/disk/boot.tar: build/platform/bplay/bootloader/a53/u-boot/install

#
# Linux kernel
#

# Kernel build configuration
build/platform/bplay/linux/.config: \
	platform/bplay/bb.org_defconfig-6.12.17-ti-arm64-r33.kconfig \
	common/linux/filesystems.kconfig

#
# Root filesystem
#

# Build the kernel before the rootfs container. The linux/install directory
# is included in the container's build context.
build/platform/bplay/rootfs.tar: \
		build/common/alpine/rootfs \
		build/platform/bplay/linux/install

build/platform/bplay/rootfs.sqfs: #? Firmware image containing the rootfs and kernel

#
# SD card image
#

# Disk image with u-boot bootloader, symmetric A/B rootfs, config overlay,
# and user data
build/platform/bplay/disk.img: #? Disk image that can be written to an SD card and run on a BeaglePlay
build/platform/bplay/disk.img: \
		build/platform/bplay/disk/boot.fat \
		build/platform/bplay/rootfs.sqfs.pad \
		build/platform/bplay/disk/config.ext4 \
		build/platform/bplay/disk/userdata.ext4
	makrocosm-disk "$@" create 1G
	makrocosm-disk "$@" table msdos
	makrocosm-disk "$@" partition boot build/platform/bplay/disk/boot.fat boot
	makrocosm-disk "$@" partition imageA build/platform/bplay/rootfs.sqfs.pad
	makrocosm-disk "$@" partition imageB build/platform/bplay/rootfs.sqfs.pad
	makrocosm-disk "$@" partition config build/platform/bplay/disk/config.ext4
	makrocosm-disk "$@" partition userdata build/platform/bplay/disk/userdata.ext4

#?
