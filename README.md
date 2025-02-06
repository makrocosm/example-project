# Makrocosm example project

An example project using the [Makrocosm](https://www.github.com/makrocosm/makrocosm)
build system to create minimal Alpine-based firmware for a variety of platforms.

Supported platforms:

 - Generic x64
   - BIOS and EFI Grub bootloader
   - Disk image can be written to USB flash, harddrive, etc, and booted on real hardware
   - Disk image can be booted in VM
 - Orange Pi One (ARM)
   - u-boot bootloader
   - Disk image can be written to SD card and booted on real hardware
   - Disk image can be booted in VM

Common features:

  - Squashfs root filesystem images (read-only)
  - Persistent storage overlay on `/etc`
  - Disk layout has A/B rootfs partitions, selected by variable in bootloader environment
  - Cross-compiled example applications (C, CMake, Golang)

## Prerequisites

Building this project requires the following tools:

  - git
  - make (likely requires GNU make)
  - Docker Engine (tested with 27.3.1)
    with the [containerd image store](https://docs.docker.com/engine/storage/containerd/) enabled

See [Makrocosm's prerequisites](https://makrocosm.github.io/makrocosm/getting-started/#prerequisites) for details.

## Quickstart

Clone the repository and Makrocosm submodule. Any `make` invocation will
cause the workspace container image to build before performing the desired
operation.

```
# Clone this repository
git clone --recurse-submodules https://github.com/makrocosm/example-project.git

# Build the firmware and disk images for all platforms
make
```

See the build artifacts mentioned in the [Usage](#usage) for information on
the final output files.

## Usage

```
$ make help

Makrocosm example project
=========================

  all: Build firmware and disk images for all platforms
  release: Copy all platforms' versioned firmware and disk images to the "release" directory

Alpine x64
----------

  alpine-x64: Build the example Alpine x64 firmware and disk image
  alpine-x64-bios-vm: Boot the disk.raw image in a virtual machien using BIOS
  alpine-x64-efi-vm: Boot the disk.raw image in a virtual machine using EFI
  alpine-x64-release: Copy versioned firmware and disk images to the "release" directory
  alpine-x64-clean: Remove build artifacts

  build/alpine/x64/rootfs.sqfs: Firmare image containing the rootfs and kernel
  build/alpine/x64/disk.raw: Disk image that can booted in a VM, or written to an SD card, USB flash, etc and run on real x64 hardware

Alpine Orange Pi One
--------------------

  alpine-orangepi-one: Build the example Alpine Orange Pi One firmware and disk image
  alpine-orangepi-one-vm: Boot the disk.raw image in a virtual machine
  alpine-orangepi-one-release: Copy versioned firmware and disk images to the "release" directory
  alpine-orangepi-one-clean: Remove build artifacts

  build/alpine/orangepi-one/rootfs.sqfs: Firmware image containing the rootfs and kernel
  build/alpine/orangepi-one/disk.raw: Disk image that can be booted in the VM, or written to an SD card and run on an Orange Pi One

makrocosm targets
-----------------

Run with "make VERBOSE=1 ..." to see make and tool trace

  help: Display this help
  deps: Install dependencies
  shell: Enter a shell in the workspace container
  clean: Remove built artifacts from the build directory
  distclean: Remove the build directory

```
