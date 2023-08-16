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
- MAKEFLAGS="-j8"  # this errors on Windows nmake, so don't use on Windows

# Build on Windows

## Preinstall
- CMake
- Visual Studio 2015, 2017, 2019 or 2022
- Strawberry Perl (https://strawberryperl.com/)
- Python >=3.5
- rvm/Ruby 2.7.8
  - ```rvm --default use ruby-2.7.8```
- wallet-core dependency tools
  - Rust, cargo
    - ```rustup set default-host x86_64-pc-windows-msvc```
    - ```rustup target add x86_64-pc-windows-msvc```
## Building
    ○ git submodule update --init --recursive
    ○ cd ./build/Windows
    ○ mkdir Release
    ○ cd Release
    ○ cmake .. -G "Visual Studio 17 2022" -A x64 -DCMAKE_BUILD_TYPE=Release
    ○ cmake --build . --config Release
### Building for debugging
	○ git pull
	○ git submodule update --init --recursive
	○ cd ./build/Windows
	○ mkdir Debug
	○ cd Debug
	○ cmake .. -G "Visual Studio 17 2022" -A x64 -DCMAKE_BUILD_TYPE=Debug
	○ cmake --build . --config Debug
# Build on Linux
## Preinstall
	
- Ubuntu 22.04 (or compatible) recommended

Open a terminal as root ("sudo" won't do it because of Ruby installation)

```bash
	apt-get -y update
	apt-get -y install g++ clang llvm cmake ntp zlib1g-dev libgtk-3-dev ninja-build libjsoncpp25 libsecret-1-0 libjsoncpp-dev libsecret-1-dev git cmake default-jre curl libc++-dev
	cd /usr/local/src
	wget --no-check-certificate https://www.openssl.org/source/openssl-1.1.1t.tar.gz 
	tar -xf openssl-1.1.1t.tar.gz 
	cd openssl-1.1.1t/
	./config --prefix=/usr/local/ssl --openssldir=/usr/local/ssl shared zlib >build.log 
	make install >>build.log
	cd ~/
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
	. "$HOME/.cargo/env" 
	cargo install cbindgen >rust-install.log 
	rustup target add x86_64-unknown-linux-gnu >rust-install.log 
	cp -R /root/.cargo /home/your_user_here 
	cp -R /root/.rustup /home/your_user_here 
	chown -R your_user_here:your_user_here /home/your_user_here/.cargo /home/your_user_here/.rustup
	apt-get -y install gnupg2
	curl -sSL https://rvm.io/mpapis.asc | gpg2 --import -
	curl -sSL https://rvm.io/pkuczynski.asc | gpg2 --import -
	curl -sSL https://get.rvm.io | bash -s stable  >>ruby-build.log 
	source /etc/profile.d/rvm.sh
	rvm install ruby-2.7.8 --with-openssl-dir=/usr/local/ssl/ >>ruby-build.log
	rvm --default use ruby-2.7.8 
	ln -s /usr/bin/python3 /usr/bin/python
	update-alternatives --set c++ /usr/bin/clang++
	update-alternatives --set cc /usr/bin/clang
```
These steps were extracted from the bootstrap.sh script on TestVMS [**(here)**](../../../TestVMs/blob/master/Ubuntu64Desktop/bootstrap.sh)

## Building

	○ export CMAKE_BUILD_PARALLEL_LEVEL=8
	○ export MAKEFLAGS="-j8"
	○ cd ./build/Linux
	○ mkdir Release
	○ cd Release
	○ cmake .. -DCMAKE_BUILD_TYPE=Release
	○ make

# Build/Cross-Compile Android on Linux/OSX/Windows Hosts 
## Preinstall Host tools
- CMake
- Android NDK Latest LTS Version (r25b) [(link)](https://developer.android.com/ndk/downloads#lts-downloads)
- rvm/Ruby 2.7.8
  - ```rvm --default use ruby-2.7.8``` 
- wallet-core dependency tools
  - Rust, cargo
    - ```rustup target add aarch64-linux-android armv7-linux-androideabi x86_64-linux-android i686-linux-android```
## Host settings in .bash_profile (ex.)
	○ export ANDROID_NDK=/path/to/android-ndk-r25b
	○ export ANDROID_TOOLCHAIN="$ANDROID_NDK/toolchains/llvm/prebuilt/linux-x86_64/bin"
	○ export PATH="$ANDROID_TOOLCHAIN":"$PATH"
# Building
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
- rvm/Ruby 2.7.8
  - ```rvm --default use ruby-2.7.8```
- wallet-core dependency tools
  - Rust, cargo
    - ```rustup target add aarch64-apple-darwin x86_64-apple-darwin```
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
- rvm/Ruby 2.7.8
- wallet-core dependency tools
  - Rust, cargo
    - ```rustup target add x86_64-apple-ios aarch64-apple-ios-sim aarch64-apple-ios```
## Building
```
○ cd build/iOS
○ mkdir Release/
○ cmake .. -DCMAKE_BUILD_TYPE=Release -DiOS_ABI=arm64-v8a -DIOS_ARCH="arm64" -DENABLE_ARC=0 -DENABLE_BITCODE=0 -DENABLE_VISIBILITY=1  -DCMAKE_OSX_ARCHITECTURES=arm64 -DCMAKE_SYSTEM_PROCESSOR=arm64 -DCMAKE_TOOLCHAIN_FILE=$PWD/../iOS.cmake
○ make
```
