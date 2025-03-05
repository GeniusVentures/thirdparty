#!/bin/sh

#  Automatic build script for libssl and libcrypto
#  for Android devices.

# -u  Attempt to use undefined variable outputs error message, and forces an exit
# -e  Abort script at first error, when a command exits with non-zero status (except in until or while loops, if-tests, list constructs)
# -o pipefail  Causes a pipeline to return the exit status of the last command in the pipe that returned a non-zero return value
echo "Top of openssl script"
set -ue

# Initialize variables
ABI=""
ANDROID_NATIVE_API_LEVEL=""
BUILD_DIR=""
LOCAL_PATH=""
LOCAL_ANDROID_NDK=""
LOCAL_ANDROID_TOOLCHAIN=""
DEBUG_FLAGS=""

convert_to_unix_path() {
  echo "$1" | tr ';' '\n' | while read -r path; do
    cygpath -u "$path"
  done | tr '\n' ':'
}
# Process command line arguments
collecting_path=false

for i in "$@"; do
  if [ "$collecting_path" = true ]; then
    case $i in
      --*) # Stop collecting if a new argument is encountered
        collecting_path=false
        ;;
      *)
        LOCAL_PATH="$LOCAL_PATH;$i"
        continue
        ;;
    esac
  fi

  case $i in
    --abi=*)
      ABI="${i#*=}"
      ;;
    --api-level=*)
      ANDROID_NATIVE_API_LEVEL="${i#*=}"
      ;;
    --build-dir=*)
      BUILD_DIR="${i#*=}"
      ;;
    --env_path=*)
      LOCAL_PATH="${i#*=}"
      collecting_path=true
      ;;
    --env_android_ndk=*)
      LOCAL_ANDROID_NDK="${i#*=}"
      ;;
    --env_android_toolchain=*)
      LOCAL_ANDROID_TOOLCHAIN="${i#*=}"
      ;;
    --debug)
      DEBUG_FLAGS="-g"
      ;;
    *)
      echo "Unknown argument: ${i}"
      ;;
  esac
done
#LOCAL_PATH=$(echo "$LOCAL_PATH" | xargs)
LOCAL_PATH=$(echo "$LOCAL_PATH" | sed 's/^;//' | sed 's/;$//')
# Print the values of the variables for verification
LOCAL_PATH=$(convert_to_unix_path "$LOCAL_PATH")
echo "ABI: $ABI"
echo "ANDROID_NATIVE_API_LEVEL: $ANDROID_NATIVE_API_LEVEL"
echo "BUILD_DIR: $BUILD_DIR"
echo "LOCAL_PATH: $LOCAL_PATH"
echo "LOCAL_ANDROID_NDK: $LOCAL_ANDROID_NDK"
echo "LOCAL_ANDROID_TOOLCHAIN: $LOCAL_ANDROID_TOOLCHAIN"
echo "DEBUG_FLAGS: $DEBUG_FLAGS"

ANDROID_NDK=$(cygpath -u "$LOCAL_ANDROID_NDK")
ANDROID_TOOLCHAIN=$(cygpath -u "$LOCAL_ANDROID_TOOLCHAIN")
echo "exports"
export ANDROID_NDK=$(cygpath -u "$LOCAL_ANDROID_NDK")
export ANDROID_TOOLCHAIN=$(cygpath -u "$LOCAL_ANDROID_TOOLCHAIN")
export PATH=$(cygpath -u "$LOCAL_ANDROID_NDK")/toolchains/llvm/prebuilt/windows-x86_64/bin:$(cygpath -u "$LOCAL_ANDROID_TOOLCHAIN"):$LOCAL_PATH
#export PATH="$LOCAL_ANDROID_NDK/toolchains/llvm/prebuilt/linux-x86_64/bin;$LOCAL_ANDROID_TOOLCHAIN;$LOCAL_PATH"
export CC=clang
SCRIPT_PATH="${0%/*}"
CONFIGDIR="$SCRIPT_PATH/../../../openssl"
REALCONFIGDIR=$(cd "$CONFIGDIR" && pwd)
OPENSSL_CONFIGURE_CMD="${REALCONFIGDIR}/Configure $DEBUG_FLAGS no-asm no-shared $ABI --prefix=$BUILD_DIR --openssldir=$BUILD_DIR" --libdir=lib android-arm64

echo "Building OpenSSL"
echo $OPENSSL_CONFIGURE_CMD

echo "Environment variables: \nPATH="$PATH


$OPENSSL_CONFIGURE_CMD

make -j 8 build_libs
