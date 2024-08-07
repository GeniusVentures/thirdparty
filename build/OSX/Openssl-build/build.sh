

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

if $X86_64_PRESENT; then
  if [ ! -f "Makefile" ]; then
    $SRC_DIR/Configure $DEBUG_FLAGS darwin64-x86_64-cc -static --prefix=$BUILD_DIR --openssldir=$BUILD_DIR -mmacosx-version-min=$MACOSX_DEPLOYMENT_TARGET
  fi
  make build_generated libcrypto.a libssl.a
  make install_dev
fi

if $ARM64_PRESENT; then

  ARM64_DIR="$BUILD_DIR"

  if $X86_64_PRESENT; then
    ARM64_DIR="$LIB_DIR/arm64"
    mkdir -p "$ARM64_DIR"
    cd $ARM64_DIR
  fi

  $SRC_DIR/Configure $DEBUG_FLAGS darwin64-arm64-cc no-asm -static --prefix=$ARM64_DIR --openssldir=$ARM64_DIR -mmacosx-version-min=$MACOSX_DEPLOYMENT_TARGET

  make build_generated libcrypto.a libssl.a
  if ! $X86_64_PRESENT ; then
      make install_dev
  fi
fi


if $X86_64_PRESENT && $ARM64_PRESENT; then
  echo "Building the fat library"
  mv $LIB_DIR/libssl.a $LIB_DIR/libssltemp.a 
  mv $LIB_DIR/libcrypto.a $LIB_DIR/libcryptotemp.a 

  lipo -create $ARM64_DIR/libssl.a $LIB_DIR/libssltemp.a -output $LIB_DIR/libssl.a
  lipo -create $ARM64_DIR/libcrypto.a $LIB_DIR/libssltemp.a -output $LIB_DIR/libcrypto.a
  rm -rf $ARM64_DIR
  rm $LIB_DIR/libssltemp.a 
  rm $LIB_DIR/libcryptotemp.a 
fi
