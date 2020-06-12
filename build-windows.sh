# get the current working directory
rootdir=$(pwd)
yell() { echo "$0: $*" >&2; }
die() { yell "$*"; exit 111; }
try() { "$@" >>$rootdir/build-windows.log 2>&1 || die "command $* failed see build-windows.log"; }

# build function for a library in thirdparty
# @param $rootdir - Root(Parent) directory for sub library
# @param $1       - Sub library(directory) name
build_library_for_windows(){
	echo "***************************************************"
	echo --- Building Windows version of $1 library ----
	echo "==============================================="	
	try mkdir -p $rootdir/$1/build
	try cd $rootdir/$1/build
	try mkdir -p $rootdir/build/Windows/$1
	try cmake .. -G "Visual Studio 15 2017 Win64" -DCMAKE_INSTALL_PREFIX=$rootdir/build/Windows/$1 $2 $3 $4
	try cmake --build . --target install
	echo ---- $1 library was installed in $rootdir/build/Windows/$1. ---	
}

# clear the log file
echo "" >build-windows.log

# Make install directory for libraries
try mkdir -p build/Windows/

## Build GTest ##
build_library_for_windows GTest

## Build GSL ##
build_library_for_windows GSL
GSL_DIR=$rootdir/build/Windows/GSL
## Build spdlog v1.4.2##
build_library_for_windows spdlog
spdlog_DIR=$rootdir/build/Windows/spdlog/lib/spdlog/cmake

## Build tsl_hat_trie 343e0dac54fc8491065e8a059a02db9a2b1248ab##
build_library_for_windows hat-trie
tsl_hat_trie_DIR=$rootdir/build/Windows/hat-trie/lib/cmake/tsl_hat_trie

## Build Boost.DI c5287ee710ad90f5286d0cc2b9e49b72d89267a6##
build_library_for_windows Boost.DI -DBOOST_DI_OPT_BUILD_TESTS=OFF  -DBOOST_DI_OPT_BUILD_EXAMPLES=OFF
Boost_DI_DIR=$rootdir/build/Windows/Boost.DI/lib/cmake/Boost.DI

## Build Protobuf ## 
echo "***********************************************"
echo "*** Building Windows version of Protobuf library ***"
echo "==============================================="
try mkdir -p $rootdir/grpc/build_dir
try mkdir -p $rootdir/grpc/build_dir/protobuf
try cd $rootdir/grpc/build_dir/protobuf
try mkdir -p $rootdir/build/Windows/protobuf
try cmake ../../third_party/protobuf/cmake -G "Visual Studio 15 2017 Win64" -DCMAKE_INSTALL_PREFIX=$rootdir/build/Windows/protobuf -Dprotobuf_BUILD_TESTS=OFF -Dprotobuf_WITH_ZLIB=OFF -Dprotobuf_MSVC_STATIC_RUNTIME=OFF 
try cmake --build . --target install
echo "*** protobuf library was installed in $rootdir/build/Windows/protobuf. ***"
echo "--------------------------------------------------------------------------"
Protobuf_DIR=$rootdir/build/Windows/protobuf/cmake
Protobuf_LIBRARIES=$rootdir/build/Windows/protobuf/lib
Protobuf_INCLUDE_DIR=$rootdir/build/Windows/protobuf/include

## Build libp2p ## 
echo "***********************************************"
echo "*** Building Windows version of libp2p library ***"
echo "==============================================="
try mkdir -p $rootdir/libp2p
try mkdir -p $rootdir/libp2p/build
try cd $rootdir/libp2p/build
try mkdir -p $rootdir/build/Windows/libp2p
try cmake .. -G "Visual Studio 15 2017 Win64" -DCMAKE_INSTALL_PREFIX=$rootdir/build/Windows/libp2p \
 -DCMAKE_USE_OPENSSL=ON -DBUILD_EXAMPLES=OFF -DTESTING=OFF -DDEXPOSE_MOCKS=OFF -DHUNTER_ENABLED=OFF \
 -DProtobuf_DIR=$Protobuf_DIR -DProtobuf_LIBRARIES=$Protobuf_LIBRARIES -DProtobuf_INCLUDE_DIR=$Protobuf_INCLUDE_DIR \
 -DGSL_DIR=$GSL_DIR -DGSL_INCLUDE_DIR=$GSL_DIR/include   -Dspdlog_DIR=$spdlog_DIR -Dtsl_hat_trie_DIR=$tsl_hat_trie_DIR \
 -DBoost.DI_DIR=$Boost_DI_DIR -DBoost_ROOT="C:/local/boost_1_72_0" -DBoost_INCLUDE_DIR="C:/local/boost_1_72_0" \
 -DBoost_LIBRARY_DIR="C:/local/boost_1_72_0/lib64-msvc-14.1"
try cmake --build . --target install
echo "*** libp2p library was installed in $rootdir/build/Windows/libp2p. ***"
echo "--------------------------------------------------------------------------"



