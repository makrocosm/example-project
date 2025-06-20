FROM mep-common-alpine-base AS build
RUN mkdir -p /config/etc /config/overlay

FROM scratch
COPY --from=build /config ./
