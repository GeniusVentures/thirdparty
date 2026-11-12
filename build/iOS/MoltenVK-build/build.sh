
# Init optional command line vars
SRC_DIR="."
BUILD_DIR="`pwd`/build"
MACOSX_DEPLOYMENT_TARGET=10.12
VARIANT="Release"
SDK="iphoneos"

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
    --sdk=*)
      SDK="${i#*=}"
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

IOS_SDK_PATH=$(xcrun --sdk ${SDK} --show-sdk-path)
echo "BUILDDIR ${INSTALL_DIR}"
echo "Getting dependencies..."
cd $SRC_DIR
echo "Src Dir ${SRC_DIR}"
if [ "${SDK}" = "iphonesimulator" ]; then
  ./fetchDependencies --iossim
else
  ./fetchDependencies --ios
fi

echo "building..."

xcodebuild build -quiet -project MoltenVKPackaging.xcodeproj -scheme "MoltenVK Package (iOS only)" -configuration "${VARIANT}" -sdk ${SDK} -archivePath "${INSTALL_DIR}"

mkdir -p ${LIB_DIR}
cp -R ./Package/"${VARIANT}"/MoltenVK/include "${INSTALL_DIR}"/
cp -R ./Package/"${VARIANT}"/MoltenVK/static/* "${LIB_DIR}"/
