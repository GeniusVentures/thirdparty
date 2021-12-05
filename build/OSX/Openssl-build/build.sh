

# Init optional command line vars
SRC_DIR="."
BUILD_DIR="`pwd`/build"
CONFIG=""

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
  *)
    echo "Unknown argument: ${i}"
    ;;
esac
done

make clean

LIB_DIR=$BUILD_DIR/lib
cd $SRC_DIR
./Configure darwin64-x86_64-cc shared --prefix=$BUILD_DIR --openssldir=$BUILD_DIR
make build_libs
make install_dev

LIB_X86_64_DIR=$BUILD_DIR/lib_x86_64
mkdir -p $LIB_X86_64_DIR
cp $BUILD_DIR/lib/libssl.1.1.dylib $LIB_X86_64_DIR
cp $BUILD_DIR/lib/libssl.a $LIB_X86_64_DIR
cp $BUILD_DIR/lib/libcrypto.1.1.dylib $LIB_X86_64_DIR
cp $BUILD_DIR/lib/libcrypto.a $LIB_X86_64_DIR


make clean

ARM64_DIR=$BUILD_DIR/arm64
./Configure $CONFIG darwin64-arm64-cc no-asm --prefix=$ARM64_DIR --openssldir=$ARM64_DIR
make build_libs
make install_dev

LIB_ARM64_DIR=$BUILD_DIR/lib_arm64
mkdir -p $LIB_ARM64_DIR
cp $ARM64_DIR/lib/libssl.1.1.dylib $LIB_ARM64_DIR
cp $ARM64_DIR/lib/libssl.a $LIB_ARM64_DIR
cp $ARM64_DIR/lib/libcrypto.1.1.dylib $LIB_ARM64_DIR
cp $ARM64_DIR/lib/libcrypto.a $LIB_ARM64_DIR

lipo -create $LIB_X86_64_DIR/libssl.1.1.dylib $LIB_ARM64_DIR/libssl.1.1.dylib -output $LIB_DIR/libssl.1.1.dylib
lipo -create $LIB_X86_64_DIR/libcrypto.1.1.dylib $LIB_ARM64_DIR/libcrypto.1.1.dylib -output $LIB_DIR/libcrypto.1.1.dylib
lipo -create $LIB_X86_64_DIR/libssl.a $LIB_ARM64_DIR/libssl.a -output $LIB_DIR/libssl.a
lipo -create $LIB_X86_64_DIR/libcrypto.a $LIB_ARM64_DIR/libcrypto.a -output $LIB_DIR/libcrypto.a
ln -s $LIB_DIR/libssl.1.1.dylib $LIB_DIR/libssl.dylib
ln -s $LIB_DIR/libcrypto.1.1.dylib $LIB_DIR/libcrypto.dylib
