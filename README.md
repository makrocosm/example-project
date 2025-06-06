# Makrocosm example project

An example project using the [Makrocosm](https://www.github.com/makrocosm/makrocosm)
build system to create minimal Alpine-based firmware for a variety of platforms.

Platforms:

 - Generic x64
   - BIOS and EFI Grub bootloader
   - Disk image can be written to USB flash, harddrive, etc, and booted on real hardware
   - Disk image can be booted in VM
 - Raspberry Pi (ARM64)
   - u-boot bootloader
   - Disk image can be written to SD card and booted on real hardware
   - Supports Raspberry Pi models compatible with the BCM2711 kernel. Tested on:
     - Raspberry Pi 4 Model B Rev 1.1
     - Raspberry Pi 3 Model B Rev 1.2
   - Console on UART0 (TX GPIO 14 & RX GPIO15) @ 115200 baud
 - BeaglePlay (ARM64)
   - Two stage u-boot bootloaders (ARM R5 and ARM64 A53) with OPTEE and Trusted Firmware-A
   - Disk image can be written to SD card and booted on real hardware (press USR during reset to boot from SD card)
   - Does not currently support booting from eMMC (requires revised boot scripts and default environment)
   - Console on UART header @ 115200 baud
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

  x64-alpine: Build the example Alpine x64 firmware and disk image
  x64-alpine-bios-vm: Boot the disk.img image in a virtual machine using BIOS
  x64-alpine-efi-vm: Boot the disk.img image in a virtual machine using EFI
  x64-alpine-release: Copy versioned firmware and disk images to the "release" directory
  x64-alpine-clean: Remove build artifacts

  build/platform/x64/rootfs.sqfs: Firmare image containing the rootfs and kernel
  build/platform/x64/disk.img: Disk image that can booted in a VM, or written to an SD card, USB flash, etc and run on real x64 hardware

Alpine Orange Pi One
--------------------

  opi1-alpine: Build the example Alpine Orange Pi One firmware and disk image
  opi1-alpine-vm: Boot disk.img in a virtual machine
  opi1-alpine-release: Copy versioned firmware and disk images to the "release" directory
  opi1-alpine-clean: Remove build artifacts

  build/platform/opi1/rootfs.sqfs: Firmware image containing the rootfs and kernel
  build/platform/opi1/disk.img: Disk image that can be booted in the VM, or written to an SD card and run on an Orange Pi One

Alpine Raspberry Pi (BCM2710-based)
-----------------------------------

  rpi-alpine: Build the example Alpine Raspberry Pi firmware and disk image
  rpi-alpine-release: Copy versioned firmware and disk images to the "release" directory
  rpi-alpine-clean: Remove build artifacts

  build/platform/rpi/rootfs.sqfs: Firmware image containing the rootfs and kernel
  build/platform/rpi/disk.img: Disk image that can be written to an SD card and run on various BCM2710-based Raspberry Pi models

Alpine BeagleBoard.org BeaglePlay
---------------------------------

  bplay-alpine: Build the example Alpine BeaglePlay firmware and disk image
  bplay-alpine-release: Copy versioned firmware and disk images to the "release" directory
  bplay-alpine-clean: Remove build artifacts

  build/platform/bplay/rootfs.sqfs: Firmware image containing the rootfs and kernel
  build/platform/bplay/disk.img: Disk image that can be written to an SD card and run on a BeaglePlay

Makrocosm targets
-----------------

Run with "make VERBOSE=1 ..." to see make and tool trace

  help: Display this help
  deps: Install dependencies
  tftpboot: Run a tftp server providing files from the build directory
  shell: Enter a shell in the workspace container
  clean: Remove built artifacts from the build directory
  distclean: Remove the build directory

```
