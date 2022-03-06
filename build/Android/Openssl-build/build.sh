#!/bin/sh

#  Automatic build script for libssl and libcrypto
#  for Android devices.

# -u  Attempt to use undefined variable outputs error message, and forces an exit
# -e  Abort script at first error, when a command exits with non-zero status (except in until or while loops, if-tests, list constructs)
# -o pipefail  Causes a pipeline to return the exit status of the last command in the pipe that returned a non-zero return value
set -ue

ABI=""
ANDROID_NATIVE_API_LEVEL=""
BUILD_DIR=""
LOCAL_PATH=""
LOCAL_ANDROID_NDK=""
LOCAL_ANDROID_TOOLCHAIN=""

# Process command line arguments
for i in "$@"
do
case $i in
  --abi=*)
    ABI="${i#*=}"
    shift
    ;;
  --api-level=*)
    ANDROID_NATIVE_API_LEVEL="${i#*=}"
    shift
    ;;
  --build-dir=*)
    BUILD_DIR="${i#*=}"
    shift
    ;;
  --env_path=*)
    LOCAL_PATH="${i#*=}"
    shift
    ;;
  --env_android_ndk=*)
    LOCAL_ANDROID_NDK="${i#*=}"
    shift
    ;;
  --env_android_toolchain=*)
    LOCAL_ANDROID_TOOLCHAIN="${i#*=}"
    shift
    ;;
  *)
    echo "Unknown argument: ${i}"
    ;;
esac
done

export ANDROID_NDK=$LOCAL_ANDROID_NDK
export ANDROID_TOOLCHAIN=$LOCAL_ANDROID_TOOLCHAIN
export PATH=$LOCAL_ANDROID_NDK:$LOCAL_ANDROID_TOOLCHAIN:$LOCAL_PATH
export CC=clang
CONFIGDIR=`dirname $0`/../../../openssl
REALCONFIGDIR=`realpath ${CONFIGDIR}`
OPENSSL_CONFIGURE_CMD="${REALCONFIGDIR}/Configure no-asm $ABI --prefix=$BUILD_DIR --openssldir=$BUILD_DIR"

echo "Building OpenSSL"
echo $OPENSSL_CONFIGURE_CMD

echo "Environment variables: \nPATH="$PATH
which clang

$OPENSSL_CONFIGURE_CMD

make build_libs
