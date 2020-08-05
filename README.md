

This is the repository for third party of SuperGenius
===================================

# Build on Windows

## Preinstall
- CMake 
- Visual Studio 2015 or 2017
- Perl 
- Openssl
- Python >=3.5
## Building	
    ○ git pull
	○ git submodule update --init --recursive
	○ cd ./build
	○ mkdir Release
	○ cd Release
	○ cmake ../Windows -G "Visual Studio 15 2017 Win64"   -DCMAKE_USE_OPENSSL=ON     -DBOOST_ROOT="to_boost_install_path"   \  -DBOOST_INCLUDE_DIR="to_boost_install_path"     -DBOOST_LIBRARY_DIR="to_boost_install_path/lib64-msvc-14.1"   \ -DOPENSSL_ROOT_DIR="C:/Program Files/OpenSSL-Win64" -DCMAKE_BUILD_TYPE=Release
	○ cmake --build . --config Release
### Building for debugging
	○ git pull
	○ git submodule update --init --recursive
	○ cd ./build
	○ mkdir Debug
	○ cd Debug
	○ cmake ../Windows -G "Visual Studio 15 2017 Win64"   -DCMAKE_USE_OPENSSL=ON     -DBOOST_ROOT="to_boost_install_path"   \  -DBOOST_INCLUDE_DIR="to_boost_install_path"     -DBOOST_LIBRARY_DIR="to_boost_install_path/lib64-msvc-14.1"   \ -DOPENSSL_ROOT_DIR="C:/Program Files/OpenSSL-Win64" -DCMAKE_BUILD_TYPE=Debug
	○ cmake --build . --config Debug
# Build on Linux
## Preinstall
- CMake 
- Openssl
- Python >=3.5
## Building
	○ cd ./build/Linux
	○ cmake . -DOPENSSL_ROOT_DIR=/usr/include/openssl -DCMAKE_BUILD_TYPE=Release -DBOOST_DIR=/to_boost_install_root_path()
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



