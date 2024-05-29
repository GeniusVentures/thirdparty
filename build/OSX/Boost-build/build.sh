# Init optional command line vars
SRC_DIR="."
BUILD_DIR="$(pwd)/build"
MACOSX_DEPLOYMENT_TARGET=10.12
VARIANT="release"

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
    --with-libraries=*)
        WITH_LIBRARIES="${i#*=}"
        shift
        ;;
    --debug)
        VARIANT="debug"
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

COMMON_BOOTSTRAP_PARAMS="--with-toolset=clang --with-libraries=${WITH_LIBRARIES}"

COMMON_BUILD_PARAMS="visibility=global cxxstd=17 address-model=64 binary-format=mach-o runtime-link=static link=static threading=multi --build-type=minimal --withvariant=${VARIANT} --stagedir=stage/x64"

COMMON_CXX_FLAGS="-Wno-enum-constexpr-conversion -D_LIBCPP_ENABLE_CXX17_REMOVED_UNARY_BINARY_FUNCTION"

# x86

X86_64_DIR=$BUILD_DIR/x86_64
if [ ! -d "$X86_64_DIR" ]; then
    mkdir -p "$X86_64_DIR"
fi

echo "Bootstapping x86"
cd $SRC_DIR
./bootstrap.sh ${COMMON_BOOTSTRAP_PARAMS} cxxflags="-arch x86_64 ${COMMON_CXX_FLAGS}" cflags="-arch x86_64" linkflags="-arch x86_64" >$X86_64_DIR/boostbuild.log 2>&1 || (echo "Error in Building Boost!" && cat $X86_64_DIR/boostbuild.log)

echo "Building for X86_64"
cd $SRC_DIR
./b2 cxxflags="-arch x86_64  ${COMMON_CXX_FLAGS}" ${COMMON_BUILD_PARAMS} --build-dir=$X86_64_DIR --prefix=$X86_64_DIR --libdir=$X86_64_DIR/lib install >$X86_64_DIR/boostbuild.log 2>&1 || (echo "Error in Building Boost!" && cat $X86_64_DIR/boostbuild.log)

if [ ! -d "$LIB_DIR" ]; then
    mkdir -p "$LIB_DIR"
fi

cp -R $X86_64_DIR/include $INSTALL_DIR/
cp -R $X86_64_DIR/lib/cmake $LIB_DIR/

# arm

ARM64_DIR=$BUILD_DIR/arm64
if [ ! -d "$ARM64_DIR" ]; then
    mkdir -p $ARM64_DIR
fi

echo "Bootstapping arm64"
cd $SRC_DIR
./bootstrap.sh ${COMMON_BOOTSTRAP_PARAMS} cxxflags="-arch arm64  ${COMMON_CXX_FLAGS}" cflags="-arch arm64" linkflags="-arch arm64" >$ARM64_DIR/boostbuild.log 2>&1 || (echo "Error in Building Boost!" && cat $ARM64_DIR/boostbuild.log)

cd $SRC_DIR
./b2 cxxflags="-arch arm64 -stdlib=libc++ -isysroot $MACOS_SDK_PATH  ${COMMON_CXX_FLAGS}" cflags="-arch arm64" linkflags="-arch arm64" abi=aapcs -mmacosx-version-min=12.1 ${COMMON_BUILD_PARAMS} architecture=arm --build-dir=$ARM64_DIR --prefix=$ARM64_DIR --libdir=$ARM64_DIR/lib install >$ARM64_DIR/boostbuild.log 2>&1 || (echo "Error in Building Boost!" && cat $ARM64_DIR/boostbuild.log)

for lib in $X86_64_DIR/lib/*.a; do
    lipo -create $lib $ARM64_DIR/lib/$(basename $lib) -output $LIB_DIR/$(basename $lib)
    # print fat library info
    lipo -info $LIB_DIR/$(basename $lib)
done
