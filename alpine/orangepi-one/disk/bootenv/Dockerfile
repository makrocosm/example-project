FROM alpine-common-base AS build
ARG TARGETARCH

RUN --mount=type=cache,id=${TARGETARCH}/var/cache/apk,target=/var/cache/apk \
  apk add u-boot-tools

COPY boot.cmd boot.cmd
RUN mkimage -C none -A arm -T script -d boot.cmd boot.scr

RUN \
  echo "/uboot.env 0x0000 0x4000" > /etc/fw_env.config \
  && dd if=/dev/zero of=/uboot.env bs=1024 count=16 \
  && fw_setenv bootpart a

FROM scratch
COPY --from=build boot.scr boot.scr
COPY --from=build uboot.env uboot.env
