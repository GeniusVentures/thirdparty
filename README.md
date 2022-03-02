This is the repository for third party of SuperGenius
===================================

# CI/CD Status
[![Release Build CI](https://github.com/GeniusVentures/thirdparty/actions/workflows/cmake.yml/badge.svg?branch=master)](https://github.com/GeniusVentures/thirdparty/actions/workflows/cmake.yml)
[![Release Build CI](https://github.com/GeniusVentures/thirdparty/actions/workflows/cmake.yml/badge.svg?branch=develop)](https://github.com/GeniusVentures/thirdparty/actions/workflows/cmake.yml)

# Build on Windows

## Preinstall
- CMake
- Visual Studio 2015, 2017 or 2019
- Strawberry Perl (https://strawberryperl.com/)
- Python >=3.5
## Building
    ○ git submodule update --init --recursive
    ○ cd ./build
    ○ mkdir Release
    ○ cd Release
    ○ cmake ../Windows -G "Visual Studio 16 2019" -A x64 -DCMAKE_BUILD_TYPE=Release
    ○ cmake --build . --config Release

### Building for debugging
	○ git pull
	○ git submodule update --init --recursive
	○ cd ./build
	○ mkdir Debug
	○ cd Debug
	○ cmake ../Windows -G "Visual Studio 16 2019" -A x64 -DCMAKE_BUILD_TYPE=Debug
	○ cmake --build . --config Debug
# Build on Linux
## Preinstall
- CMake
- Python >=3.5 (make sure /bin/python links to your python3 version, e.g. `ln -s /bin/python3.8 /bin/python`)
## Building
	○ mkdir .build.Release
	○ cd ./.build.Release
	○ cmake . -DCMAKE_BUILD_TYPE=Release
	○ make
# Build on Linux for Android cross compile
## Preinstall
- CMake
- Android NDK Latest LTS Version (r23b) [(link)](https://developer.android.com/ndk/downloads#lts-downloads)
## Building
	○ export ANDROID_NDK=/path/to/android-ndk-r23b
	○ export ANDROID_TOOLCHAIN="$ANDROID_NDK/toolchains/llvm/prebuilt/linux-x86_64/bin"
	○ export PATH="$ANDROID_TOOLCHAIN":"$PATH"
* armeabi-v7a
```
○ mkdir .build.Android.armeabi-v7a
○ cd ./.build.Android.armeabi-v7a
○ cmake -S ../build/Android/ -DANDROID_ABI="armeabi-v7a" -DCMAKE_ANDROID_NDK=$ANDROID_NDK -DANDROID_TOOLCHAIN=clang
○ make -j4
```
* arm64-v8a
```
○ mkdir .build.Android.arm64-v8a
○ cd ./.build.Android.arm64-v8a
○ cmake -S ../build/Android/ -DANDROID_ABI="arm64-v8a" -DCMAKE_ANDROID_NDK=$ANDROID_NDK -DANDROID_TOOLCHAIN=clang
○ make -j4
```
* x86
```
○ mkdir .build.Android.x86
○ cd ./.build.Android.x86
○ cmake -S ../build/Android/ -DANDROID_ABI="x86" -DCMAKE_ANDROID_NDK=$ANDROID_NDK -DANDROID_TOOLCHAIN=clang
○ make -j4
```
* x86_64
```
○ mkdir .build.Android.x86_64
○ cd ./.build.Android.x86_64
○ cmake -S ../build/Android/ -DANDROID_ABI="x86_64" -DCMAKE_ANDROID_NDK=$ANDROID_NDK -DANDROID_TOOLCHAIN=clang
○ make -j4
```
# Build on OSX
## Preinstall
   - CMake    
   - Python >=3.5
 ## Building
    ○ cd ./build/OSX
    ○ cmake . -DCMAKE_BUILD_TYPE=Release
    ○ cmake --build . --config Release

# Build for iOS
## Preinstall
  - CMake

## Building
```
    ○ cd ./build/iOS
    ○ cmake -S ../../build/iOS -DCMAKE_BUILD_TYPE=Release -DiOS_ABI=arm64-v8a -DIOS_ARCH="arm64" -DENABLE_ARC=0 -DENABLE_BITCODE=0 -DENABLE_VISIBILITY=1  -DCMAKE_OSX_ARCHITECTURES=arm64 -DCMAKE_SYSTEM_PROCESSOR=arm64 -DCMAKE_TOOLCHAIN_FILE=[/path/to/GeniusTokens/thirdparty/build/iOS/iOS.cmake]
    ○ make - j8
```
