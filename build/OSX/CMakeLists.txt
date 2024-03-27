cmake_minimum_required(VERSION 3.15)

# --------------------------------------------------------
# if on OSX Darwin system, build the OSX executables
if (NOT ${CMAKE_HOST_SYSTEM_NAME} MATCHES "Darwin")
    message(FATAL_ERROR "${CMAKE_HOST_SYSTEM_NAME} host system name does not match OSX Darwin - Please select the correct folder for configuring project")
endif()

if(POLICY CMP0025)
	#NEW: report OS X version of Clang as "AppleClang"
  cmake_policy(SET CMP0025 NEW)
endif()
if(POLICY CMP0042)
  #NEW: set TARGET PROPERTY MACOSX_RPATH to on by default
  cmake_policy(SET CMP0042 NEW)
endif()

set(CMAKE_OSX_DEPLOYMENT_TARGET "12.1" CACHE STRING "Minimum OS X deployment version" FORCE)

project(OSX_SHARED_THIRD_PARTY)

# --------------------------------------------------------
# build common libraries by platforms
include(../CommonCompilerOptions.CMake)

# ------------------------------------------
# Set OSX specific runtime options

# TODO: use single architecture to avoid Crypto3 error - removed ";arm64"  
set(CMAKE_OSX_ARCHITECTURES "x86_64")
set(CMAKE_MACOSX_RPATH 1)
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM "BOTH")

if (${CMAKE_BUILD_TYPE} STREQUAL "Debug")
	set(BUILD_VARIANT "--debug")
else()
	set(BUILD_VARIANT "")
endif(${CMAKE_BUILD_TYPE} STREQUAL "Debug")

# Assuming that xcode 12.0 is installed you most probably have ios sdk 14.0 or later installed (tested on Big Sur)
# if you don't set a deployment target it will be set the way you only get 64-bit builds
if(NOT DEFINED DEPLOYMENT_TARGET AND XCODE_VERSION_INT VERSION_GREATER 12.0)
  # Temporarily fix the arm64 issues in CMake install-combined by excluding arm64 for simulator builds (needed for Apple Silicon...)
  set(CMAKE_XCODE_ATTRIBUTE_EXCLUDED_ARCHS[sdk=iphonesimulator*] "arm64")
endif()

set(_CMAKE_COMMON_BUILD_PARAMS ${_CMAKE_COMMON_BUILD_PARAMS}
   	-DCMAKE_SYSTEM_NAME:STRING=${CMAKE_SYSTEM_NAME}
    -DCMAKE_OSX_ARCHITECTURES:STRING=${CMAKE_OSX_ARCHITECTURES}
    -DCMAKE_XCODE_ATTRIBUTE_ONLY_ACTIVE_ARCH:BOOL=YES
    -DCMAKE_IOS_INSTALL_COMBINED:BOOL=TRUE
    -DCMAKE_XCODE_ATTRIBUTE_VALID_ARCHS:STRING=${CMAKE_OSX_ARCHITECTURES}
    -DCMAKE_OSX_DEPLOYMENT_TARGET:STRING=${CMAKE_OSX_DEPLOYMENT_TARGET}
    -D"CMAKE_XCODE_ATTRIBUTE_EXCLUDED_ARCHS[sdk=iphonesimulator*]":STRING=arm64
)
#print("CMAKE_XCODE_ATTRIBUTE_EXCLUDED_ARCHS: ${'CMAKE_XCODE_ATTRIBUTE_EXCLUDED_ARCHS[sdk=iphonesimulator*]'}")

# ------------------------------------------
# build boost
if(CMAKE_SIZEOF_VOID_P EQUAL 4)
	set(address_model 32)
else()
	set(address_model 64)
endif()

