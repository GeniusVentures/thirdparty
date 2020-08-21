

This is the repository for third party of SuperGenius
===================================

# Build on Windows

## Preinstall
- CMake 
- Visual Studio 2015 or 2017
- Perl 
- Openssl   Click the link to visit OpenSSL download page: [here](http://slproweb.com/products/Win32OpenSSL.html)
- Python >=3.5
## Building	
    ○ git pull
	○ git submodule update --init --recursive
	○ cd ./build
	○ mkdir Release
	○ cd Release
	○ cmake ../Windows -G "Visual Studio 15 2017 Win64"  -DCMAKE_BUILD_TYPE=Release
	○ cmake --build . --config Release
### Building for debugging
	○ git pull
	○ git submodule update --init --recursive
	○ cd ./build
	○ mkdir Debug
	○ cd Debug
	○ cmake ../Windows -G "Visual Studio 15 2017 Win64"  -DCMAKE_BUILD_TYPE=Debug -DOPENSSL_ROOT_DIR=/to_prebuilt_openssl_root_dir 
	○ cmake --build . --config Debug
# Build on Linux
## Preinstall
- CMake 
- Python >=3.5
## Building
	○ cd ./build/Linux	
	○ ../../sr25519/scripts/install_dependencies.sh
	○ export PATH=$PATH:$(pwd)/grpc/src/grpc-build:~/.cargo/bin
	○ cmake . -DCMAKE_BUILD_TYPE=Release
	○ make
# Build on Android
## Preinstall
- CMake 
- Openssl(For Android)
- Boost (For Android NDK)
- protoc and grpc_cpp_plugin (They should be prebuilt on host system)

## Building
		○ export ANDROID_NDK=/to_android_ndk_path
		○ export NDK_ROOT=$ANDROID_NDK
		○ export CROSS_COMPILER=$PATH:$ANDROID_NDK/prebuilt/linux-x86_64/bin/
		○ cmake . -DOPENSSL_ROOT_DIR=/to_prebuilt_openssl_root_dir  -DCMAKE_SYSTEM_NAME="Android" -DBoost_ADDITIONAL_VERSIONS="1.72" -DCMAKETOOLCHAIN_FILE=$ANDROID_NDK/build/cmake/android.toolchain.cmake -DANDROID_ABI="armeabi-v7a(or arm64-v8a,x86,x86_64)" -DANDROID_NATIVE_API_LEVEL=26 -DANDROID_TOOLCHAIN=clang  -DBOOST_DIR=/to_boost_forNDK_dir/libs/arm64-v8a(or arm64-v8a,x86,x86_64)/cmake/Boost-1.72.0 -DBOOST_ROOT=/to_boost_forNDK_dir -DCMAKE_BUILD_TYPE=Release
		○ make
   
# Build on OSX
## Preinstall
   - CMake    
   - Python >=3.5    
 ## Building
       ○ cd ./build/OSX
	   ○ ../../sr25519/scripts/install_dependencies.sh 
	   ○ export PATH=$PATH:$(pwd)/grpc/src/grpc-build:$(pwd)/protobuf/bin:~/.cargo/bin
       ○ cmake . -DCMAKE_BUILD_TYPE=Release
       ○ cmake --build . --config Release

# Build for iOS
## Preinstall
  - CMake
  - Openssl(build for iOS platform)
  - Boost (build with boost-for-mobile)

## Building
   ○ cd ./build/iOS
   ○ cmake .  -DCMAKE_SYSTEM_NAME=iOS -DBOOST_ROOT="/to_boost_root_path"   -DBoost_DIR="/to_thirdparty_path/boost-for-mobile/target/outputs/boost/1.72.0/ios/lib/release/arm64-v8a/cmake/Boost-1.72.0"  -DCMAKE_BUILD_TYPE=Release -DOPENSSL_ROOT_DIR=/to_openssl_path  -DiOS_ABI=arm64-v8a   -DCMAKE_TOOLCHAIN_FILE=/to_thirdparty_path/build/iOS/iOS.cmake -DIOS_PLATFORM=OS64 -DIOS_ARCH="arm64" -DENABLE_ARC=0 -DENABLE_BITCODE=0 -DENABLE_VISIBILITY=1  -DCMAKE_OSX_ARCHITECTURES=arm64 -DCMAKE_SYSTEM_PROCESSOR=arm64

