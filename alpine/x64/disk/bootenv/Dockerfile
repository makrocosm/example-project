FROM mep-alpine-x64-rootfs AS build
RUN grub-editenv /grubenv set default=0
RUN grub-editenv /grubenv set timeout=2

FROM scratch AS bootenv
COPY grub.cfg ./
COPY --from=build grubenv grubenv
