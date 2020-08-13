

To build this make sure you have Android NDK > 12 installed and

```
    ○ export ANDROID_NDK=/android_home_path_to/android-ndk-r21b
    ○ export NDK_ROOT=$ANDROID_NDK
```
export CROSS_COMPILER=$PATH;$ANDROID_NDK/prebuilt/linux-x86_64/bin/

```
cmake -DCMAKE_SYSTEM_NAME="Android" -DCMAKETOOLCHAIN_FILE=$ANDROID_NDK/build/cmake/android.toolchain.cmake -DANDROID_ABI="armeabi-v7a,arm64-v8a,x86,x86_64" -DANDROID_NATIVE_API_LEVE=12 .
cmake . -DOPENSSL_INCLUDE_DIR=/path_ssl_include_to  -DCMAKE_SYSTEM_NAME="Android" -DBoost_NO_SYSTEM_PATHS=TRUE -DBoost_ADDITIONAL_VERSIONS="1.72" -DCMAKETOOLCHAIN_FILE=$ANDROID_NDK/build/cmake/android.toolchain.cmake -DANDROID_ABI="armeabi-v7a,arm64-v8a,x86,x86_64" -DANDROID_NATIVE_API_LEVEL=23 -DANDROID_TOOLCHAIN=clang  -DBOOST_ROOT=/path_boost_for_ndk_to -DBOOST_INCLUDE_DIR=/path_boost_for_ndk_to/include  -DBOOST_LIBRARY_DIR=/path_boost_for_ndk_to/libs
```

Then you can use

```
make
```

to make the libraries