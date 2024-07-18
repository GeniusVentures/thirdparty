

# Init optional command line vars
SRC_DIR="."
BUILD_DIR="`pwd`/build"
MACOSX_DEPLOYMENT_TARGET=10.12
DEBUG_FLAGS=""

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
  --debug)
    DEBUG_FLAGS="-g"
    shift
    ;;
  --release)
    DEBUG_FLAGS=""
    shift
    ;;
  *)
    echo "Unknown argument: ${i}"
    ;;
esac
done

INSTALL_DIR=$BUILD_DIR
LIB_DIR="$INSTALL_DIR/lib"

X86_64_DIR="$LIB_DIR/x86_64"
if [ ! -d "$X86_64_DIR" ]; then
  mkdir -p "$X86_64_DIR"
fi
cd $X86_64_DIR
if [ ! -f "Makefile" ]; then
  $SRC_DIR/Configure $DEBUG_FLAGS darwin64-x86_64-cc -static --prefix=$LIB_DIR --openssldir=$X86_64_DIR -mmacosx-version-min=$MACOSX_DEPLOYMENT_TARGET
fi
make -j`nproc` build_generated libcrypto.a libssl.a libcrypto.pc libssl.pc openssl.pc

if [ ! -d "$LIB_DIR/pkgconfig/" ]; then
  mkdir -p "$LIB_DIR/pkgconfig/"
fi

#cp $X86_64_DIR/lib*.dylib $LIB_DIR/x86_64
#cp $X86_64_DIR/lib*.a $LIB_DIR/x86_64
cp -R $X86_64_DIR/include $INSTALL_DIR/
cp -R $SRC_DIR/include/openssl $INSTALL_DIR/include/
cp -R $X86_64_DIR/*.pc $LIB_DIR/pkgconfig

ARM64_DIR=$LIB_DIR/arm64
if [ ! -d "$ARM64_DIR" ]; then
  mkdir -p $ARM64_DIR
fi
cd $ARM64_DIR
if [ ! -f "Makefile" ]; then
  $SRC_DIR/Configure $DEBUG_FLAGS darwin64-arm64-cc no-asm -static --prefix=$LIB_DIR --openssldir=$ARM64_DIR -mmacosx-version-min=$MACOSX_DEPLOYMENT_TARGET
fi

make -j`nproc` build_generated libcrypto.a libssl.a

lipo -create $X86_64_DIR/libssl.a $ARM64_DIR/libssl.a -output $LIB_DIR/libssl.a
lipo -create $X86_64_DIR/libcrypto.a $ARM64_DIR/libcrypto.a -output $LIB_DIR/libcrypto.a
