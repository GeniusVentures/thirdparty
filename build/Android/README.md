

To build this make sure you have Android NDK > 12 installed and

```
export ANDROD_NDK=$ANDROID_HOME/ndk/21.1.6352462
```

make sure you path aslo includes the Android build tools directory

```
cmake -DCMAKE_SYSTEM_NAME="Android" -DCMAKETOOLCHAIN_FILE=$ANDROID_NDK/build/cmake/android.toolchain.cmake -DANDROID_ABI="armeabi-v7a,arm64-v8a,x86,x86_64" -DANDROID_NATIVE_API_LEVE=12 .
```

Then you can use

```
make
```

to make the libraries