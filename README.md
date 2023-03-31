This is the repository for third party of SuperGenius
===================================

# CI/CD Status
|                                                                                                                                                                                                                 |    |    |
|:----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|:---|:---|
| [![WIndows Master](https://github.com/GeniusVentures/thirdparty/actions/workflows/Windows-cmake.yml/badge.svg?branch=master)](https://github.com/GeniusVentures/thirdparty/actions/workflows/Windows-cmake.yml) | [![OSX Master](https://github.com/GeniusVentures/thirdparty/actions/workflows/OSX-cmake.yml/badge.svg?branch=master)](https://github.com/GeniusVentures/thirdparty/actions/workflows/OSX-cmake.yml) | [![Linux Master](https://github.com/GeniusVentures/thirdparty/actions/workflows/Linux-cmake.yml/badge.svg?branch=master)](https://github.com/GeniusVentures/thirdparty/actions/workflows/Linux-cmake.yml)       |
| [![iOS Master](https://github.com/GeniusVentures/thirdparty/actions/workflows/iOS-cmake.yml/badge.svg?branch=master)](https://github.com/GeniusVentures/thirdparty/actions/workflows/iOS-cmake.yml)             | [![Android Master](https://github.com/GeniusVentures/thirdparty/actions/workflows/Android-cmake.yml/badge.svg?branch=master)](https://github.com/GeniusVentures/thirdparty/actions/workflows/Android-cmake.yml) ||


### Speeding up the build tools
Set two environment variables
- CMAKE_BUILD_PARALLEL_LEVEL=8
- MAKEFLAGS="-j8"

# Build on Windows

## Preinstall
- CMake
- Visual Studio 2015, 2017, 2019 or 2022
- Strawberry Perl (https://strawberryperl.com/)
- Python >=3.5
## Building
    ○ git submodule update --init --recursive
    ○ cd ./build/Windows
    ○ mkdir Release
    ○ cd Release
    ○ cmake ../Windows -G "Visual Studio 17 2022" -A x64 -DCMAKE_BUILD_TYPE=Release
    ○ cmake --build . --config Release
### Building for debugging
	○ git pull
	○ git submodule update --init --recursive
	○ cd ./build/Windows
	○ mkdir Debug
	○ cd Debug
	○ cmake ../Windows -G "Visual Studio 17 2022" -A x64 -DCMAKE_BUILD_TYPE=Debug
	○ cmake --build . --config Debug
# Build on Linux
## Preinstall
- CMake
- Python >=3.5 (make sure /bin/python links to your python3 version, e.g. `ln -s /bin/python3.8 /bin/python`)
- clang
## Building
	○ cd ./build/Linux
	○ mkdir Release
	○ cd Release
	○ cmake .. -DCMAKE_BUILD_TYPE=Release
	○ make
# Build on Linux for Android cross compile
## Preinstall
- CMake
- Android NDK Latest LTS Version (r25b) [(link)](https://developer.android.com/ndk/downloads#lts-downloads)
## Building
	○ export ANDROID_NDK=/path/to/android-ndk-r25b
	○ export ANDROID_TOOLCHAIN="$ANDROID_NDK/toolchains/llvm/prebuilt/linux-x86_64/bin"
	○ export PATH="$ANDROID_TOOLCHAIN":"$PATH"
* armeabi-v7a
```
○ cd build/Android
○ mkdir -p Release/armeabi-v7a
○ cd Release/armeabi-v7a
○ cmake ../../ -DANDROID_ABI="armeabi-v7a" -DCMAKE_ANDROID_NDK=$ANDROID_NDK -DANDROID_TOOLCHAIN=clang
○ make
```
* arm64-v8a
```
○ cd build/Android
○ mkdir -p Release/arm64-v8a
○ cd Release/arm64-v8a
○ cmake ../../ -DANDROID_ABI="arm64-v8a" -DCMAKE_ANDROID_NDK=$ANDROID_NDK -DANDROID_TOOLCHAIN=clang
○ make
```
* x86
```
○ cd build/Android
○ mkdir -p Release/x86
○ cd Release/x86
○ cmake ../../ -DANDROID_ABI="x86" -DCMAKE_ANDROID_NDK=$ANDROID_NDK -DANDROID_TOOLCHAIN=clang
○ make
```
* x86_64
```
○ cd build/Android
○ mkdir -p Release/x86_64
○ cd Release/x86_64
○ cmake ../../ -DANDROID_ABI="x86_64" -DCMAKE_ANDROID_NDK=$ANDROID_NDK -DANDROID_TOOLCHAIN=clang
○ make
```
# Build on OSX (Builds x86_64 & Arm64)
## Preinstall
   - CMake    
   - Python >=3.5
   - xCode Command line Tools & SDK

 ## Building
```
○ cd build/OSX
○ mkdir Release
○ cd Release
○ cmake .. -DCMAKE_BUILD_TYPE=Release
○ make
```
# Build for iOS
## Preinstall
  - CMake
  - xCode Command line Tools & SDK 

## Building
```
○ cd build/iOS
○ mkdir Release/
○ cmake ../../ -DCMAKE_BUILD_TYPE=Release -DiOS_ABI=arm64-v8a -DIOS_ARCH="arm64" -DENABLE_ARC=0 -DENABLE_BITCODE=0 -DENABLE_VISIBILITY=1  -DCMAKE_OSX_ARCHITECTURES=arm64 -DCMAKE_SYSTEM_PROCESSOR=arm64 -DCMAKE_TOOLCHAIN_FILE=../iOS.cmake
○ make
```