set(_BOOST_ROOT "${CMAKE_CURRENT_BINARY_DIR}/boost/build/${CMAKE_SYSTEM_NAME}")
ExternalProject_Add( Boost
	PREFIX  boost
    SOURCE_DIR    "${THIRDPARTY_DIR}/boost"
	CONFIGURE_COMMAND  ""
	PATCH_COMMAND ""
 	BUILD_COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/Boost-build/build.sh ${BUILD_VARIANT} --build-dir=${_BOOST_ROOT} --src-dir=${THIRDPARTY_DIR}/boost --deployment-target=${CMAKE_OSX_DEPLOYMENT_TARGET}
	INSTALL_COMMAND ""
	UPDATE_COMMAND ""
)


print("BOOST_VERSION: ${BOOST_VERSION}")
set(boost_headers_DIR "${_BOOST_ROOT}/lib/cmake/boost_headers-${BOOST_VERSION}")
set(boost_random_DIR "${_BOOST_ROOT}/lib/cmake/boost_random-${BOOST_VERSION}")
set(boost_system_DIR "${_BOOST_ROOT}/lib/cmake/boost_system-${BOOST_VERSION}")
set(boost_filesystem_DIR "${_BOOST_ROOT}/lib/cmake/boost_filesystem-${BOOST_VERSION}")
set(boost_program_options_DIR "${_BOOST_ROOT}/lib/cmake/boost_program_options-${BOOST_VERSION}")
set(boost_regex_DIR "${_BOOST_ROOT}/lib/cmake/boost_regex-${BOOST_VERSION}")
set(boost_date_time_DIR "${_BOOST_ROOT}/lib/cmake/boost_date_time-${BOOST_VERSION}")
set(boost_DIR "${_BOOST_ROOT}/lib/cmake/Boost-${BOOST_VERSION}")
set(Boost_USE_STATIC_RUNTIME ON)
print("boost_DIR: ${boost_DIR}")
set(_Boost_INCLUDE_DIR "${_BOOST_ROOT}/include")
set(_FINDPACKAGE_BOOST_CONFIG_DIR ${boost_DIR})

set(_BOOST_CACHE_ARGS
	-Dboost_headers_DIR:PATH=${boost_headers_DIR}
	-Dboost_random_DIR:PATH=${boost_random_DIR}
	-Dboost_system_DIR:PATH=${boost_system_DIR}
	-Dboost_filesystem_DIR:PATH=${boost_filesystem_DIR}
	-Dboost_program_options_DIR:PATH=${boost_program_options_DIR}
	-Dboost_regex_DIR:PATH=${boost_regex_DIR}
	-Dboost_date_time_DIR:PATH=${boost_date-time_DIR}
	-DBoost_DIR:PATH=${boost_DIR}
	-DBOOST_ROOT:PATH=${_BOOST_ROOT}
	-DBoost_USE_MULTITHREADED:BOOL=ON
	-DBoost_USE_STATIC_RUNTIME:BOOL=ON
	-DBoost_USE_STATIC_LIBS:BOOL=ON
	-DBoost_NO_SYSTEM_PATHS:BOOL=ON
	-DBoost_INCLUDE_DIR:PATH=${_BOOST_ROOT}/include
)

# ------------------------------------------
# build OpenSSL
set(_openssl_BUILD_ROOT "${CMAKE_CURRENT_BINARY_DIR}/openssl/build/${CMAKE_SYSTEM_NAME}")
ExternalProject_Add(openssl
    PREFIX openssl
	  SOURCE_DIR    "${THIRDPARTY_DIR}/openssl"
	  CONFIGURE_COMMAND  ""
    PATCH_COMMAND ""
    BUILD_COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/Openssl-build/build.sh ${BUILD_VARIANT} --build-dir=${_openssl_BUILD_ROOT} --src-dir=${THIRDPARTY_DIR}/openssl --deployment-target=${CMAKE_OSX_DEPLOYMENT_TARGET}
    INSTALL_COMMAND ""
    UPDATE_COMMAND ""
)
set(OPENSSL_USE_STATIC_LIBS  ON)
set(_OPENSSL_INCLUDE_DIR ${_openssl_BUILD_ROOT}/include)

