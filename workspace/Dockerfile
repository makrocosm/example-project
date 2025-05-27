#
# A custom workspace that extends Makrocosm's Ubuntu 24.04 workspace
#

FROM mep-makrocosm-workspace-ubuntu-24.04

# Add qemu for installing the x64 Grub bootloader in a VM, and
# testing out various targets in a VM.
# Add device-tree-compiler for trusted-firmware build.
# Add python3-cryptography and python3-pyelftools for optee build.
RUN --mount=target=/var/lib/apt/lists,type=cache,sharing=locked \
    --mount=target=/var/cache/apt,type=cache,sharing=locked \
    rm -f /etc/apt/apt.conf.d/docker-clean \
    && apt-get update \
    && apt-get -y --no-install-recommends install \
      qemu-system \
      device-tree-compiler \
      python3-cryptography python3-pyelftools python3-jsonschema

# Add yamllint for ti-linux-firmware/u-boot Beagleplay r5 build.
RUN pip3 install --break-system-packages yamllint
