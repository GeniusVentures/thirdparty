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
- `clang` or `MSVC` as a compiler

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

```bash
cd build/Linux
cmake -B Debug -CMAKE_BUILD_TYPE=Debug
cmake --build Debug --config Debug -j
```

Some CMake projects rely on having `CMAKE_BUILD_TYPE` set, so even if you're using a multi-config generator like Visual Studio, it is important to set it accordingly.

Another example, for Windows using release mode:

```bash
cd build/Windows
cmake -B Release -CMAKE_BUILD_TYPE=Release
cmake --build Release --config Release -j
```

When building for Android, we expect each ABI to have its own subdirectory.

```bash
cd build/Android
mkdir Debug && cd Debug
cmake -S .. -B arm64-v8a -CMAKE_BUILD_TYPE=Debug -DANDROID_ABI=arm64-v8a
cmake --build arm64-v8a --config Debug -j
```

When building for Apple platforms, you'll need to configure the project with the `PLATFORM` variable set to one of these values:

- `OS64` for iOS
- `MAC` for macOS **x86**
- `MAC_ARM64` for macOS **arm64**

Example for macOS x86:

```bash
cd build/OSX
cmake -B Release -CMAKE_BUILD_TYPE=Release -DPLATFORM=MAC
cmake --build Release --config Release -j
```
