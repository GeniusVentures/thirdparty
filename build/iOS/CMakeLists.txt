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
    set(PLATFORM OS64)
    set(CMAKE_TOOLCHAIN_FILE "${CMAKE_CURRENT_SOURCE_DIR}/../ios.toolchain.cmake" CACHE STRING "Toolchain file")
endif()

project(iOS_SHARED_THIRD_PARTY LANGUAGES C CXX)

include(../CommonCompilerOptions.CMake)

# OSX specific runtime options
set(_CMAKE_COMMON_CACHE_ARGS ${_CMAKE_COMMON_CACHE_ARGS}
    -DPLATFORM:STRING=${PLATFORM}
)

# Boost
set(BOOST_ROOT "${CMAKE_CURRENT_BINARY_DIR}/boost/build/${CMAKE_SYSTEM_NAME}/${iOS_ABI}")
set(BOOST_BUILD_VARIANT $<$<CONFIG:Debug>:--debug>)
ExternalProject_Add(Boost
    PREFIX boost
    SOURCE_DIR "${THIRDPARTY_DIR}/boost"

    PATCH_COMMAND <SOURCE_DIR>/bootstrap.sh --with-toolset=clang --with-libraries=${BOOST_INCLUDE_LIBRARIES_COMMA_SEPARATED} --prefix=${_BOOST_BUILD_ROOT}

    BUILD_COMMAND <SOURCE_DIR>/b2 headers && <SOURCE_DIR>/b2 ${BOOST_B2_FLAGS} cxxstd=${CMAKE_CXX_STANDARD} toolset=darwin target-os=iphone visibility=global runtime-link=static link=static threading=multi --build-type=minimal address-model=64 architecture=arm variant=${BOOST_VARIANT} --build-dir=${_BOOST_BUILD_ROOT} --libdir=${_BOOST_BUILD_ROOT}/lib install
    BUILD_IN_SOURCE TRUE

    INSTALL_COMMAND ""
)

set(boost_headers_DIR "${BOOST_ROOT}/lib/cmake/boost_headers-${BOOST_VERSION}")
set(boost_random_DIR "${BOOST_ROOT}/lib/cmake/boost_random-${BOOST_VERSION}")
set(boost_system_DIR "${BOOST_ROOT}/lib/cmake/boost_system-${BOOST_VERSION}")
set(boost_filesystem_DIR "${BOOST_ROOT}/lib/cmake/boost_filesystem-${BOOST_VERSION}")
set(boost_program_options_DIR "${BOOST_ROOT}/lib/cmake/boost_program_options-${BOOST_VERSION}")
set(boost_regex_DIR "${BOOST_ROOT}/lib/cmake/boost_regex-${BOOST_VERSION}")
set(boost_date_time_DIR "${BOOST_ROOT}/lib/cmake/boost_date_time-${BOOST_VERSION}")
set(boost_DIR "${BOOST_ROOT}/lib/cmake/Boost-${BOOST_VERSION}")
set(_Boost_INCLUDE_DIR "${BOOST_ROOT}/include")
set(FINDPACKAGE_BOOST_CONFIG_DIR ${boost_DIR})

set(_BOOST_CACHE_ARGS
    -DBoost_DIR:PATH=${boost_DIR}
    -DBOOST_ROOT:PATH=${BOOST_ROOT}
    -Dboost_headers_DIR:PATH=${boost_headers_DIR}
    -Dboost_random_DIR:PATH=${boost_random_DIR}
    -Dboost_system_DIR:PATH=${boost_system_DIR}
    -Dboost_filesystem_DIR:PATH=${boost_filesystem_DIR}
    -Dboost_program_options_DIR:PATH=${boost_program_options_DIR}
    -Dboost_regex_DIR:PATH=${boost_regex_DIR}
    -Dboost_date_time_DIR:PATH=${boost_date-time_DIR}
    -DBoost_USE_MULTITHREADED:BOOL=ON
    -DBoost_USE_STATIC_RUNTIME:BOOL=ON
    -DBoost_USE_STATIC_LIBS:BOOL=ON
    -DBoost_NO_SYSTEM_PATHS:BOOL=ON
    -DBoost_INCLUDE_DIR:PATH=${_Boost_INCLUDE_DIR}
)

# OpenSSL
set(_openssl_BUILD_ROOT "${CMAKE_CURRENT_BINARY_DIR}/openssl/build/${CMAKE_SYSTEM_NAME}/${iOS_ABI}")

ExternalProject_Add(openssl
    PREFIX openssl
    SOURCE_DIR "${THIRDPARTY_DIR}/openssl"
    CONFIGURE_COMMAND ""
    BUILD_COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/Openssl-build/build-libssl.sh ${BOOST_BUILD_VARIANT} --version=1.1.1g --targets=ios64-cross-arm64 --src-dir=${THIRDPARTY_DIR}/openssl --build-dir=${_openssl_BUILD_ROOT}
    INSTALL_COMMAND ""
    UPDATE_COMMAND ""
)