set(_OPENSSL_CACHE_ARGS
	-DOPENSSL_USE_STATIC_LIBS:BOOL=ON
	-DOPENSSL_ROOT_DIR:STRING=${_openssl_BUILD_ROOT}
  -DOPENSSL_INCLUDE_DIR:PATH=${_OPENSSL_INCLUDE_DIR}
  -DOPENSSL_CRYPTO_LIBRARY:PATH=${_openssl_BUILD_ROOT}/lib/libcrypto${CMAKE_STATIC_LIBRARY_SUFFIX}
  -DOPENSSL_SSL_LIBRARY:PATH=${_openssl_BUILD_ROOT}/lib/libssl${CMAKE_STATIC_LIBRARY_SUFFIX}
)


# ------------------------------------------
# build MoltenVK
set(_MVK_ROOT "${CMAKE_CURRENT_BINARY_DIR}/MoltenVK/build/${CMAKE_SYSTEM_NAME}")
ExternalProject_Add(MoltenVK
	PREFIX  moltenvk
    SOURCE_DIR    "${THIRDPARTY_DIR}/MoltenVK"
	CONFIGURE_COMMAND  ""
	PATCH_COMMAND ""
 	BUILD_COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/MoltenVK-build/build.sh ${BUILD_VARIANT} --build-dir=${_MVK_ROOT} --src-dir=${THIRDPARTY_DIR}/MoltenVK --deployment-target=${CMAKE_OSX_DEPLOYMENT_TARGET}
	INSTALL_COMMAND ""
	UPDATE_COMMAND ""
)

# --------------------------------------------------------
# set config for grpc
set(_grpc_EXTRA_PARAM
    -D_gRPC_PROTOBUF_PROTOC_EXECUTABLE:STRING=${CMAKE_CURRENT_BINARY_DIR}/grpc/bin/third_party/protobuf/protoc
    -D_gRPC_CPP_PLUGIN:STRING=${CMAKE_CURRENT_BINARY_DIR}/grpc/bin/grpc_cpp_plugin
		-DgRPC_SSL_PROVIDER:STRING=package
	  -DgRPC_BUILD_GRPC_PYTHON_PLUGIN:BOOL=OFF
    -DgRPC_BUILD_GRPC_RUBY_PLUGIN:BOOL=OFF
    -DgRPC_BUILD_GRPC_PHP_PLUGIN:BOOL=OFF
    -DgRPC_BUILD_GRPC_OBJECTIVE_C_PLUGIN:BOOL=OFF
    -DgRPC_BUILD_GRPC_CPP_PLUGIN:BOOL=ON
    -DgRPC_BUILD_GRPC_NODE_PLUGIN:BOOL=OFF
    -DgRPC_BUILD_GRPC_CSHARP_PLUGIN:BOOL=OFF
)

# --------------------------------------------------------
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
set(_PROTOBUF_HOST_CONFIG_DIR "${CMAKE_CURRENT_BINARY_DIR}/protobuf/lib/cmake/protobuf")
set(_PROTOBUF_HOST_INCLUDE_DIR "${CMAKE_CURRENT_BINARY_DIR}/protobuf/include")
set(_PROTOBUF_HOST_LIB_DIR "${CMAKE_CURRENT_BINARY_DIR}/protobuf/lib")

# --------------------------------------------------------
# set config for rocksdb
set(_rocksdb_EXTRA_PARAM
  -DHAS_ARMV8_CRC:BOOL=ON)

# ------------------------------------------
# set config for ed25519 crypto
set(_ED25519_EDIIMPL ref10)
set(_ED25519_HASH sha3_brainhub)
set(_ED25519_RANDOM dev_urandom)

# --------------------------------------------------------
# Set config for libp2p
set(_libp2p_BUILD_EXAMPLES ON)

# ---------------------------------------------------------
# Set config for MNN modules
set(_MNN_WIN_RUNTIME_MT OFF)

# --------------------------------------------------------
# Allow multiple definitions
set(FORCE_MULTILE ON)
set(MULTIPLE_OPTION "-Xlink=-force:multiple")

# --------------------------------------------------------
# build common targets
include(../CommonTargets.CMake)
