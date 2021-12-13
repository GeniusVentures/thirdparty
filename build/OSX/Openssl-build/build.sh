

# Init optional command line vars
SRC_DIR="."
BUILD_DIR="`pwd`/build"
CONFIG=""
CONFIG_DIR=""
MACOSX_DEPLOYMENT_TARGET=10.12

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
  --config=*)
    CONFIG="--config=${i#*=}"
    shift
    ;;
  --deployment-target=*)
    MACOSX_DEPLOYMENT_TARGET="${i#*=}"
    shift
    ;;
  *)
    echo "Unknown argument: ${i}"
    ;;
esac
done

INSTALL_DIR=$(cd "$BUILD_DIR/../../"; pwd)
LIB_DIR="$INSTALL_DIR/lib"

echo "INSTALL_DIR is $INSTALL_DIR"
echo "BUILD_DIR is $BUILD_DIR"
echo "LIB_DIR is $LIB_DIR"

X86_64_DIR=$BUILD_DIR/x86_64
if [ ! -d "$X86_64_DIR" ]; then
  mkdir -p "$X86_64_DIR"
fi
cd $X86_64_DIR
if [ ! -f "Makefile" ]; then
  $SRC_DIR/Configure darwin64-x86_64-cc shared --prefix=$INSTALL_DIR --openssldir=$BUILD_DIR
fi
make build_libs

if [ ! -d "$LIB_DIR/x86_64" ]; then
  mkdir -p "$LIB_DIR/x86_64"
fi

cp $X86_64_DIR/lib*.dylib $LIB_DIR/x86_64
cp $X86_64_DIR/lib*.a $LIB_DIR/x86_64
cp $X86_64_DIR/include $INSTALL_DIR

ARM64_DIR=$BUILD_DIR/arm64
if [ ! -d "$ARM64_DIR" ]; then
  mkdir -p $ARM64_DIR
fi
cd $ARM64_DIR
if [ ! -f "Makefile" ]; then
  $SRC_DIR/Configure $CONFIG darwin64-arm64-cc no-asm --prefix=$ARM64_DIR --openssldir=$ARM64_DIR
fi

if [ ! -d "$LIB_DIR/arm64" ]; then
  mkdir -p "$LIB_DIR/arm64"
fi

make build_libs
cp $ARM64_DIR/lib*.dylib $LIB_DIR/arm64
cp $ARM64_DIR/lib*.a $LIB_DIR/arm64

if [ ! -d "$LIB_DIR/universal" ]; then
  mkdir -p $LIB_DIR/universal
fi

lipo -create $LIB_DIR/x86_64/libssl.1.1.dylib $LIB_DIR/arm64/libssl.1.1.dylib -output $LIB_DIR/universal/libssl.1.1.dylib
lipo -create $LIB_DIR/x86_64/libcrypto.1.1.dylib $LIB_DIR/arm64/libcrypto.1.1.dylib -output $LIB_DIR/universal/libcrypto.1.1.dylib
lipo -create $LIB_DIR/x86_64/libssl.a $LIB_DIR/arm64/libssl.a -output $LIB_DIR/universal/libssl.a
lipo -create $LIB_DIR/x86_64/libcrypto.a $LIB_DIR/arm64/libcrypto.a -output $LIB_DIR/universal/libcrypto.a
if [ ! -f $LIB_DIR/universal/libssl.dylib ]; then
  ln -s $LIB_DIR/universal/libssl.1.1.dylib $LIB_DIR/universal/libssl.dylib
fi

if [ ! -f $LIB_DIR/universal/libcrypto.dylib ]; then
  ln -s $LIB_DIR/universal/libcrypto.1.1.dylib $LIB_DIR/universal/libcrypto.dylib
fi

# print fat library info
lipo -info $LIB_DIR/universal/libssl.1.1.dylib
lipo -info $LIB_DIR/universal/libssl.dylib
lipo -info $LIB_DIR/universal/libcrypto.1.1.dylib
lipo -info $LIB_DIR/universal/libcrypto.dylib
