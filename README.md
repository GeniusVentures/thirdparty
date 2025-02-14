This is the repository for third party of [SuperGenius](https://github.com/GeniusVentures/SuperGenius/).

![Android](https://github.com/GeniusVentures/thirdparty/actions/workflows/Android.yml/badge.svg?branch=master)
![iOS](https://github.com/GeniusVentures/thirdparty/actions/workflows/iOS.yml/badge.svg?branch=master)
![Linux](https://github.com/GeniusVentures/thirdparty/actions/workflows/Linux.yml/badge.svg?branch=master)
![macOS](https://github.com/GeniusVentures/thirdparty/actions/workflows/macOS.yml/badge.svg?branch=master)
![Windows](https://github.com/GeniusVentures/thirdparty/actions/workflows/Windows.yml/badge.svg?branch=master)

===================================

# Download pre-built libraries

Pre-built libraries are available on the [release page](https://github.com/GeniusVentures/thirdparty/releases). The tags are named with the following convention:

`${PLATFORM}-${BRANCH}-${BUILD_TYPE}`

Where:

- `PLATFORM` is Android, iOS, Linux, OSX or Windows
- `BUILD_TYPE` is either Debug or Release

The `master` branch receives few merges, download from the `develop` branch to get the newest builds.

# Building

If you want to build `thirdparty` for yourself, you'll need to recursively checkout every submodule.

## Requirements

- CMake
- Perl
- `wallet-core` dependency tools
  - Ruby
  - Rust
    - `bindgen` (install with `cargo install cbindgen`)
    - WASM target (install with `rustup target add wasm32-unknown-emscripten`)
    - On Mac don't use homebrew to install rust, use the recommended install procedure on the official website
- `clang` or `MSVC` as a compiler
    - On Linux setting cc and c++ to clang might be needed (using `update-alternatives`)

## Optional (but recommended)
- Ninja

### Android

- NDK, preferably version 27b
  - Remember to set the environment variable `ANDROID_NDK_HOME` to point to the install path 
- Rust Android target
  - Installable with `rustup target add aarch64-linux-android`

Note: we do not test cross-compiling for Android using Windows.

### iOS

- Rust iOS target and toolchain

```bash
rustup toolchain install nightly-aarch64-apple-darwin
rustup component add rust-src --toolchain nightly-aarch64-apple-darwin
rustup target add aarch64-apple-ios
```

## CMake

In the `build` directory, there'll be a folder for every supported platform, and inside each there will be a `CMakeLists.txt` file. To build, you must configure CMake using this platform-specific subdirectory and build from there.

Our convention is to create a subdirectory inside `build/${PLATFORM}`, called either `Debug` or `Release`, depending on the `BUILD_TYPE`. So to build the debug version for Linux, you would:

It is recommended that you enter into the build directory, i.e. Debug or Release, etc for ninja to work properly

```bash
cd build/Linux/Debug
cmake .. -CMAKE_BUILD_TYPE=Debug 
cmake --build Debug --config Debug -j
```

## Ninja (recommended)

Ninja is able to use parallel builds far better than CMake and picks up on # processors automatically.
```bash
cd build/Linux/Debug
cmake .. -CMAKE_BUILD_TYPE=Debug -G "Ninja"
ninja
```

Some CMake projects rely on having `CMAKE_BUILD_TYPE` set, so even if you're using a multi-config generator like Visual Studio, it is important to set it accordingly.

Another example, for Windows using release mode:

```bash
cd build/Windows
cmake -B Release -G "Visual Studio 17 2022" -A x64 -CMAKE_BUILD_TYPE=Release
cmake --build Release --config Release -j
```

When building for Android, we expect each ABI to have its own subdirectory. You need to configure the ABI to be built. The ABIs supported are:

- `armeabi-v7a` for Android **x86**
- `arm64-v8a ` for Android **arm64**
- `x86_64` for Android **emulator**


Example for Android arm64:

```bash
cd build/Android
mkdir Debug && cd Debug
cmake -S .. -B arm64-v8a -CMAKE_BUILD_TYPE=Debug -DANDROID_ABI=arm64-v8a
cmake --build arm64-v8a --config Debug -j
```

Or when using Ninja

```bash
cd build/Android
mkdir -p Debug/arm64-v8a && cd Debug/arm64-v8a
cmake .. -CMAKE_BUILD_TYPE=Debug -DANDROID_ABI=arm64-v8a -G "Ninja"
ninja
```

When building for Apple platforms, you'll need to configure the project with the `PLATFORM` variable set to one of these values:

- `OS64` for iOS
- `MAC` for macOS **x86**
- `MAC_ARM64` for macOS **arm64**
- `MAC_UNIVERSAL` for macOS **arm64 + x86**, (Default for Mac/OSX)

Example for macOS x86:

```bash
cd build/OSX
cmake -B Release -CMAKE_BUILD_TYPE=Release -DPLATFORM=MAC
cmake --build Release --config Release -j
```
And when using Ninja

```bash
cd build/OSX
mkdir Release
cd Release
cmake .. -CMAKE_BUILD_TYPE=Release -G "Ninja" # default is MAC_UNIVERSAL
ninja
```
