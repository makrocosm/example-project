FROM alpine:3.20 AS build
RUN mkdir -p /config/etc /config/overlay

FROM scratch
COPY --from=build /config ./
