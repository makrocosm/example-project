#? Alpine Orange Pi One
#? --------------------
#?

all: opi1-alpine

release: opi1-alpine-release

.PHONY: opi1-alpine
opi1-alpine: build/platform/opi1/disk.img #? Build the example Alpine Orange Pi One firmware and disk image

.PHONY: opi1-alpine-vm
opi1-alpine-vm: #? Boot disk.img in a virtual machine
	$(AT)qemu-system-arm \
  	-machine orangepi-pc \
  	-nic user \
  	-nographic \
		-sd build/platform/opi1/disk.img

.PHONY: opi1-alpine-release
opi1-alpine-release: #? Copy versioned firmware and disk images to the "release" directory
opi1-alpine-release: \
		build/platform/opi1/rootfs.sqfs \
		build/platform/opi1/disk.img
	mkdir -p release
	cp build/platform/opi1/rootfs.sqfs release/opi1-alpine-image-$(RELEASE_VERSION).bin
	cp build/platform/opi1/disk.img release/opi1-alpine-disk-$(RELEASE_VERSION).img

.PHONY: opi1-alpine-clean
opi1-alpine-clean: #? Remove build artifacts
	rm -rf build/platform/opi1

#?

#
# u-boot bootloader
#

# Bootloader build configuration
build/platform/opi1/u-boot/.config: \
		common/u-boot/filesystems.kconfig

# Bootloader patches
build/platform/opi1/u-boot.src: \
		platform/opi1/u-boot/0001-fs-squashfs-Only-use-export-table-if-available.patch

#
# Linux kernel
#

# Kernel build configuration
build/platform/opi1/linux/.config: \
		common/linux/filesystems.kconfig

#
# Root filesystem
#

# Build the kernel before the rootfs container. The linux/install directory
# is included in the container's build context.
build/platform/opi1/rootfs.tar: \
		build/common/alpine/rootfs \
		build/platform/opi1/linux/install

build/platform/opi1/rootfs.sqfs: #? Firmware image containing the rootfs and kernel

#
# SD card image
#

# Disk image with u-boot bootloader, symmetric A/B rootfs, config overlay,
# and user data
build/platform/opi1/disk.img: #? Disk image that can be booted in the VM, or written to an SD card and run on an Orange Pi One
build/platform/opi1/disk.img: \
		build/platform/opi1/u-boot/install \
		build/platform/opi1/disk/bootenv.fat \
		build/platform/opi1/rootfs.sqfs.pad \
		build/platform/opi1/disk/config.ext4 \
		build/platform/opi1/disk/userdata.ext4
	makrocosm-disk "$@" create 1G
	makrocosm-disk "$@" table msdos
	makrocosm-disk "$@" write build/platform/opi1/u-boot/install/u-boot-sunxi-with-spl.bin 8K
	PARTITION_OFFSET=1M makrocosm-disk "$@" partition bootenv build/platform/opi1/disk/bootenv.fat
	makrocosm-disk "$@" partition imageA build/platform/opi1/rootfs.sqfs.pad
	makrocosm-disk "$@" partition imageB build/platform/opi1/rootfs.sqfs.pad
	makrocosm-disk "$@" partition config build/platform/opi1/disk/config.ext4
	makrocosm-disk "$@" partition userdata build/platform/opi1/disk/userdata.ext4

#?
