cmake_minimum_required(VERSION 3.22)

if(NOT ${CMAKE_HOST_SYSTEM_NAME} MATCHES "Windows")
    message(FATAL_ERROR "${CMAKE_HOST_SYSTEM_NAME} host system name does not match Windows - Please select the correct folder for configuring project")
endif()

cmake_policy(SET CMP0091 NEW)

project(WINDOWS_SHARED_THIRD_PARTY LANGUAGES C CXX)

# This speeds up build time when using `--parallel`
if(NOT CMAKE_VS_GLOBALS MATCHES "(^|;)UseMultiToolTask=")
    list(APPEND CMAKE_VS_GLOBALS UseMultiToolTask=true)
endif()

if(NOT CMAKE_VS_GLOBALS MATCHES "(^|;)EnforceProcessCountAcrossBuilds=")
    list(APPEND CMAKE_VS_GLOBALS EnforceProcessCountAcrossBuilds=true)
endif()

include(../CommonCompilerOptions.CMake)

set(_WALLET_CORE_GENERATE_SCRIPT "${THIRDPARTY_DIR}/wallet-core/tools/win-generate-files.bat")

# Set Windows specific protobuf options
set(_PROTOBUF_CONFIG_DIR "${CMAKE_CURRENT_BINARY_DIR}/grpc/cmake")

# Set Boost Windows specific configurations
set(VC_PLATFORMTOOLSET "vc193")
set(BOOST_TOOLSET "msvc-14.1")

if(MSVC_VERSION AND MSVC_VERSION GREATER_EQUAL 1920) # v142 toolset
    set(VC_PLATFORMTOOLSET "vc142")
    set(BOOST_TOOLSET "msvc-14.2")
endif()

if(MSVC_VERSION AND MSVC_VERSION GREATER_EQUAL 1930) # v143 toolset
    set(VC_PLATFORMTOOLSET "vc143")
    set(BOOST_TOOLSET "msvc-14.3")
endif()

# Boost
set(_BOOST_ROOT "${CMAKE_CURRENT_BINARY_DIR}/boost/build/${CMAKE_SYSTEM_NAME}")
set(Boost_NO_SYSTEM_PATHS ON)
set(Boost_USE_STATIC_LIBS ON)
set(Boost_USE_STATIC_RUNTIME ON)

list(TRANSFORM BOOST_INCLUDE_LIBRARIES PREPEND "--with-" OUTPUT_VARIABLE BOOST_INCLUDE_LIBRARIES_EXPANDED)
ExternalProject_Add(Boost
    PREFIX boost
    SOURCE_DIR "${THIRDPARTY_DIR}/boost"

    PATCH_COMMAND ./bootstrap.bat ${VC_PLATFORMTOOLSET}

    CONFIGURE_COMMAND ""

    BUILD_COMMAND ./b2.exe headers
    BUILD_IN_SOURCE TRUE

    INSTALL_COMMAND ./b2.exe cxxstd=${CMAKE_CXX_STANDARD} runtime-link=static visibility=global --build-type=minimal ${BOOST_INCLUDE_LIBRARIES_EXPANDED} address-model=64 architecture=x86 variant=${BOOST_VARIANT} link=static threading=multi --stagedir=stage/x64 --build-dir=${_BOOST_ROOT} --prefix=${_BOOST_ROOT} --libdir=${_BOOST_ROOT}/lib install
)
set(BOOST_LIB_CMAKE_DIR "${_BOOST_ROOT}/lib/cmake")

# not sure why this can't match the exaxt ${BOOST_VERSION} string of everything else.
set(_Boost_INCLUDE_DIR "${_BOOST_ROOT}/include/boost-${BOOST_VERSION_2U}")

set(_BOOST_CACHE_ARGS
    -Dboost_headers_DIR:PATH=${BOOST_LIB_CMAKE_DIR}/boost_headers-${BOOST_VERSION}
    -Dboost_random_DIR:PATH=${BOOST_LIB_CMAKE_DIR}/boost_random-${BOOST_VERSION}
    -Dboost_system_DIR:PATH=${BOOST_LIB_CMAKE_DIR}/boost_system-${BOOST_VERSION}
    -Dboost_filesystem_DIR:PATH=${BOOST_LIB_CMAKE_DIR}/boost_filesystem-${BOOST_VERSION}
    -Dboost_program_options_DIR:PATH=${BOOST_LIB_CMAKE_DIR}/boost_program_options-${BOOST_VERSION}
    -Dboost_regex_DIR:PATH=${BOOST_LIB_CMAKE_DIR}/boost_regex-${BOOST_VERSION}
    -Dboost_date_time_DIR:PATH=${BOOST_LIB_CMAKE_DIR}/boost_date_time-${BOOST_VERSION}
    -DBoost_DIR:PATH=${BOOST_LIB_CMAKE_DIR}/Boost-${BOOST_VERSION}
    -DBOOST_ROOT:PATH=${_BOOST_ROOT}
    -DBoost_INCLUDE_DIR:PATH=${_Boost_INCLUDE_DIR}
    -DBoost_USE_MULTITHREADED:BOOL=ON
    -DBoost_USE_STATIC_RUNTIME:BOOL=ON
    -DBoost_USE_STATIC_LIBS:BOOL=ON
    -DBoost_NO_SYSTEM_PATHS:BOOL=ON
)

