#!/bin/sh

#  Automatic build script for libssl and libcrypto
#  for Android devices.

# -u  Attempt to use undefined variable outputs error message, and forces an exit
# -e  Abort script at first error, when a command exits with non-zero status (except in until or while loops, if-tests, list constructs)
# -o pipefail  Causes a pipeline to return the exit status of the last command in the pipe that returned a non-zero return value
set -ue


# Process command line arguments
for i in "$@"
do
case $i in
  --grpc-dir=*)
    GRPC_DIR="${i#*=}"
    shift
    ;;
  --patch-dir=*)
    PATCH_DIR="${i#*=}"
    shift
    ;;
  *)
    echo "Unknown argument: ${i}"
    ;;
esac
done

echo "Patching grpc CMakeLists.txt file at ${GRPC_DIR}/CMakeLists.txt"
cp ${PATCH_DIR}/patch.CMakeLists.txt ${GRPC_DIR}/CMakeLists.txt

echo "Patching protobuf CMake file at ${GRPC_DIR}/third_party/protobuf/cmake/libprotobuf.cmake"
cp ${PATCH_DIR}/patch.libprotobuf.cmake ${GRPC_DIR}/third_party/protobuf/cmake/libprotobuf.cmake

echo "Patching protobuf CMake file at ${GRPC_DIR}/third_party/protobuf/cmake/libprotobuf-lite.cmake"
cp ${PATCH_DIR}/patch.libprotobuf-lite.cmake ${GRPC_DIR}/third_party/protobuf/cmake/libprotobuf-lite.cmake
