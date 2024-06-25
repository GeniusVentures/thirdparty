cmake_minimum_required(VERSION 3.22)

if(NOT ${CMAKE_HOST_SYSTEM_NAME} MATCHES "Darwin")
    message(FATAL_ERROR "${CMAKE_HOST_SYSTEM_NAME} host system name does not match OSX Darwin for iOS cross compiling - Please select the correct folder for configuring project")
endif()

if(POLICY CMP0025)
    cmake_policy(SET CMP0025 NEW)
endif()

if(POLICY CMP0042)
    cmake_policy(SET CMP0042 NEW)
endif()

if(NOT DEFINED CMAKE_TOOLCHAIN_FILE)
    set(PLATFORM OS64 CACHE STRING "Toolchain platform parameter")
    set(CMAKE_TOOLCHAIN_FILE "${CMAKE_CURRENT_SOURCE_DIR}/../apple.toolchain.cmake" CACHE STRING "Toolchain file")
endif()

project(iOS_SHARED_THIRD_PARTY LANGUAGES C CXX)

include(../CommonCompilerOptions.CMake)

# OSX specific runtime options
set(_CMAKE_COMMON_CACHE_ARGS ${_CMAKE_COMMON_CACHE_ARGS}
    -DPLATFORM:STRING=${PLATFORM}
)

# Boost
set(BOOST_ROOT "${CMAKE_CURRENT_BINARY_DIR}/boost/build/${CMAKE_SYSTEM_NAME}/${iOS_ABI}")
ExternalProject_Add(Boost
    PREFIX boost
    SOURCE_DIR "${THIRDPARTY_DIR}/boost"
    INSTALL_DIR ${BOOST_ROOT}

    CONFIGURE_COMMAND <SOURCE_DIR>/bootstrap.sh --with-toolset=clang --with-libraries=${BOOST_INCLUDE_LIBRARIES_COMMA_SEPARATED} --prefix=${BOOST_ROOT}

    BUILD_COMMAND <SOURCE_DIR>/b2${CMAKE_EXECUTABLE_SUFFIX} ${BOOST_B2_FLAGS} cxxstd=${CMAKE_CXX_STANDARD} toolset=darwin target-os=iphone visibility=global runtime-link=static link=static threading=multi --build-type=minimal address-model=64 architecture=arm variant=${BOOST_VARIANT} --prefix=<INSTALL_DIR> install
    BUILD_IN_SOURCE TRUE

    INSTALL_COMMAND ""
)

set(Boost_DIR "${BOOST_ROOT}/lib/cmake/Boost-${BOOST_VERSION}")
set(Boost_INCLUDE_DIR "${BOOST_ROOT}/include")
set(boost_headers_DIR "${BOOST_ROOT}/lib/cmake/boost_headers-${BOOST_VERSION}")
set(boost_random_DIR "${BOOST_ROOT}/lib/cmake/boost_random-${BOOST_VERSION}")
set(boost_system_DIR "${BOOST_ROOT}/lib/cmake/boost_system-${BOOST_VERSION}")
set(boost_filesystem_DIR "${BOOST_ROOT}/lib/cmake/boost_filesystem-${BOOST_VERSION}")
set(boost_program_options_DIR "${BOOST_ROOT}/lib/cmake/boost_program_options-${BOOST_VERSION}")
set(boost_regex_DIR "${BOOST_ROOT}/lib/cmake/boost_regex-${BOOST_VERSION}")
set(boost_date_time_DIR "${BOOST_ROOT}/lib/cmake/boost_date_time-${BOOST_VERSION}")

set(_BOOST_CACHE_ARGS
    -DBOOST_ROOT:PATH=${BOOST_ROOT}
    -DBoost_DIR:PATH=${Boost_DIR}
    -DBoost_INCLUDE_DIR:PATH=${Boost_INCLUDE_DIR}
    -DBoost_NO_SYSTEM_PATHS:BOOL=ON
    -DBoost_USE_MULTITHREADED:BOOL=ON
    -DBoost_USE_STATIC_LIBS:BOOL=ON
    -DBoost_USE_STATIC_RUNTIME:BOOL=ON
    -Dboost_date_time_DIR:PATH=${boost_date_time_DIR}
    -Dboost_filesystem_DIR:PATH=${boost_filesystem_DIR}
    -Dboost_headers_DIR:PATH=${boost_headers_DIR}
    -Dboost_program_options_DIR:PATH=${boost_program_options_DIR}
    -Dboost_random_DIR:PATH=${boost_random_DIR}
    -Dboost_regex_DIR:PATH=${boost_regex_DIR}
    -Dboost_system_DIR:PATH=${boost_system_DIR}
)

# OpenSSL
set(OPENSSL_ROOT_DIR "${CMAKE_CURRENT_BINARY_DIR}/openssl/build/${CMAKE_SYSTEM_NAME}/${iOS_ABI}")

ExternalProject_Add(openssl
    PREFIX openssl
    SOURCE_DIR "${THIRDPARTY_DIR}/openssl"
    CONFIGURE_COMMAND ""
    BUILD_COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/Openssl-build/build-libssl.sh ${BOOST_BUILD_VARIANT} --version=1.1.1g --targets=ios64-cross-arm64 --src-dir=${THIRDPARTY_DIR}/openssl --build-dir=${OPENSSL_ROOT_DIR}
    INSTALL_COMMAND ""
    UPDATE_COMMAND ""
)

set(OPENSSL_INCLUDE_DIR ${OPENSSL_ROOT_DIR}/include)
set(_OPENSSL_CACHE_ARGS
    -DOPENSSL_USE_STATIC_LIBS:BOOL=ON
    -DOPENSSL_ROOT_DIR:PATH=${OPENSSL_ROOT_DIR}
    -DOPENSSL_INCLUDE_DIR:PATH=${OPENSSL_INCLUDE_DIR}
    -DOPENSSL_CRYPTO_LIBRARY:FILEPATH=${OPENSSL_ROOT_DIR}/lib/libcrypto${CMAKE_STATIC_LIBRARY_SUFFIX}
    -DOPENSSL_SSL_LIBRARY:FILEPATH=${OPENSSL_ROOT_DIR}/lib/libssl${CMAKE_STATIC_LIBRARY_SUFFIX}
)

# rocksdb
set(_rocksdb_EXTRA_PARAM
    -DROCKSDB_LITE:BOOL=ON
)

# ed25519 crypto
set(_ED25519_RANDOM dev_urandom)

# MNN
set(_MNN_EXTRA_PARAM
    -DMNN_METAL:BOOL=ON
    -DARCHS:STRING="arm64"
    -DENABLE_BITCODE:BOOL=OFF
    -DMNN_SEP_BUILD:BOOL=OFF
    -DMNN_USE_LOGCAT:BOOL=OFF
    -DMNN_USE_SSE:BOOL=OFF
    -DMNN_SUPPORT_BF16:BOOL=OFF
    -DMNN_BUILD_FOR_ANDROID_COMMAND:BOOL=ON
)

include(../CommonTargets.CMake)
