

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
  *)
    echo "Unknown argument: ${i}"
    ;;
esac
done

INSTALL_DIR=$BUILD_DIR
LIB_DIR="$INSTALL_DIR/lib"

X86_64_DIR=$BUILD_DIR/x86_64
if [ ! -d "$X86_64_DIR" ]; then
  mkdir -p "$X86_64_DIR"
fi
cd $X86_64_DIR
if [ ! -f "Makefile" ]; then
  $SRC_DIR/Configure $DEBUG_FLAGS darwin64-x86_64-cc no-asm shared --prefix=$INSTALL_DIR --openssldir=$INSTALL_DIR
fi
make build_libs

if [ ! -d "$LIB_DIR/x86_64" ]; then
  mkdir -p "$LIB_DIR/x86_64"
fi

if [ ! -d "$LIB_DIR/pkgconfig" ]; then
  mkdir -p "$LIB_DIR/pkgconfig"
fi

cp $X86_64_DIR/lib*.dylib $LIB_DIR/x86_64
cp $X86_64_DIR/lib*.a $LIB_DIR/x86_64
cp -R $X86_64_DIR/include $INSTALL_DIR/
cp -R $SRC_DIR/include/openssl $INSTALL_DIR/include/
cp -R $X86_64_DIR/*.pc $LIB_DIR/pkgconfig

ARM64_DIR=$BUILD_DIR/arm64
if [ ! -d "$ARM64_DIR" ]; then
  mkdir -p $ARM64_DIR
fi
cd $ARM64_DIR
if [ ! -f "Makefile" ]; then
  $SRC_DIR/Configure $DEBUG_FLAGS darwin64-arm64-cc no-asm --prefix=$ARM64_DIR --openssldir=$ARM64_DIR
fi

if [ ! -d "$LIB_DIR/arm64" ]; then
  mkdir -p "$LIB_DIR/arm64"
fi

make build_libs
cp $ARM64_DIR/lib*.dylib $LIB_DIR/arm64
cp $ARM64_DIR/lib*.a $LIB_DIR/arm64


lipo -create $LIB_DIR/x86_64/libssl.1.1.dylib $LIB_DIR/arm64/libssl.1.1.dylib -output $LIB_DIR/libssl.1.1.dylib
lipo -create $LIB_DIR/x86_64/libcrypto.1.1.dylib $LIB_DIR/arm64/libcrypto.1.1.dylib -output $LIB_DIR/libcrypto.1.1.dylib
lipo -create $LIB_DIR/x86_64/libssl.a $LIB_DIR/arm64/libssl.a -output $LIB_DIR/libssl.a
lipo -create $LIB_DIR/x86_64/libcrypto.a $LIB_DIR/arm64/libcrypto.a -output $LIB_DIR/libcrypto.a
if [ ! -f $LIB_DIR/libssl.dylib ]; then
  ln -s $LIB_DIR/libssl.1.1.dylib $LIB_DIR/libssl.dylib
fi

if [ ! -f $LIB_DIR/libcrypto.dylib ]; then
  ln -s $LIB_DIR/libcrypto.1.1.dylib $LIB_DIR/libcrypto.dylib
fi

# print fat library info
lipo -info $LIB_DIR/libssl.1.1.dylib
lipo -info $LIB_DIR/libcrypto.1.1.dylib
