yell() { echo "$0: $*" >&2; }
die() { yell "$*"; exit 111; }
try() { "$@" >>$rootdir/build-linux.log 2>&1 || die "command $* failed see build-linux.log"; }

# get the current working directory
rootdir=$(pwd)
# clear the log file
echo "" >build-linux.log

#
# Build the restclient-cpp for OSX
#
echo Building linux version of restclient-cpp
cd restclient-cpp
try mkdir -p build/Linux/
try cd build/Linux/
try cmake -DCMAKE_INSTALL_PREFIX=../../Lib/Linux -DCMAKE_LIBRARY_OUTPUT_DIRECTORY=../../Lib/Linux ../../
