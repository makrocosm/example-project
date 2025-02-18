#? Alpine x64
#? ----------
#?

all: x64-alpine

release: x64-alpine-release

.PHONY: x64-alpine
x64-alpine: build/platform/x64/disk.img #? Build the example Alpine x64 firmware and disk image

.PHONY: x64-alpine-bios-vm
x64-alpine-bios-vm: #? Boot the disk.img image in a virtual machine using BIOS
	$(AT)qemu-system-x86_64 \
  	-machine pc \
  	-m 2G \
  	-nographic \
		-netdev user,id=net1,net=10.0.1.0/24 -device e1000,netdev=net1 \
		-drive id=drive0,file="build/platform/x64/disk.img",format=raw,if=virtio

.PHONY: x64-alpine-efi-vm
x64-alpine-efi-vm: #? Boot the disk.img image in a virtual machine using EFI
	$(AT)qemu-system-x86_64 \
  	-machine pc \
  	-m 2G \
  	-nographic \
  	-bios /usr/share/qemu/OVMF.fd \
		-netdev user,id=net1,net=10.0.1.0/24 -device e1000,netdev=net1 \
		-drive id=drive0,file="build/platform/x64/disk.img",format=raw,if=virtio

.PHONY: x64-alpine-release
x64-alpine-release: #? Copy versioned firmware and disk images to the "release" directory
x64-alpine-release: \
		build/platform/x64/rootfs.sqfs \
		build/platform/x64/disk.img
	mkdir -p release
	cp build/platform/x64/rootfs.sqfs release/x64-alpine-image-$(RELEASE_VERSION).bin
	cp build/platform/x64/disk.img release/x64-alpine-disk-$(RELEASE_VERSION).img

.PHONY: x64-alpine-clean
x64-alpine-clean: #? Remove build artifacts
	rm -rf build/platform/x64

#?

#
# Linux kernel
#

# Kernel build configuration
build/platform/x64/linux/.config: \
		platform/x64/defconfig.kconfig \
		common/linux/filesystems.kconfig

#
# Root filesystem
#

# Build the kernel before the rootfs container. The linux/install directory
# is included in the container's build context.
build/platform/x64/rootfs.tar build/platform/x64/rootfs: \
		build/common/alpine/rootfs \
		build/platform/x64/linux/install

build/platform/x64/rootfs.sqfs: #? Firmare image containing the rootfs and kernel

#
# Disk image
#

# bootenv is populated with environment created by grub-editenv tools
build/platform/x64/disk/bootenv.fat: \
	build/platform/x64/rootfs

# Disk image with GRUB bootloader using BIOS boot or EFI,
# symmetric A/B rootfs, config overlay, and user data
build/platform/x64/disk.img: #? Disk image that can booted in a VM, or written to an SD card, USB flash, etc and run on real x64 hardware
build/platform/x64/disk.img: \
		build/platform/x64/disk/bios.fat \
		build/platform/x64/disk/bootenv.fat \
		build/platform/x64/disk/efi.fat \
		build/platform/x64/rootfs.sqfs.pad \
		build/platform/x64/disk/config.ext4 \
		build/platform/x64/disk/userdata.ext4 \
		build/platform/x64/linux/install \
		build/platform/x64/rootfs.cpio.gz
	makrocosm-disk "$@" create 1G
	makrocosm-disk "$@" table gpt
	makrocosm-disk "$@" partition bios build/platform/x64/disk/bios.fat bios_grub
	makrocosm-disk "$@" partition bootenv build/platform/x64/disk/bootenv.fat
	makrocosm-disk "$@" partition efi build/platform/x64/disk/efi.fat esp
	makrocosm-disk "$@" partition imageA build/platform/x64/rootfs.sqfs.pad
	makrocosm-disk "$@" partition imageB build/platform/x64/rootfs.sqfs.pad
	makrocosm-disk "$@" partition config build/platform/x64/disk/config.ext4
	makrocosm-disk "$@" partition userdata build/platform/x64/disk/userdata.ext4
	# Boot the kernel/rootfs in a VM to run the Grub bootloader installer
	qemu-system-x86_64 \
		-net none \
		-nographic \
		-m 512 \
		-append "root=/dev/ram quiet console=ttyS0 rdinit=/usr/libexec/grub-install-init --" \
		-kernel build/platform/x64/linux/install/boot/bzImage \
		-initrd build/platform/x64/rootfs.cpio.gz \
		-drive id=drive0,file="$@",format=raw,if=none \
		-device virtio-blk-pci,drive=drive0,id=virtblk0,num-queues=4

#?
