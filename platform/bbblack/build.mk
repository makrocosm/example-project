#? Alpine BeagleBoard.org BeagleBone Black
#? ---------------------------------------
#?

all: bbblack-alpine

release: bbblack-alpine-release

.PHONY: bbblack-alpine
bbblack-alpine: build/platform/bbblack/disk.img #? Build the example Alpine BeagleBone Black firmware and disk image

.PHONY: bbblack-alpine-release
bbblack-alpine-release: #? Copy versioned firmware and disk images to the "release" directory
bbblack-alpine-release: \
		build/platform/bbblack/rootfs.sqfs \
		build/platform/bbblack/disk.img
	mkdir -p release
	cp build/platform/bbblack/rootfs.sqfs release/bbblack-alpine-image-$(RELEASE_VERSION).bin
	cp build/platform/bbblack/disk.img release/bbblack-alpine-disk-$(RELEASE_VERSION).img

.PHONY: bbblack-alpine-clean
bbblack-alpine-clean: #? Remove build artifacts
	rm -rf build/platform/bbblack

#?

#
# u-boot bootloader
#

# Bootloader build configuration
build/platform/bbblack/u-boot/.config: \
		common/u-boot/filesystems.kconfig

# Build u-boot before the bootloader binaries are copied to the boot partition
build/platform/bbblack/disk/boot.tar: build/platform/bbblack/u-boot/install

#
# Linux kernel
#

# Kernel build configuration
build/platform/bbblack/linux/.config: \
		common/linux/filesystems.kconfig

#
# Root filesystem
#

# Build the kernel before the rootfs container. The linux/install directory
# is included in the container's build context.
build/platform/bbblack/rootfs.tar: \
		build/common/alpine/rootfs \
		build/platform/bbblack/linux/install

build/platform/bbblack/rootfs.sqfs: #? Firmware image containing the rootfs and kernel

#
# SD card image
#

# Disk image with u-boot bootloader, symmetric A/B rootfs, config overlay,
# and user data
build/platform/bbblack/disk.img: #? Disk image that can be booted in the VM, or written to an SD card and run on a BeagleBone Black
build/platform/bbblack/disk.img: \
		build/platform/bbblack/disk/boot.fat \
		build/platform/bbblack/rootfs.sqfs.pad \
		build/platform/bbblack/disk/config.ext4 \
		build/platform/bbblack/disk/userdata.ext4
	makrocosm-disk "$@" create 1G
	makrocosm-disk "$@" table msdos
	makrocosm-disk "$@" partition boot build/platform/bbblack/disk/boot.fat
	makrocosm-disk "$@" partition imageA build/platform/bbblack/rootfs.sqfs.pad
	makrocosm-disk "$@" partition imageB build/platform/bbblack/rootfs.sqfs.pad
	makrocosm-disk "$@" partition config build/platform/bbblack/disk/config.ext4
	makrocosm-disk "$@" partition userdata build/platform/bbblack/disk/userdata.ext4

#?