set(_OPENSSL_INCLUDE_DIR ${_openssl_BUILD_ROOT}/include)

set(_OPENSSL_CACHE_ARGS
    -DOPENSSL_USE_STATIC_LIBS:BOOL=ON
    -DOPENSSL_ROOT_DIR:STRING=${_openssl_BUILD_ROOT}
    -DOPENSSL_INCLUDE_DIR:PATH=${_OPENSSL_INCLUDE_DIR}
    -DOPENSSL_CRYPTO_LIBRARY:PATH=${_openssl_BUILD_ROOT}/lib/libcrypto${CMAKE_STATIC_LIBRARY_SUFFIX}
    -DOPENSSL_SSL_LIBRARY:PATH=${_openssl_BUILD_ROOT}/lib/libssl${CMAKE_STATIC_LIBRARY_SUFFIX}
)

# Protobuf
set(_PROTOBUF_CONFIG_DIR "${CMAKE_CURRENT_BINARY_DIR}/protobuf/lib/cmake/protobuf")
set(PROTOBUF_SRC_DIR "${THIRDPARTY_DIR}/grpc/third_party/protobuf/cmake")

ExternalProject_Add(protobuf
    PREFIX protobuf
    SOURCE_DIR "${PROTOBUF_SRC_DIR}"
    CMAKE_CACHE_ARGS
    -Dprotobuf_BUILD_TESTS:BOOL=OFF
    -Dprotobuf_WITH_ZLIB:BOOL=OFF
    -Dprotobuf_MSVC_STATIC_RUNTIME:BOOL=OFF
    -DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_CURRENT_BINARY_DIR}/protobuf
    -Dprotobuf_BUILD_PROTOC_BINARIES:BOOL=OFF
    ${_CMAKE_COMMON_CACHE_ARGS}
    DEPENDS
)

set(_PROTOBUF_INCLUDE_DIR "${CMAKE_CURRENT_BINARY_DIR}/protobuf/include")
set(_PROTOBUF_LIB_DIR "${CMAKE_CURRENT_BINARY_DIR}/protobuf/lib")
set(_PROTOBUF_HOST_DIR "${THIRDPARTY_DIR}/build/${TP_BUILD_SUBDIR}/${CMAKE_BUILD_TYPE}/protobuf")

# Build protoc for host OS
ExternalProject_Add(protobuf-host
    PREFIX ${_PROTOBUF_HOST_DIR}
    SOURCE_DIR "${PROTOBUF_SRC_DIR}"
    CMAKE_CACHE_ARGS
    -Dprotobuf_BUILD_TESTS:BOOL=OFF
    -Dprotobuf_WITH_ZLIB:BOOL=OFF
    -Dprotobuf_MSVC_STATIC_RUNTIME:BOOL=OFF
    -DCMAKE_INSTALL_PREFIX:PATH=${_PROTOBUF_HOST_DIR}
    -Dprotobuf_BUILD_PROTOC_BINARIES:BOOL=ON
    ${CMAKE_CHCHE_ARGS_CFLAGES_ADD}
    DEPENDS
)

set(PROTOC_EXECUTABLE "${_PROTOBUF_HOST_DIR}/bin/protoc")
set(_PROTOBUF_TARGET protobuf protobuf-host)
set(_PROTOBUF_HOST_CONFIG_DIR "${_PROTOBUF_HOST_DIR}/lib/cmake/protobuf")
set(_PROTOBUF_HOST_INCLUDE_DIR "${_PROTOBUF_HOST_DIR}/include")
set(_PROTOBUF_HOST_LIB_DIR "${_PROTOBUF_HOST_DIR}/lib")

# gRPC
set(_grpc_EXTRA_PARAM
    -DHAVE_LIBNSL:BOOL=FALSE
    -DHAVE_SOCKET_LIBSOCKET:BOOL=FALSE
    -DHAVE_GHBN_LIBSOCKET:BOOL=FALSE
    -DHAVE_LIBSOCKET:BOOL=FALSE
    -DHAVE_LIBRT:BOOL=FALSE
    -DCARES_BUILD_TOOLS:BOOL=OFF
    -DgRPC_INSTALL:BOOL=OFF
    -DCMAKE_CXX_FLAGS:STRING=${CMAKE_CXX_FLAGS}\ -Wno-unused-command-line-argument
    -DCMAKE_C_FLAGS:STRING=${CMAKE_C_FLAGS}\ -Wno-unused-command-line-argument
)

# ed25519 crypto
set(_ED25519_RANDOM dev_urandom)

# tsl_hat_trie
set(tsl_hat_trie_patch
    PATCH_COMMAND ${CMAKE_COMMAND} -E copy
    "${PROJECT_BUILD_FOLDER}/cmake.in/hat-trie-patch/CMakeLists.foriOS.txt" <SOURCE_DIR>/CMakeLists.txt
)

# MNN
set(_MNN_WIN_RUNTIME_MT OFF)
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
