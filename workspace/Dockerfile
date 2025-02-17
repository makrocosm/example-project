#
# A custom workspace that extends Makrocosm's Ubuntu 24.04 workspace
#

FROM mep-makrocosm-workspace-ubuntu-24.04

# Add qemu for installing the x64 Grub bootloader in a VM, and
# testing out various targets in a VM
RUN --mount=target=/var/lib/apt/lists,type=cache,sharing=locked \
    --mount=target=/var/cache/apt,type=cache,sharing=locked \
    rm -f /etc/apt/apt.conf.d/docker-clean \
    && apt-get update \
    && apt-get -y --no-install-recommends install \
      qemu-system
