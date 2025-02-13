FROM alpine-common-base AS build
RUN mkdir -p /config/etc /config/overlay

FROM scratch
COPY --from=build /config ./
