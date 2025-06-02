cmake_minimum_required(VERSION 3.22)

set(ANDROID_PLATFORM_LEVEL 28)
set(ANDROID_NATIVE_API_LEVEL ${ANDROID_PLATFORM_LEVEL})
set(ANDROID_PLATFORM ${ANDROID_PLATFORM_LEVEL})

if(NOT ANDROID_ABI)
    message(WARNING "ANDROID_ABI not provided. Setting to `arm64-v8a`.")
    set(ANDROID_ABI arm64-v8a)
endif()

set(WALLET_CORE_ARCH_ABI ${ANDROID_ABI})

if(NOT CMAKE_ANDROID_NDK)
    if(DEFINED ENV{ANDROID_NDK_HOME})
        set(CMAKE_ANDROID_NDK $ENV{ANDROID_NDK_HOME})
    else()
        message(FATAL_ERROR "Cannot find Android NDK, make sure you pass -DCMAKE_ANDROID_NDK=[path_to_NDK].")
    endif()
endif()

set(ANDROID_USE_LEGACY_TOOLCHAIN_FILE OFF CACHE BOOL "Disabling legacy toolchain behavior")

set(CMAKE_TOOLCHAIN_FILE "${CMAKE_ANDROID_NDK}/build/cmake/android.toolchain.cmake")

project(ANDROID_SHARED_THIRD_PARTY LANGUAGES C CXX)

include(../CommonCompilerOptions.CMake)

# Config param for android
set(_CMAKE_COMMON_CACHE_ARGS ${_CMAKE_COMMON_CACHE_ARGS}
    -DCMAKE_ANDROID_NDK:PATH=${CMAKE_ANDROID_NDK}
    -DANDROID_ABI:STRING=${ANDROID_ABI}
    -DANDROID_NATIVE_API_LEVEL:STRING=${ANDROID_NATIVE_API_LEVEL}
    -DANDROID_PLATFORM_LEVEL:STRING=${ANDROID_PLATFORM_LEVEL}
    -DANDROID_PLATFORM:STRING=${ANDROID_PLATFORM}
    -DANDROID_STL:STRING=c++_static
    -DANDROID_TOOLCHAIN:STRING=${ANDROID_TOOLCHAIN}
    -DANDROID_USE_LEGACY_TOOLCHAIN_FILE:BOOL=${ANDROID_USE_LEGACY_TOOLCHAIN_FILE}
    -DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE:STRING=BOTH
    -DCMAKE_FIND_ROOT_PATH_MODE_PACKAGE:STRING=BOTH
    -DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY:STRING=BOTH
    -DOPENSSL_USE_STATIC_LIBS:BOOL=TRUE
)

# Boost
set(BOOST_ROOT "${CMAKE_CURRENT_BINARY_DIR}/boost/build/${CMAKE_SYSTEM_NAME}")
ExternalProject_Add(Boost
    PREFIX boost
    SOURCE_DIR "${THIRDPARTY_DIR}/boost"
    INSTALL_DIR ${BOOST_ROOT}

    CONFIGURE_COMMAND ""
    PATCH_COMMAND ""
    BUILD_COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/Boost-for-Android/build-android.sh ${CMAKE_ANDROID_NDK} --src-dir="${THIRDPARTY_DIR}/boost" --boost="${BOOST_VERSION}" --arch="${ANDROID_ABI}" --target-version="${ANDROID_PLATFORM_LEVEL}" --prefix="${BOOST_ROOT}" --with-libraries="${BOOST_INCLUDE_LIBRARIES_COMMA_SEPARATED}" --extra="--build-type=minimal,visibility=global,cxxstd=${CMAKE_CXX_STANDARD},-d0"
    INSTALL_COMMAND ""
    UPDATE_COMMAND ""
#   TODO: fix this so that ninja parallel build will work
#     BUILD_BYPRODUCTS
#        "${BOOST_ROOT}/lib/libboost_container.a"
#        "${BOOST_ROOT}/lib/libboost_program_options.a"
#        "${BOOST_ROOT}/lib/libboost_random.a"
#        "${BOOST_ROOT}/lib/libboost_regex.a"
#        "${BOOST_ROOT}/lib/libboost_system.a"
#        "${BOOST_ROOT}/lib/libboost_prg_exec_monitor.a"
#        "${BOOST_ROOT}/lib/libboost_test_exec_monitor.a"
#        "${BOOST_ROOT}/lib/libboost_unit_test_framework.a"
#        "${BOOST_ROOT}/lib/libboost_timer.a"
#        "${BOOST_ROOT}/lib/libboost_date_time.a"
#        "${BOOST_ROOT}/lib/libboost_atomic.a"
#        "${BOOST_ROOT}/lib/libboost_filesystem.a"
#        "${BOOST_ROOT}/lib/libboost_json.a"
#        "${BOOST_ROOT}/lib/libboost_thread.a"
#        "${BOOST_ROOT}/lib/libboost_chrono.a"
#        "${BOOST_ROOT}/lib/libboost_log.a"
#        "${BOOST_ROOT}/lib/libboost_log_setup.a"
)

