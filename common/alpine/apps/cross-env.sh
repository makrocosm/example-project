ARCH="$1"
VARIANT="$2"
ABI="musl"

case "$ARCH/$VARIANT" in
amd64/*)
  ARCH="x86_64"
  ;;
arm64/*)
  ARCH="aarch64"
  ;;
riscv64/*)
  ARCH="riscv"
  ;;
arm/v7)
  ARCH="armv7"
  ABI="musleabihf"
  ;;
esac

export SYSROOT="/sysroot"
export PKG_CONFIG_EXECUTABLE="$(which pkg-config)"
export PKG_CONFIG_SYSROOT_DIR="${SYSROOT}"
export PKG_CONFIG_PATH="${SYSROOT}/usr/lib/pkgconfig:${SYSROOT}/usr/share/pkgconfig"
export CFLAGS="--target=$ARCH-alpine-linux-$ABI --sysroot=$SYSROOT"
export CXXFLAGS="--target=$ARCH-alpine-linux-$ABI --sysroot=$SYSROOT"
export LDFLAGS="--target=$ARCH-alpine-linux-$ABI --sysroot=$SYSROOT -fuse-ld=lld"

export CC="clang"
export CXX="clang++"
export CPP="clang-cpp"
export AS="llvm-as"
export LD="llvm-ld"
export STRIP="llvm-strip"
export RANLIB="llvm-ranlib"
export OBJCOPY="llvm-objcopy"
export OBJDUMP="llvm-objdump"
export READELF="llvm-readelf"
export AR="llvm-ar"
export NM="llvm-nm"
