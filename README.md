

##Build Instructions for Android

###restclient-cpp
```
cd restclient-cpp
mkdir -p build/Android/x86
cd build/Android/x86
cmake -DCMAKE_SYSTEM_NAME="Android" -DCMAKE_ANDROID_ARCH_ABI=x86 -DCURL_LIBRARY="../../../../curl-android-ios/prebuilt-with-ssl/android/x86/libcurl.a" -DCURL_INCLUDE_DIR="../../../../curl-android-ios/prebuilt-with-ssl/android/include" -DCMAKE_LIBRARY_OUTPUT_DIRECTORY=../../../lib/Release/x86 -DCMAKE_BUILD_TYPE=Release ../../../
make
cmake -DCMAKE_SYSTEM_NAME="Android" -DCMAKE_ANDROID_ARCH_ABI=x86 -DCURL_LIBRARY="../../../../curl-android-ios/prebuilt-with-ssl/android/x86/libcurl.a" -DCURL_INCLUDE_DIR="../../../../curl-android-ios/prebuilt-with-ssl/android/include" -DCMAKE_LIBRARY_OUTPUT_DIRECTORY=../../../lib/Debug/x86 -DCMAKE_BUILD_TYPE=Debug ../../../
make
mv ../../../lib/Debug/x86/librestclient-cppd.so ../../../lib/Debug/x86/librestclient-cpp.so
mkdir -p build/Android/x86_64
cd build/Android/x86_64
cmake -DCMAKE_SYSTEM_NAME="Android" -DCMAKE_ANDROID_ARCH_ABI=x86_64 -DCURL_LIBRARY="../../../../curl-android-ios/prebuilt-with-ssl/android/x86_64/libcurl.a" -DCURL_INCLUDE_DIR="../../../../curl-android-ios/prebuilt-with-ssl/android/include" -DCMAKE_LIBRARY_OUTPUT_DIRECTORY=../../../lib/Release/x86_64 -DCMAKE_BUILD_TYPE=Release ../../../
make
cmake -DCMAKE_SYSTEM_NAME="Android" -DCMAKE_ANDROID_ARCH_ABI=x86_64 -DCURL_LIBRARY="../../../../curl-android-ios/prebuilt-with-ssl/android/x86_64/libcurl.a" -DCURL_INCLUDE_DIR="../../../../curl-android-ios/prebuilt-with-ssl/android/include" -DCMAKE_LIBRARY_OUTPUT_DIRECTORY=../../../lib/Debug/x86_64 -DCMAKE_BUILD_TYPE=Debug ../../../
make
mv ../../../lib/Debug/x86/librestclient-cppd.so ../../../lib/Debug/x86_64/librestclient-cpp.so

```

##Build Instructions for iOS


