#
# Install services and prepare the image as a rootfs to boot from the kernel init.
# Add any other common rootfs image.
#

FROM mep-common-alpine-base
ARG TARGETARCH

RUN --mount=type=cache,id=${TARGETARCH}/var/cache/apk,target=/var/cache/apk \
  apk update \
  && apk add openrc mdevd agetty iproute2 openssh

#RUN echo "rc_verbose=yes" >> /etc/rc.conf

# Start some system services
RUN rc-update add hostname boot
RUN rc-update add procfs boot
RUN rc-update add sysfs boot
RUN rc-update add devfs boot
RUN rc-update add mdevd-init boot

RUN rc-update add mdevd default
RUN rc-update add networking default
RUN rc-update add sshd default

RUN cd /etc/init.d \
  && ln -s agetty agetty.console
RUN cp /etc/conf.d/agetty /etc/conf.d/agetty.console
RUN rc-update add agetty.console default

# Username: root
# Password: default
RUN echo root:default | chpasswd

RUN mkdir /mnt/config /mnt/userdata

# Common configuration files
COPY etc /etc

# Example applications
COPY --from=mep-common-alpine-apps /bin /bin

ARG ETC_VERSION
RUN echo "$ETC_VERSION" > /etc/version
