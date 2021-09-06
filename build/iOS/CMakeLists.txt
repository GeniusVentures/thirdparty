
cmake_minimum_required(VERSION 3.15)

# --------------------------------------------------------
# if on OSX Darwin system, build the iOS executables
if (NOT ${CMAKE_HOST_SYSTEM_NAME} MATCHES "Darwin")
    message(FATAL_ERROR "${CMAKE_HOST_SYSTEM_NAME} host system name does not match OSX Darwin for iOS cross compiling - Please select the correct folder for configuring project")
endif()

if(POLICY CMP0025)
    #NEW: report OS X version of Clang as "AppleClang"
  cmake_policy(SET CMP0025 NEW)
endif()
if(POLICY CMP0042)
  #NEW: set TARGET PROPERTY MACOSX_RPATH to on by default
  cmake_policy(SET CMP0042 NEW)
endif()

set(IOS_DEPLOYMENT_TARGET 12.0)

project(iOS_SHARED_THIRD_PARTY)

# --------------------------------------------------------
# build common libraries by platforms
include(../CommonCompilerOptions.CMake)

# ------------------------------------------
# Set OSX specific runtime options
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM "BOTH")
set(CMAKE_SYSTEM_NAME "iOS")
set(_CMAKE_COMMON_BUILD_PARAMS ${_CMAKE_COMMON_BUILD_PARAMS}
    -DBoost_DIR:PATH=${Boost_DIR}
    -DBoost_NO_SYSTEM_PATHS:BOOL=ON
    -DBoost_USE_STATIC_LIBS:BOOL=ON
    -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
    -DCMAKE_SYSTEM_NAME:STRING=${CMAKE_SYSTEM_NAME}
    -DOPENSSL_USE_STATIC_LIBS:BOOL=TRUE
    -DCMAKE_TOOLCHAIN_FILE:PATH=${CMAKE_TOOLCHAIN_FILE}
    -DIOS_PLATFORM:STRING=${IOS_PLATFORM}
    -DIOS_ARCH:STRING=${IOS_ARCH}
    -DENABLE_ARC:STRING="0"
    -DENABLE_BITCODE:STRING=NO
    -DENABLE_VISIBILITY:STRING=${ENABLED_VISIBILITY}
    -DCMAKE_OSX_ARCHITECTURES:STRING=${CMAKE_OSX_ARCHITECTURES}
    -DIOS_SDK_VERSION:STRING=${IOS_SDK_VERSION}
    -DCMAKE_XCODE_ATTRIBUTE_ONLY_ACTIVE_ARCH:STRING=YES
    -DCMAKE_POLICY_DEFAULT_CMP0025:STRING=NEW
    -DCMAKE_POLICY_DEFAULT_CMP0042:STRING=NEW
)


# --------------------------------------------------------
# build boost
if(CMAKE_SIZEOF_VOID_P EQUAL 4)
    set(address_model 32)
else()
    set(address_model 64)
endif()
set(BOOST_ROOT "${CMAKE_CURRENT_BINARY_DIR}/boost/build/iOS/${iOS_ABI}")
ExternalProject_Add( Boost
    SOURCE_DIR  "${CMAKE_CURRENT_BINARY_DIR}/boost"
    PREFIX  "${CMAKE_CURRENT_BINARY_DIR}/boost"
    DOWNLOAD_COMMAND ""
    CONFIGURE_COMMAND  ""
    PATCH_COMMAND ${CMAKE_COMMAND} -E copy_directory  ${CMAKE_CURRENT_SOURCE_DIR}/Boost-build ${CMAKE_CURRENT_BINARY_DIR}/boost/src/Boost-build
    BUILD_COMMAND ${CMAKE_CURRENT_BINARY_DIR}/boost/src/Boost-build/build.sh -ios --boost-version 1.72.0 --build-dir ${BOOST_ROOT}
    INSTALL_COMMAND ""
    UPDATE_COMMAND ""
)

print("boost dir ${BOOST_ROOT}")
set(boost_headers_DIR "${BOOST_ROOT}/lib/cmake/boost_headers-1.72.0")
set(boost_random_DIR "${BOOST_ROOT}/lib/cmake/boost_random-1.72.0")
set(boost_system_DIR "${BOOST_ROOT}/lib/cmake/boost_system-1.72.0")
set(boost_filesystem_DIR "${BOOST_ROOT}/lib/cmake/boost_filesystem-1.72.0")
set(boost_program_options_DIR "${BOOST_ROOT}/lib/cmake/boost_program_options-1.72.0")
set(_Boost_INCLUDE_DIR ${BOOST_ROOT}/include)
set(_BOOST_CACHE_ARGS
    -DBOOST_ROOT:PATH=${BOOST_ROOT}
    -Dboost_headers_DIR:PATH=${boost_headers_DIR}
    -Dboost_random_DIR:PATH=${boost_random_DIR}
    -Dboost_system_DIR:PATH=${boost_system_DIR}
    -Dboost_filesystem_DIR:PATH=${boost_filesystem_DIR}
    -Dboost_program_options_DIR:PATH=${boost_program_options_DIR}
    -DBoost_DIR:PATH=${BOOST_ROOT}
    -DBoost_USE_MULTITHREADED:BOOL=ON
    -DBoost_USE_STATIC_RUNTIME:BOOL=OFF
    -DBoost_USE_STATIC_LIBS:BOOL=ON
    -DBoost_NO_SYSTEM_PATHS:BOOL=ON
    -DBoost_INCLUDE_DIR:PATH=${_Boost_INCLUDE_DIR}
)