# builds openssl
set(_openssl_BUILD_ROOT "${CMAKE_CURRENT_BINARY_DIR}/openssl/build/${CMAKE_SYSTEM_NAME}")

ExternalProject_Add(openssl
    PREFIX openssl
    SOURCE_DIR "${THIRDPARTY_DIR}/openssl"
    CONFIGURE_COMMAND perl ${THIRDPARTY_DIR}/openssl/Configure $<IF:$<CONFIG:Debug>,--debug,--release> enable-capieng no-shared no-asm --prefix=${_openssl_BUILD_ROOT} --openssldir=${_openssl_BUILD_ROOT} VC-WIN64A
    BUILD_COMMAND nmake build_libs
    BUILD_IN_SOURCE false
    INSTALL_COMMAND nmake install_dev
)

if(${CMAKE_SYSTEM_NAME} STREQUAL "Windows" AND $<CONFIG:Debug>)
    ExternalProject_Add_Step(openssl AddDebugSuffix
        DEPENDEES install
        COMMAND ${CMAKE_COMMAND} -E rename ${_openssl_BUILD_ROOT}/lib/libcrypto.lib ${_openssl_BUILD_ROOT}/lib/libcryptod.lib
        COMMAND ${CMAKE_COMMAND} -E rename ${_openssl_BUILD_ROOT}/lib/libssl.lib ${_openssl_BUILD_ROOT}/lib/libssld.lib
    )
endif()

set(_OPENSSL_CACHE_ARGS
    -DOPENSSL_USE_STATIC_LIBS:BOOL=ON
    -DOPENSSL_MSVC_STATIC_RT:BOOL=ON
    -DOPENSSL_ROOT_DIR:STRING=${_openssl_BUILD_ROOT}
    -DOPENSSL_INCLUDE_DIR:PATH=${_openssl_BUILD_ROOT}/include
    -DOPENSSL_LIBRARIES:PATH=${_openssl_BUILD_ROOT}/lib
)
set(_OPENSSL_INCLUDE_DIR ${_openssl_BUILD_ROOT}/include)

# set config for grpc
set(_grpc_EXTRA_PARAM
    -D_gRPC_PROTOBUF_PROTOC_EXECUTABLE:STRING=${CMAKE_CURRENT_BINARY_DIR}/grpc/bin/protoc
    -D_gRPC_CPP_PLUGIN:STRING=${CMAKE_CURRENT_BINARY_DIR}/grpc/bin/grpc_cpp_plugin
    -DgRPC_MSVC_STATIC_RUNTIME:BOOL=ON
    -Dprotobuf_MSVC_STATIC_RUNTIME:BOOL=ON
    -Dprotobuf_BUILD_TESTS:BOOL=OFF
    -DBUILD_SHARED_LIBS:BOOL=OFF
)

# Build protobuf project from the git submodule
set(PROTOBUF_SRC_DIR "${THIRDPARTY_DIR}/grpc/third_party/protobuf/cmake")

# Build protobuf project from the git submodule.
ExternalProject_Add(protobuf
    PREFIX protobuf
    SOURCE_DIR "${PROTOBUF_SRC_DIR}"
    CMAKE_CACHE_ARGS
    -Dprotobuf_BUILD_TESTS:BOOL=OFF
    -Dprotobuf_WITH_ZLIB:BOOL=OFF
    -Dprotobuf_MSVC_STATIC_RUNTIME:BOOL=OFF
    -DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_CURRENT_BINARY_DIR}/protobuf
    -Dprotobuf_BUILD_PROTOC_BINARIES:BOOL=ON
)

set(PROTOC_EXECUTABLE "${CMAKE_CURRENT_BINARY_DIR}/protobuf/bin/protoc")
set(_PROTOBUF_TARGET protobuf)
set(_PROTOBUF_HOST_CONFIG_DIR "${CMAKE_CURRENT_BINARY_DIR}/protobuf/cmake")
set(_PROTOBUF_HOST_INCLUDE_DIR "${CMAKE_CURRENT_BINARY_DIR}/protobuf/include")
set(_PROTOBUF_HOST_LIB_DIR "${CMAKE_CURRENT_BINARY_DIR}/protobuf/lib")

# Set ed25519 OS specific configurations
set(_ED25519_EDIIMPL ref10)
set(_ED25519_HASH sha3_brainhub)
set(_ED25519_RANDOM bcryptgen)

# eliminates some warnings on windows
set(libp2_EXTRA_PARAM
    -D_WIN32_WINNT:STRING=_WIN32_WINNT_WIN7
)

set(ipfs-lite-cpp_EXTRA_PARAM
    -D_WIN32_WINNT:STRING=_WIN32_WINNT_WIN7
)

set(ipfs-pubsub_EXTRA_PARAM
    -D_WIN32_WINNT:STRING=_WIN32_WINNT_WIN7
)

set(ipfs-bitswap-cpp_EXTRA_PARAM
    -D_WIN32_WINNT:STRING=_WIN32_WINNT_WIN7
)

# Set config for MNN modules
set(_MNN_WIN_RUNTIME_MT ON)

# Allow multiple definitions
set(MULTIPLE_OPTION /FORCE:MULTIPLE)

# for rocksdb windows needs > windows 8
set(rocksdb_EXTRA_PARAM
    -D_WIN32_WINNT:STRING=_WIN32_WINNT_WIN8
)

# build common targets
include(../CommonTargets.CMake)
