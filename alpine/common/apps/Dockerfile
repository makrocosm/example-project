#
# Development sysroot.
# Install dev versions of libraries in the base image that are required
# for compiling custom applications.
# This image is used as a sysroot that can be used to cross-compile
# the applications.
# Alternatively, it can be used as base image for an emulated native
# compile of the applications.
#

FROM alpine-common-base AS dev
ARG TARGETARCH

RUN --mount=type=cache,id=${TARGETARCH}/var/cache/apk,target=/var/cache/apk \
  apk add musl-dev libc-dev libstdc++-dev gcc \
    libuv-dev

#
# Cross-compiling base image
#

FROM --platform=$BUILDPLATFORM alpine:3.20 AS cross
ARG TARGETARCH
ARG TARGETVARIANT

RUN --mount=type=cache,id=${TARGETARCH}/var/cache/apk,target=/var/cache/apk \
  apk add clang llvm lld build-base cmake pkgconfig

COPY --from=dev / /sysroot
COPY cross-env.sh /usr/libexec

#
# Example C application (target arch, emulated if necessary) build stage
#

FROM dev AS helloworld_c_native
ARG TARGETARCH

RUN --mount=type=cache,id=${TARGETARCH}/var/cache/apk,target=/var/cache/apk \
  apk add gcc build-base

COPY helloworld_c /src
WORKDIR /src
RUN make

#
# Example C application (cross-compiled) build stage
#
# Using clang because Alpine repository doesn't have cross-compiling gcc
# packages that target Alpine.
#

FROM --platform=$BUILDPLATFORM cross AS helloworld_c_cross
ARG TARGETARCH
ARG TARGETVARIANT

COPY helloworld_c /src
WORKDIR /src
RUN \
  . /usr/libexec/cross-env.sh "$TARGETARCH" "$TARGETVARIANT" \
  && make

#
# Example C application with CMake (cross-compiled) build stage
#

FROM --platform=$BUILDPLATFORM cross AS helloworld_cmake
ARG TARGETARCH
ARG TARGETVARIANT

COPY helloworld_cmake /src
RUN mkdir -p /src/build
WORKDIR /src/build
RUN \
  . /usr/libexec/cross-env.sh "$TARGETARCH" "$TARGETVARIANT" \
  && cmake \
    -DCMAKE_SYSROOT="$SYSROOT" \
    -DCMAKE_FIND_ROOT_PATH_NODE_PROGRAM=NEVER \
    -DCMAKE_FIND_ROOT_PATH_NODE_LIBRARY=ONLY \
    -DCMAKE_FIND_ROOT_PATH_NODE_INCLUDE=ONLY \
    -DCMAKE_FIND_ROOT_PATH_NODE_PACKAGE=NEVER \
    -DPKG_CONFIG_EXECUTABLE="$PKG_CONFIG_EXECUTABLE" \
    .. \
  && make install

#
# Example Go application (cross-compile) build stage
#

FROM --platform=$BUILDPLATFORM golang:1.23.2-alpine3.20 AS helloworld_go
ARG TARGETARCH
ARG TARGETOS

COPY helloworld_go /src
WORKDIR /src
RUN GOOS=$TARGETOS GOARCH=$TARGETARCH go build

#
# Example Go application (cross-compile) build stage
#

FROM scratch
COPY --from=helloworld_c_cross /src/helloworld /bin/helloworld_c_cross
COPY --from=helloworld_c_native /src/helloworld /bin/helloworld_c_native
COPY --from=helloworld_cmake /usr/local/bin/helloworld /bin/helloworld_cmake
COPY --from=helloworld_go /src/helloworld /bin/helloworld_go