set(Boost_DIR "${BOOST_ROOT}/lib/cmake/Boost-${BOOST_VERSION}")
set(Boost_INCLUDE_DIR "${BOOST_ROOT}/include/boost-${BOOST_VERSION_2U}")
set(boost_headers_DIR "${BOOST_ROOT}/lib/cmake/boost_headers-${BOOST_VERSION}")
set(boost_thread_DIR "${BOOST_ROOT}/lib/cmake/boost_thread-${BOOST_VERSION}")
set(boost_program_options_DIR "${BOOST_ROOT}/lib/cmake/boost_program_options-${BOOST_VERSION}")
set(boost_system_DIR "${BOOST_ROOT}/lib/cmake/boost_system-${BOOST_VERSION}")
set(boost_date_time_DIR "${BOOST_ROOT}/lib/cmake/boost_date_time-${BOOST_VERSION}")
set(boost_regex_DIR "${BOOST_ROOT}/lib/cmake/boost_regex-${BOOST_VERSION}")
set(boost_chrono_DIR "${BOOST_ROOT}/lib/cmake/boost_chrono-${BOOST_VERSION}")
set(boost_atomic_DIR "${BOOST_ROOT}/lib/cmake/boost_atomic-${BOOST_VERSION}")
set(boost_random_DIR "${BOOST_ROOT}/lib/cmake/boost_random-${BOOST_VERSION}")
set(boost_filesystem_DIR "${BOOST_ROOT}/lib/cmake/boost_filesystem-${BOOST_VERSION}")
set(boost_log_DIR "${BOOST_ROOT}/lib/cmake/boost_log-${BOOST_VERSION}")
set(boost_log_setup_DIR "${BOOST_ROOT}/lib/cmake/boost_log_setup-${BOOST_VERSION}")
set(boost_container_DIR "${BOOST_ROOT}/lib/cmake/boost_container-${BOOST_VERSION}")
set(boost_unit_test_framework_DIR "${BOOST_ROOT}/lib/cmake/boost_unit_test_framework-${BOOST_VERSION}")