# --------------------------------------------------------
# build OpenSSL
print("${CMAKE_COMMAND} -E copy_directory  ${CMAKE_CURRENT_SOURCE_DIR}/Openssl-build ${CMAKE_CURRENT_BINARY_DIR}/openssl")
set(_openssl_BUILD_ROOT "${CMAKE_CURRENT_BINARY_DIR}/openssl/build/${CMAKE_SYSTEM_NAME}/${iOS_ABI}")
ExternalProject_Add(openssl
    SOURCE_DIR  "${CMAKE_CURRENT_BINARY_DIR}/openssl"
    PREFIX "${THIRDPARTY_DIR}/openssl"
    DOWNLOAD_COMMAND ""
    CONFIGURE_COMMAND  ""
    PATCH_COMMAND ${CMAKE_COMMAND} -E copy_directory ${CMAKE_CURRENT_SOURCE_DIR}/Openssl-build ${CMAKE_CURRENT_BINARY_DIR}/openssl
    BUILD_COMMAND ${CMAKE_CURRENT_BINARY_DIR}/openssl/build-libssl.sh --version=1.1.1g --targets=ios64-cross-arm64 --build-dir=${_openssl_BUILD_ROOT}
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

# --------------------------------------------------------
# Build protobuf project from the git submodule for local executation of protoc.
set(_PROTOBUF_CONFIG_DIR "${CMAKE_CURRENT_BINARY_DIR}/protobuf/lib/cmake/protobuf")
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
          -Dprotobuf_BUILD_PROTOC_BINARIES:BOOL=OFF
          ${_CMAKE_COMMON_BUILD_PARAMS}
    DEPENDS
  )

set(_PROTOBUF_INCLUDE_DIR "${CMAKE_CURRENT_BINARY_DIR}/protobuf/include")
set(_PROTOBUF_LIB_DIR "${CMAKE_CURRENT_BINARY_DIR}/protobuf/lib")

# Build protoc for host OS
ExternalProject_Add(protobuf-host
    PREFIX protobuf-host
    SOURCE_DIR "${PROTOBUF_SRC_DIR}"
    CMAKE_CACHE_ARGS
          -Dprotobuf_BUILD_TESTS:BOOL=OFF
          -Dprotobuf_WITH_ZLIB:BOOL=OFF
          -Dprotobuf_MSVC_STATIC_RUNTIME:BOOL=OFF
          -DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_CURRENT_BINARY_DIR}/protobuf-host
          -Dprotobuf_BUILD_PROTOC_BINARIES:BOOL=ON
          ${CMAKE_CHCHE_ARGS_CFLAGES_ADD}
    DEPENDS
  )
set(PROTOC_EXECUTABLE "${CMAKE_CURRENT_BINARY_DIR}/protobuf-host/bin/protoc")
set(_PROTOBUF_TARGET protobuf protobuf-host)

# --------------------------------------------------------
# set config for grpc
set(_grpc_EXTRA_PARAM
        -DgRPC_SSL_PROVIDER:STRING=package
        -DgRPC_BUILD_GRPC_PYTHON_PLUGIN:BOOL=OFF
        -DgRPC_BUILD_GRPC_RUBY_PLUGIN:BOOL=OFF
        -DgRPC_BUILD_GRPC_PHP_PLUGIN:BOOL=OFF
        -DgRPC_BUILD_GRPC_OBJECTIVE_C_PLUGIN:BOOL=OFF
        -DgRPC_BUILD_GRPC_NODE_PLUGIN:BOOL=OFF
        -DgRPC_BUILD_GRPC_CSHARP_PLUGIN:BOOL=OFF
        -DgRPC_BUILD_CODEGEN:BOOL=OFF
        -DHAVE_LIBNSL:BOOL=FALSE
        -DHAVE_SOCKET_LIBSOCKET:BOOL=FALSE
        -DHAVE_GHBN_LIBSOCKET:BOOL=FALSE
        -DHAVE_LIBSOCKET:BOOL=FALSE
        -DHAVE_LIBRT:BOOL=FALSE
        -DCARES_BUILD_TOOLS:BOOL=OFF
)

# --------------------------------------------------------
# set config for ed25519 crypto
set(_ED25519_EDIIMPL ref10)
set(_ED25519_HASH sha3_brainhub)
set(_ED25519_RANDOM dev_urandom)
print("target platform IOS=${IOS}")


# --------------------------------------------------------
# Set tsl_hat_trie iOS specific configurations
set(tsl_hat_trie_patch
  PATCH_COMMAND ${CMAKE_COMMAND} -E copy
        "${PROJECT_BUILD_FOLDER}/cmake.in/hat-trie-patch/CMakeLists.foriOS.txt" <SOURCE_DIR>/CMakeLists.txt
)

# --------------------------------------------------------
# Set config for libp2p
set(_libp2p_BUILD_EXAMPLES ON)

# --------------------------------------------------------
# Set o iOS specific configurations
set(grpc_patch
 PATCH_COMMAND ${CMAKE_COMMAND} -E copy "${PROJECT_BUILD_FOLDER}/cmake.in/grpc-patch/ssl_transport_security.cc" <SOURCE_DIR>/src/core/tsi/ssl_transport_security.cc)

# --------------------------------------------------------
# Allow multiple definitions
set(FORCE_MULTILE ON)
set(MULTIPLE_OPTION "-Xlink=-force:multiple")

# --------------------------------------------------------
# build common targets
include(../CommonTargets.CMake)
