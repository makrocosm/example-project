make \
  CROSS_COMPILE=arm-linux-gnueabihf- \
  CROSS_COMPILE64=aarch64-linux-gnu- \
  PLATFORM=k3-am62x \
  CFG_ARM64_core=y \
  CFG_WITH_SOFTWARE_PRNG=y
