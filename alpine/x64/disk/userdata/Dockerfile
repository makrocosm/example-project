FROM alpine AS build
RUN --mount=type=cache,target=/var/cache/apk \
  apk update \
  && apk add grub

RUN grub-editenv /grubenv set default=0
RUN grub-editenv /grubenv set timeout=2

RUN mkdir -p /config/etc /config/overlay

FROM scratch AS bootenv
COPY grub.cfg grub.cfg
COPY --from=build grubenv grubenv

FROM scratch AS config
COPY --from=build /config ./

FROM scratch AS empty