set(_BOOST_CACHE_ARGS
    -DBOOST_ROOT:PATH=${BOOST_ROOT}
    -DBoost_DIR:PATH=${Boost_DIR}
    -DBoost_USE_MULTITHREADED:BOOL=ON
    -DBoost_USE_STATIC_LIBS:BOOL=ON
    -DBoost_USE_STATIC_RUNTIME:BOOL=ON
    -DBoost_NO_SYSTEM_PATHS:BOOL=ON
    -DBoost_INCLUDE_DIR:PATH=${Boost_INCLUDE_DIR}
    -Dboost_headers_DIR:PATH=${boost_headers_DIR}
    -Dboost_atomic_DIR:PATH=${boost_atomic_DIR}
    -Dboost_chrono_DIR:PATH=${boost_chrono_DIR}
    -Dboost_container_DIR:PATH=${boost_container_DIR}
    -Dboost_date_time_DIR:PATH=${boost_date_time_DIR}
    -Dboost_filesystem_DIR:PATH=${boost_filesystem_DIR}
    -Dboost_log_DIR:PATH=${boost_log_DIR}
    -Dboost_log_setup_DIR:PATH=${boost_log_setup_DIR}
    -Dboost_program_options_DIR:PATH=${boost_program_options_DIR}
    -Dboost_random_DIR:PATH=${boost_random_DIR}
    -Dboost_regex_DIR:PATH=${boost_regex_DIR}
    -Dboost_system_DIR:PATH=${boost_system_DIR}
    -Dboost_thread_DIR:PATH=${boost_thread_DIR}
    -Dboost_unit_test_framework_DIR:PATH=${boost_unit_test_framework_DIR}
    -DBoost_COMPILER:STRING=clang
)

# OpenSSL
if(ANDROID_ABI STREQUAL "arm64-v8a")
    set(OPENSSL_ABI android-arm64)
elseif(ANDROID_ABI STREQUAL "armeabi-v7a")
    set(OPENSSL_ABI android-arm)
elseif(ANDROID_ABI STREQUAL "x86")
    set(OPENSSL_ABI android-x86)
elseif(ANDROID_ABI STREQUAL "x86_64")
    set(OPENSSL_ABI android-x86_64)
endif()

set(OPENSSL_VARIANT $<$<CONFIG:Debug>:--debug>)

set(OPENSSL_ROOT_DIR "${CMAKE_CURRENT_BINARY_DIR}/openssl/build")

ExternalProject_Add(openssl
    PREFIX openssl
    SOURCE_DIR "${THIRDPARTY_DIR}/openssl"
    CONFIGURE_COMMAND ""
    BUILD_COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/Openssl-build/build.sh ${OPENSSL_VARIANT} --abi=${OPENSSL_ABI} --api-level=${ANDROID_NATIVE_API_LEVEL} --build-dir=${OPENSSL_ROOT_DIR} --env_path=$ENV{PATH} --env_android_ndk=${CMAKE_ANDROID_NDK} --env_android_toolchain=${ANDROID_TOOLCHAIN_ROOT}/bin
    BUILD_IN_SOURCE FALSE
    INSTALL_COMMAND make install_dev
    BUILD_BYPRODUCTS
        ${OPENSSL_ROOT_DIR}/lib/libssl.a
        ${OPENSSL_ROOT_DIR}/lib/libcrypto.a
)

set(OPENSSL_INCLUDE_DIR ${OPENSSL_ROOT_DIR}/include)
set(_OPENSSL_CACHE_ARGS
    -DOPENSSL_USE_STATIC_LIBS:BOOL=ON
    -DOPENSSL_ROOT_DIR:PATH=${OPENSSL_ROOT_DIR}
    -DOpenSSL_DIR:PATH=${OPENSSL_ROOT_DIR}/lib/cmake/OpenSSL
)

# rocksdb
set(_rocksdb_EXTRA_PARAM
    -DROCKSDB_LITE:BOOL=ON
)

# ed25519 crypto
set(_ED25519_RANDOM dev_urandom)

# MNN
set(_MNN_EXTRA_PARAM
    -DMNN_BUILD_FOR_ANDROID_COMMAND:BOOL=ON
)

set(_ZKLLVM_EXTRA_PARAM
    -DZKLLVM_BUILD_TRANSPILER_LIB:BOOL=OFF
    -DZKLLVM_BUILD_EXAMPLES:BOOL=OFF
    -DZKLLVM_BUILD_STD_LIB:BOOL=OFF
    -DZKLLVM_BUILD_EXECUTABLES:BOOL=OFF
)
include(../CommonTargets.CMake)
