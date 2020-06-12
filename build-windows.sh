# get the current working directory
rootdir=$(pwd)
yell() { echo "$0: $*" >&2; }
die() { yell "$*"; exit 111; }
try() { "$@" >>$rootdir/build-windows.log 2>&1 || die "command $* failed see build-windows.log"; }


# clear the log file
echo "" >build-windows.log

# make build directory
try mkdir -p build/Windows/

#
# Build GTest
#
echo "***********************************************"
echo "*** Building Windows version of GTest library ***"
echo "==============================================="
try mkdir -p $rootdir/GTest/build
try cd $rootdir/GTest/build
try mkdir -p $rootdir/build/Windows/GTest
try cmake .. -G "Visual Studio 15 2017 Win64" -DCMAKE_INSTALL_PREFIX=$rootdir/build/Windows/GTest
try cmake --build . --config Release
echo "*** Installing Windows version of GTest library ***"
try cmake --install .



