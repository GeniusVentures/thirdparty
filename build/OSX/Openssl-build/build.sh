#! /bin/bash
# Init optional command line vars
SRC_DIR="."
BUILD_DIR="$(pwd)/build"
MACOSX_DEPLOYMENT_TARGET=12.0
DEBUG_FLAGS=""

# Process command line arguments
for i in "$@"; do
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
    esac
done

echo "Building for x86_64"

INSTALL_DIR=$BUILD_DIR
LIB_DIR="$INSTALL_DIR/lib"

"$SRC_DIR/Configure" $DEBUG_FLAGS darwin64-x86_64-cc no-asm enable-threads no-shared --prefix="$BUILD_DIR" --openssldir="$BUILD_DIR" -mmacosx-version-min="$MACOSX_DEPLOYMENT_TARGET"

make build_generated libcrypto.a libssl.a -j4
make install_dev -j4
ARM64_DIR="$LIB_DIR/arm64"
mkdir -p "$ARM64_DIR"
cd "$ARM64_DIR"

"$SRC_DIR/Configure" $DEBUG_FLAGS darwin64-arm64-cc no-asm enable-threads no-shared --prefix="$ARM64_DIR" --openssldir="$ARM64_DIR" -mmacosx-version-min="$MACOSX_DEPLOYMENT_TARGET"

make build_generated libcrypto.a libssl.a -j4

echo "Building the fat library"
mv "$LIB_DIR"/libssl.a "$LIB_DIR"/libsslx86_64.a
mv "$LIB_DIR"/libcrypto.a "$LIB_DIR"/libcryptox86_64.a

lipo -create "$ARM64_DIR"/libssl.a "$LIB_DIR"/libsslx86_64.a -output "$LIB_DIR"/libssl.a
lipo -create "$ARM64_DIR"/libcrypto.a "$LIB_DIR"/libcryptox86_64.a -output "$LIB_DIR"/libcrypto.a
rm -rf "$ARM64_DIR"
rm "$LIB_DIR"/libsslx86_64.a
rm "$LIB_DIR"/libcryptox86_64.a
