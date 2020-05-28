# get the current working directory
rootdir=$(pwd)
yell() { echo "$0: $*" >&2; }
die() { yell "$*"; exit 111; }
try() { "$@" >>$rootdir/build-windows.log 2>&1 || die "command $* failed see build-windows.log"; }


# clear the log file
echo "" >build-windows.log

#
# Build the restclient-cpp for OSX
#
echo "*****************************************"
echo Building Windows version of gtest and curl library
yes | cp -rf ./build-patch/*  ./restclient-cpp/vendor/gtest-1.7.0/cmake/

cd restclient-cpp
cd vendor
cd gtest-1.7.0
try mkdir -p build/Windows/
try cd build/Windows
cmake ../.. -G "Visual Studio 15 2017 Win64"
cmake --build . --config Release

cd $rootdir/curl-android-ios
cd curl
try mkdir -p build/Windows/
try cd build/Windows
try rm CMakeCache.txt
cmake ../.. -G "Visual Studio 15 2017 Win64" -DBUILD_TESTING=OFF -DCMAKE_USE_OPENSSL=ON -DCURL_STATICLIB=ON
cmake --build . --config Release

echo "*****************************************"
echo "Building Windows version of restclient-cpp"
cd $rootdir/restclient-cpp
try mkdir -p build/Windows/
try cd build/Windows
try rm CMakeCache.txt
cmake ../.. -G "Visual Studio 15 2017 Win64"  -DCURL_LIBRARY=../../../curl-android-ios/curl/build/lib/Release/libcurl.lib    -DCURL_INCLUDE_DIR=../../../curl-android-ios/curl/include -DBUILD_SHARED_LIBS=NO
cmake --build . --config Release
echo "*****************************************"
echo "Building Windows version of cpp-ipfs-http-client"
cd $rootdir/cpp-ipfs-http-client
try mkdir -p build/Windows/
try cd build/Windows
currentDir=$(pwd)
$CacheFile = $currentDir/CMakeCache.txt
if [ -f "$CacheFile" ]; then    
	try rm CMakeCache.txt
fi

cmake ../.. -G "Visual Studio 15 2017 Win64"  -DCURL_LIBRARY=../../../curl-android-ios/curl/build/Windows/lib/Release/libcurl.lib    -DCURL_INCLUDE_DIR=../../../curl-android-ios/curl/include -DBUILD_SHARED_LIBS=NO -DJSON_FOR_MODERN_CXX_INCLUDE_DIR=../../../json/include -DBUILD_TESTING=OFF
cmake --build . --config Release
#try cmake  -DBUILD_TESTING=OFF -DCMAKE_INSTALL_PREFIX=../../Lib/Windows -DCMAKE_LIBRARY_OUTPUT_DIRECTORY=../../Lib/Windows ../../

