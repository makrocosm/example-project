#? Alpine x64
#? ----------
#?

all: alpine-x64

release: alpine-x64-release

.PHONY: alpine-x64
alpine-x64: build/alpine/x64/disk.img #? Build the example Alpine x64 firmware and disk image

.PHONY: alpine-x64-bios-vm
alpine-x64-bios-vm: #? Boot the disk.img image in a virtual machine using BIOS
	$(AT)qemu-system-x86_64 \
  	-machine pc \
  	-m 2G \
  	-nographic \
		-netdev user,id=net1,net=10.0.1.0/24 -device e1000,netdev=net1 \
		-drive id=drive0,file="build/alpine/x64/disk.img",format=raw,if=virtio

.PHONY: alpine-x64-efi-vm
alpine-x64-efi-vm: #? Boot the disk.img image in a virtual machine using EFI
	$(AT)qemu-system-x86_64 \
  	-machine pc \
  	-m 2G \
  	-nographic \
  	-bios /usr/share/qemu/OVMF.fd \
		-netdev user,id=net1,net=10.0.1.0/24 -device e1000,netdev=net1 \
		-drive id=drive0,file="build/alpine/x64/disk.img",format=raw,if=virtio

.PHONY: alpine-x64-release
alpine-x64-release: #? Copy versioned firmware and disk images to the "release" directory
alpine-x64-release: \
		build/alpine/x64/rootfs.sqfs \
		build/alpine/x64/disk.img
	mkdir -p release
	cp build/alpine/x64/rootfs.sqfs release/alpine-x64-image-$(RELEASE_VERSION).bin
	cp build/alpine/x64/disk.img release/alpine-x64-disk-$(RELEASE_VERSION).img

.PHONY: alpine-x64-clean
alpine-x64-clean: #? Remove build artifacts
	rm -rf build/alpine/x64

#?

#
# Linux kernel
#

# Kernel build configuration
build/alpine/x64/linux/.config: \
		alpine/x64/defconfig.kconfig \
		alpine/common/linux/filesystems.kconfig

#
# Root filesystem
#

# Build the kernel before the rootfs container. The linux/install directory
# is included in the container's build context.
build/alpine/x64/rootfs.tar build/alpine/x64/rootfs: \
		build/alpine/common/rootfs \
		build/alpine/x64/linux/install

build/alpine/x64/rootfs.sqfs: #? Firmare image containing the rootfs and kernel

#
# Disk image
#

# bootenv is populated with environment created by grub-editenv tools
build/alpine/x64/disk/bootenv.fat: \
	build/alpine/x64/rootfs

# Disk image with GRUB bootloader using BIOS boot or EFI,
# symmetric A/B rootfs, config overlay, and user data
build/alpine/x64/disk.img: #? Disk image that can booted in a VM, or written to an SD card, USB flash, etc and run on real x64 hardware
build/alpine/x64/disk.img: \
		build/alpine/x64/disk/bios.fat \
		build/alpine/x64/disk/bootenv.fat \
		build/alpine/x64/disk/efi.fat \
		build/alpine/x64/rootfs.sqfs.pad \
		build/alpine/x64/disk/config.ext4 \
		build/alpine/x64/disk/userdata.ext4 \
		build/alpine/x64/linux/install \
		build/alpine/x64/rootfs.cpio.gz
	makrocosm-disk "$@" create 1G
	makrocosm-disk "$@" table gpt
	makrocosm-disk "$@" partition bios build/alpine/x64/disk/bios.fat bios_grub
	makrocosm-disk "$@" partition bootenv build/alpine/x64/disk/bootenv.fat
	makrocosm-disk "$@" partition efi build/alpine/x64/disk/efi.fat esp
	makrocosm-disk "$@" partition imageA build/alpine/x64/rootfs.sqfs.pad
	makrocosm-disk "$@" partition imageB build/alpine//x64/rootfs.sqfs.pad
	makrocosm-disk "$@" partition config build/alpine/x64/disk/config.ext4
	makrocosm-disk "$@" partition userdata build/alpine/x64/disk/userdata.ext4
	# Boot the kernel/rootfs in a VM to run the Grub bootloader installer
	qemu-system-x86_64 \
		-net none \
		-nographic \
		-m 512 \
		-append "root=/dev/ram quiet console=ttyS0 rdinit=/usr/libexec/grub-install-init --" \
		-kernel build/alpine/x64/linux/install/boot/bzImage \
		-initrd build/alpine/x64/rootfs.cpio.gz \
		-drive id=drive0,file="$@",format=raw,if=none \
		-device virtio-blk-pci,drive=drive0,id=virtblk0,num-queues=4

#?
