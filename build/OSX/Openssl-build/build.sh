

# Init optional command line vars
SRC_DIR="."
BUILD_DIR="`pwd`/build"
MACOSX_DEPLOYMENT_TARGET=10.12
DEBUG_FLAGS=""
ARCHITECTURES=""
X86_64_PRESENT=false
ARM64_PRESENT=false

# Process command line arguments
for i in "$@"
do
case $i in
  --src-dir=*)
    SRC_DIR="${i#*=}"
    shift
    ;;
  --build-dir=*)
    BUILD_DIR="${i#*=}"
    shift
    ;;
  --deployment-target=*)
    MACOSX_DEPLOYMENT_TARGET="${i#*=}"
    shift
    ;;
  --arch=*)
    ARCHITECTURES="${i#*=}"
    shift
    ;;
  --debug)
    DEBUG_FLAGS="-g"
    shift
    ;;
  --release)
    DEBUG_FLAGS=""
    shift
    ;;
esac
done

echo "Architectures selected $ARCHITECTURES"

if [[ $ARCHITECTURES == *"x86_64"* ]]; then
  X86_64_PRESENT=true
fi
if [[ $ARCHITECTURES == *"arm64"* ]]; then
  ARM64_PRESENT=true
fi

INSTALL_DIR=$BUILD_DIR
LIB_DIR="$INSTALL_DIR/lib"
OUT_DIR=""

if $X86_64_PRESENT; then
  X86_64_DIR="$LIB_DIR/x86_64"
  if [ ! -d "$X86_64_DIR" ]; then
    mkdir -p "$X86_64_DIR"
  fi
  cd $X86_64_DIR
  if [ ! -f "Makefile" ]; then
    $SRC_DIR/Configure $DEBUG_FLAGS darwin64-x86_64-cc -static --prefix=$LIB_DIR --openssldir=$X86_64_DIR -mmacosx-version-min=$MACOSX_DEPLOYMENT_TARGET
  fi
  make build_generated libcrypto.a libssl.a
  OUT_DIR=$X86_64_DIR
fi

if $ARM64_PRESENT; then
  ARM64_DIR=$LIB_DIR/arm64
  if [ ! -d "$ARM64_DIR" ]; then
    mkdir -p $ARM64_DIR
  fi
  cd $ARM64_DIR
  if [ ! -f "Makefile" ]; then
    $SRC_DIR/Configure $DEBUG_FLAGS darwin64-arm64-cc no-asm -static --prefix=$LIB_DIR --openssldir=$ARM64_DIR -mmacosx-version-min=$MACOSX_DEPLOYMENT_TARGET
  fi

  make build_generated libcrypto.a libssl.a
  OUT_DIR=$ARM64_DIR
fi

make build_generated libcrypto.pc libssl.pc openssl.pc
if [ ! -d "$LIB_DIR/pkgconfig/" ]; then
  mkdir -p "$LIB_DIR/pkgconfig/"
fi

cp -R $OUT_DIR/include $INSTALL_DIR/
cp -R $SRC_DIR/include/openssl $INSTALL_DIR/include/
cp -R $OUT_DIR/*.pc $LIB_DIR/pkgconfig


if $X86_64_PRESENT && $ARM64_PRESENT; then
  echo "Building the fat library"
  lipo -create $X86_64_DIR/libssl.a $ARM64_DIR/libssl.a -output $LIB_DIR/libssl.a
  lipo -create $X86_64_DIR/libcrypto.a $ARM64_DIR/libcrypto.a -output $LIB_DIR/libcrypto.a
  rm -rf $ARM64_DIR/
  rm -rf $X86_64_DIR/
else
  mv $OUT_DIR/libssl.a $LIB_DIR/
  mv $OUT_DIR/libcrypto.a $LIB_DIR/
fi
