FROM mep-common-alpine-base AS build
ARG TARGETARCH

RUN --mount=type=cache,id=${TARGETARCH}/var/cache/apk,target=/var/cache/apk \
  apk add u-boot-tools

# Compile the boot script which handles A/B rootfs partition swapping
COPY mmcload.cmd netload.cmd ./
RUN \
  mkimage -C none -A arm -T script -d mmcload.cmd mmcload.scr \
  && mkimage -C none -A arm -T script -d netload.cmd netload.scr

# Prepare the environment so u-boot mmcload script at startup
RUN \
  echo "/uboot.env 0x0000 0x4000" > /etc/fw_env.config \
  && dd if=/dev/zero of=/uboot.env bs=1024 count=16 \
  && fw_setenv bootpart a \
  && fw_setenv mmc_bootdev 0 \
  && fw_setenv bootfile platform/bbblack/rootfs.sqfs \
  && fw_setenv extra_bootargs 'panic=10 loglevel=6' \
  && fw_setenv bootscriptaddr 0x3000 \
  && fw_setenv mmcload 'load mmc ${mmc_bootdev}:1 ${scriptaddr} mmcload.scr && source ${scriptaddr}' \
  && fw_setenv netload 'load mmc ${mmc_bootdev}:1 ${scriptaddr} netload.scr && source ${scriptaddr}' \
  && fw_setenv bootcmd 'run mmcload'

FROM scratch
COPY --from=u-boot u-boot.img MLO ./
COPY --from=build uboot.env mmcload.scr netload.scr ./
