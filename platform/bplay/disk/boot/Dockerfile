FROM mep-common-alpine-base AS build
ARG TARGETARCH

RUN --mount=type=cache,id=${TARGETARCH}/var/cache/apk,target=/var/cache/apk \
  apk add u-boot-tools

# Compile the boot script which handles A/B rootfs partition swapping
COPY mmcload.cmd netload.cmd ./
RUN \
  mkimage -C none -A arm64 -T script -d mmcload.cmd mmcload.scr \
  && mkimage -C none -A arm64 -T script -d netload.cmd netload.scr

# Prepare the environment so u-boot mmcload script at startup
# MMC device selection is for SD card (device 1).
# Supporting eMMC (device 0) will require some changes here and in
# mmcload.cmd
RUN \
  echo "/uboot.env 0x0000 0x4000" > /etc/fw_env.config \
  && dd if=/dev/zero of=/uboot.env bs=1024 count=16 \
  && fw_setenv bootpart a \
  && fw_setenv mmc_bootdev 1 \
  && fw_setenv bootfile platform/bplay/rootfs.sqfs \
  && fw_setenv extra_bootargs 'panic=10 loglevel=6' \
  && fw_setenv scriptaddr 0x80b80000 \
  && fw_setenv bootscriptaddr 0x80b90000 \
  && fw_setenv fdt_addr_r 0x80d00400 \
  && fw_setenv kernel_addr_r 0x80e00400 \
  && fw_setenv mmcload 'load mmc ${mmc_bootdev}:1 ${scriptaddr} mmcload.scr && source ${scriptaddr}' \
  && fw_setenv netload 'load mmc ${mmc_bootdev}:1 ${scriptaddr} netload.scr && source ${scriptaddr}' \
  && fw_setenv bootcmd 'run mmcload'

FROM scratch
# There are a few different variants of tiboot3.bin:
#   GP General Purpose: This is a SoC/board state where there is no device protection and authentication is not enabled for booting the device.
#   HS-FS High Security - Field Securable: This is a SoC/board state before a customer has blown the keys in the device. i.e. the state at which HS device leaves TI factory. In this state, the device protects the ROM code, TI keys and certain security peripherals. In this state, device do not force authentication for booting, however DMSC is locked.
#   HS-SE High Security - Security Enforced: This is a SoC/board state after a customer has successfully blown the keys and set “customer Keys enable”. In HS-SE device all security features enabled. All secrets within the device are fully protected and all of the security goals are fully enforced. The device also enforces secure booting.
# Choosing the one relevant to the BeaglePlay board at hand, but copy all so
# another can be selected by renaming to tiboot3.bin.
COPY --from=u-boot-r5 tiboot3-am62x-gp-evm.bin tiboot3.bin
COPY --from=u-boot-r5 tiboot3-*.bin ./
COPY --from=u-boot-a53 tispl.bin_unsigned tispl.bin
COPY --from=u-boot-a53 u-boot.img_unsigned u-boot.img
COPY --from=build uboot.env mmcload.scr netload.scr ./
