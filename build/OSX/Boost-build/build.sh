

# Init optional command line vars
SRC_DIR="."
BUILD_DIR="`pwd`/build"
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
  --deployment-target=*)
    MACOSX_DEPLOYMENT_TARGET="${i#*=}"
    shift
    ;;
  *)
    echo "Unknown argument: ${i}"
    ;;
esac
done

INSTALL_DIR=$BUILD_DIR
LIB_DIR="$INSTALL_DIR/lib"

MACOS_SDK_PATH=$(xcrun --sdk macosx --show-sdk-path)

echo "Bootstapping..."
cd $SRC_DIR
./bootstrap.sh cxxflags="-arch x86_64 -arch arm64" cflags="-arch x86_64 -arch arm64" linkflags="-arch x86_64 -arch arm64" > $X86_64_DIR/boostbuild.log 2>&1 || (echo "Error in Building Boost!" && cat $X86_64_DIR/boostbuild.log)

COMMOM_PARAMS="toolset=clang -a target-os=darwin address-model=64 binary-format=mach-o runtime-link=static link=static threading=multi --build-type=minimal --with-log --with-thread --with-program_options --with-system --with-date_time --with-regex --with-chrono --with-atomic --with-random --with-filesystem variant=release --stagedir=stage/x64"

X86_64_DIR=$BUILD_DIR/x86_64
if [ ! -d "$X86_64_DIR" ]; then
  mkdir -p "$X86_64_DIR"
fi

echo "building for X86_64..."
cd $SRC_DIR
./b2 -j8 cxxflags="-arch x86_64" $COMMOM_PARAMS --build-dir=$X86_64_DIR --prefix=$X86_64_DIR --libdir=$X86_64_DIR/lib install > $X86_64_DIR/boostbuild.log 2>&1 || (echo "Error in Building Boost!" && cat $X86_64_DIR/boostbuild.log)

if [ ! -d "$LIB_DIR" ]; then
  mkdir -p "$LIB_DIR"
fi

cp -R $X86_64_DIR/include $INSTALL_DIR/
cp -R $X86_64_DIR/lib/cmake $LIB_DIR/

ARM64_DIR=$BUILD_DIR/arm64
if [ ! -d "$ARM64_DIR" ]; then
  mkdir -p $ARM64_DIR
fi

echo "Bootstapping... for arm64"
cd $SRC_DIR
./bootstrap.sh cxxflags="-arch arm64" cflags="-arch arm64" linkflags="-arch arm64" > $ARM64_DIR/boostbuild.log 2>&1 || (echo "Error in Building Boost!" && cat $ARM64_DIR/boostbuild.log)

cd $SRC_DIR
./b2 -j8 cxxflags="-arch arm64 -stdlib=libc++ -isysroot $MACOS_SDK_PATH" cflags="-arch arm64" linkflags="-arch arm64" abi=aapcs -mmacosx-version-min=12.1 $COMMOM_PARAMS architecture=arm --build-dir=$ARM64_DIR --prefix=$ARM64_DIR --libdir=$ARM64_DIR/lib install > $ARM64_DIR/boostbuild.log 2>&1 || (echo "Error in Building Boost!" && cat $ARM64_DIR/boostbuild.log)

for lib in $X86_64_DIR/lib/*.a; do
  lipo -create $lib $ARM64_DIR/lib/$(basename $lib) -output $LIB_DIR/$(basename $lib);
  # print fat library info
  lipo -info $LIB_DIR/$(basename $lib);
done
