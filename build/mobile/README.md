# Mobile Thirdparty Library Build Guide

Build the render-specific thirdparty libraries (vk-bootstrap, SPIRV-Tools, shaderc, and Vulkan headers)
for Android (arm64-v8a, armeabi-v7a) and iOS (arm64 device).

## Prerequisites

### Both Platforms
- **Git** — submodules must be initialized:
  ```bash
  git submodule update --init --recursive
  ```
- **CMake** ≥ 3.22
- **Python** 3.7+ (required by shaderc's bundled glslang for code generation)
- **Ninja** (optional but recommended for faster builds)

### Android
- **Android NDK** r26 or later
  - Set `ANDROID_NDK_HOME` environment variable, or pass `-DCMAKE_ANDROID_NDK=/path/to/ndk` to CMake

### iOS
- **Xcode** 15+ with command-line tools
- **macOS** build host (iOS cross-compilation requires Apple toolchain)

---

## Android Build Commands

### arm64-v8a

```bash
mkdir -p thirdparty/build/Android/Debug
cd thirdparty/build/Android/Debug
cmake .. -G "Ninja" \
  -DCMAKE_BUILD_TYPE=Debug \
  -DCMAKE_ANDROID_NDK=/path/to/ndk \
  -DANDROID_ABI=arm64-v8a
cmake --build . --parallel 8
```

### armeabi-v7a

```bash
mkdir -p thirdparty/build/Android/Debug
cd thirdparty/build/Android/Debug
cmake .. -G "Ninja" \
  -DCMAKE_BUILD_TYPE=Debug \
  -DCMAKE_ANDROID_NDK=/path/to/ndk \
  -DANDROID_ABI=armeabi-v7a
cmake --build . --parallel 8
```

Replace `/path/to/ndk` with your actual NDK path (e.g. `$ANDROID_NDK_HOME` or
`~/Android/Sdk/ndk/26.3.11579264`). Adjust `--parallel` based on available CPU cores.

The NDK toolchain propagates `ANDROID_STL=c++_static`, `ANDROID_NATIVE_API_LEVEL=28`, and
`CMAKE_FIND_ROOT_PATH` automatically via `_CMAKE_COMMON_CACHE_ARGS` set in
`thirdparty/build/Android/CMakeLists.txt`.

---

## iOS Build Commands

### arm64 Device

```bash
mkdir -p thirdparty/build/iOS/Debug
cd thirdparty/build/iOS/Debug
cmake .. -G "Xcode" \
  -DCMAKE_BUILD_TYPE=Debug \
  -DCMAKE_TOOLCHAIN_FILE=../apple.toolchain.cmake \
  -DPLATFORM=OS64 \
  -DDEPLOYMENT_TARGET=15
cmake --build . --config Debug --parallel 8
```

To use Ninja instead of Xcode generator:
```bash
cmake .. -G "Ninja" \
  -DCMAKE_BUILD_TYPE=Debug \
  -DCMAKE_TOOLCHAIN_FILE=../apple.toolchain.cmake \
  -DPLATFORM=OS64 \
  -DDEPLOYMENT_TARGET=15
cmake --build . --parallel 8
```

The apple toolchain propagates `PLATFORM`, `DEPLOYMENT_TARGET`, and
`NAMED_LANGUAGE_SUPPORT`/`ENABLE_BITCODE`/`ENABLE_ARC`/`ENABLE_VISIBILITY`
automatically via `_CMAKE_COMMON_CACHE_ARGS` set in `thirdparty/build/iOS/CMakeLists.txt`.

Note: iOS builds must run on a macOS host with Xcode installed. Simulator architectures
are not supported — arm64 device only.

---

## Expected Build Outputs

After a successful build, the following static libraries are produced:

| Library | Android Path | iOS Path |
|---------|-------------|----------|
| vk-bootstrap | `thirdparty/build/Android/Debug/vk-bootstrap/lib/libvk-bootstrap.a` | `thirdparty/build/iOS/Debug/vk-bootstrap/lib/libvk-bootstrap.a` |
| SPIRV-Tools | `thirdparty/build/Android/Debug/SPIRV-Tools/lib/libSPIRV-Tools.a` | `thirdparty/build/iOS/Debug/SPIRV-Tools/lib/libSPIRV-Tools.a` |
| shaderc | `thirdparty/build/Android/Debug/shaderc/lib/libshaderc_combined.a` | `thirdparty/build/iOS/Debug/shaderc/lib/libshaderc_combined.a` |
| Vulkan Headers | `thirdparty/build/Android/Debug/Vulkan-Headers/share/cmake/VulkanHeaders/` | `thirdparty/build/iOS/Debug/Vulkan-Headers/share/cmake/VulkanHeaders/` |

Additional platform-specific outputs:

- **Android:** Vulkan loader is provided by the NDK as `libvulkan.so` — loaded at runtime
  on the device. No separate build step required.
- **iOS:** MoltenVK (Vulkan-over-Metal) is built separately by
  `thirdparty/build/iOS/CMakeLists.txt` and produces
  `thirdparty/build/iOS/Debug/moltenvk/build/lib/MoltenVK.xcframework`.

---

## Link Verification

After building the thirdparty libraries, verify the SGProcessingManager render path
resolves correctly for the target platform:

### Android

```bash
cd SuperGenius/build/Android
cmake .. \
  -DCMAKE_ANDROID_NDK=/path/to/ndk \
  -DANDROID_ABI=arm64-v8a \
  -D_THIRDPARTY_BUILD_DIR=../../thirdparty/build/Android/Debug
```

### iOS

```bash
cd SuperGenius/build/iOS
cmake .. \
  -DCMAKE_TOOLCHAIN_FILE=../apple.toolchain.cmake \
  -DPLATFORM=OS64 \
  -DDEPLOYMENT_TARGET=15 \
  -D_THIRDPARTY_BUILD_DIR=../../thirdparty/build/iOS/Debug
```

A successful CMake configure — with no `find_package` or `target_link_libraries` errors
for `shaderc::shaderc`, `SPIRV-Tools::SPIRV-Tools`, `Vulkan::Vulkan`, or
`vk-bootstrap::vk-bootstrap` — proves the link chain is intact.

Build logs should be captured as evidence per the phase verification requirements.

---

## Troubleshooting

### shaderc build fails with "Python not found"

**Cause:** shaderc's bundled glslang uses Python for code generation during the build.

**Fix:** Ensure Python 3.7+ is on `PATH`:
```bash
python3 --version
# If missing, install Python 3.7+ and add to PATH
```

### SPIRV-Tools build fails on Android with C++ standard library errors

**Cause:** `ANDROID_STL` not propagated correctly.

**Fix:** Verify `ANDROID_STL=c++_static` is in `_CMAKE_COMMON_CACHE_ARGS`
(automatically set by `thirdparty/build/Android/CMakeLists.txt`). If building
standalone, pass it explicitly:
```bash
cmake .. -DANDROID_STL=c++_static ...
```

### vk-bootstrap configure fails with "VulkanHeaders not found"

**Cause:** `_VK_BOOTSTRAP_VULKAN_HEADERS_DIR` resolution in
`thirdparty/build/CommonTargets.cmake` points to a path that doesn't exist.

**Fix:** Check that Vulkan-Headers built successfully:
- Android: `ls thirdparty/build/Android/Debug/Vulkan-Headers/share/cmake/VulkanHeaders/`
- iOS: `ls thirdparty/build/iOS/Debug/Vulkan-Headers/share/cmake/VulkanHeaders/`
- Desktop: `ls thirdparty/build/{Platform}/Debug/Vulkan-Loader/share/cmake/VulkanHeaders/`

### Build runs out of memory

**Cause:** shaderc's bundled glslang build is memory-intensive, especially with high
`--parallel` values.

**Fix:** Reduce parallelism:
```bash
cmake --build . --parallel 2
```
Or build incrementally (build shaderc first, then the rest):
```bash
cmake --build . --target shaderc --parallel 2
cmake --build . --parallel 8
```

### iOS build fails with "unknown platform"

**Cause:** The apple toolchain file or Xcode command-line tools not found.

**Fix:** Ensure Xcode and command-line tools are installed:
```bash
xcode-select --install
xcodebuild -version
```
