# Init optional command line vars
SRC_DIR="."
BUILD_DIR="$(pwd)/build"
MACOSX_DEPLOYMENT_TARGET=10.12
VARIANT="Release"

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
        VARIANT="Debug"
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
echo "BUILDDIR ${INSTALL_DIR}"
echo "Getting dependencies..."
cd $SRC_DIR
echo "Src Dir ${SRC_DIR}"
./fetchDependencies --macos

echo "building..."

if [ "$VARIANT" != "Debug" ]; then
	xcodebuild build -quiet -project MoltenVKPackaging.xcodeproj GCC_PREPROCESSOR_DEFINITIONS='$GCC_PREPROCESSOR_DEFINITIONS MVK_CONFIG_LOG_LEVEL=1' -scheme "MoltenVK Package (macOS only)" -configuration "${VARIANT}" -archivePath "${INSTALL_DIR} ONLY_ACTIVE_ARCH=NO -arch x86_64 -arch arm64"
else
	xcodebuild build -quiet -project MoltenVKPackaging.xcodeproj -scheme "MoltenVK Package (macOS only)" -configuration "${VARIANT}" -archivePath "${INSTALL_DIR} ONLY_ACTIVE_ARCH=NO -arch x86_64 -arch arm64"
fi

mkdir -p ${LIB_DIR}
cp -R ./Package/"${VARIANT}"/MoltenVK/include "${INSTALL_DIR}"/
cp -R ./Package/"${VARIANT}"/MoltenVK/static/* "${LIB_DIR}"/
