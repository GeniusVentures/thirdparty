
cmake_minimum_required(VERSION 3.15)

project(ANDROID_SHARED_THIRD_PARTY)

# --------------------------------------------------------
# Include common compiler options
include(../CommonCompilerOptions.CMake)

# --------------------------------------------------------
# Set Android cross compile specific options
find_program(MAKE_EXE NAMES gmake nmake make)
set(CMAKE_SYSTEM_NAME Android)
set(CMAKE_SYSTEM_VERSION 28) # API level
set(ANDROID_PLATFORM_LEVEL 28)
set(ANDROID_NATIVE_API_LEVEL ${ANDROID_PLATFORM_LEVEL})

if(NOT CMAKE_ANDROID_NDK)
	message(FATAL_ERROR "Cannot find Android NDK, make sure you pass -DCMAKE_ANDROID_NDK=[path_to_NDK]")
endif()

file(READ "${CMAKE_ANDROID_NDK}/source.properties" SOURCE_PROPERTIES_CONTENT)
string(REGEX MATCH "Pkg\\.Revision = ([0-9]+)\\.([0-9]+)\\." NDK_VERSION_MATCH "${SOURCE_PROPERTIES_CONTENT}")
set(CMAKE_ANDROID_NDK_VERSION ${CMAKE_MATCH_1})
set(CMAKE_ANDROID_NDK_VERSION_MINOR ${CMAKE_MATCH_2})

print("Android NDK version: ${CMAKE_ANDROID_NDK_VERSION}.${CMAKE_ANDROID_NDK_VERSION_MINOR}")

if (NOT CMAKE_ANDROID_NDK_VERSION EQUAL 23)
  message(FATAL_ERROR "Android NDK LTS Version (r23b) stable long term support version required")
endif()

set(CMAKE_TOOLCHAIN_FILE "${CMAKE_ANDROID_NDK}/build/cmake/android.toolchain.cmake")
if(NOT EXISTS ${CMAKE_TOOLCHAIN_FILE})
  message(FATAL_ERROR "Android NDK toolchain file ${CMAKE_TOOLCHAIN_FILE} not found")
endif()

if("${LINUX_TARGET_ARCHITECTURES}" STREQUAL "")
    set(LINUX_TARGET_ARCHITECTURES "${CMAKE_HOST_SYSTEM_PROCESSOR}")
endif("${LINUX_TARGET_ARCHITECTURES}" STREQUAL "")

# --------------------------------------------------------
## Config param for android
set(_CMAKE_COMMON_BUILD_PARAMS ${_CMAKE_COMMON_BUILD_PARAMS}
  -DCMAKE_SYSTEM_NAME:STRING=${CMAKE_SYSTEM_NAME}
  -DCMAKE_ANDROID_NDK:PATH=${CMAKE_ANDROID_NDK}
	-DANDROID_ABI:STRING=${ANDROID_ABI}
	-DANDROID_PLATFORM_LEVEL:STRING=${ANDROID_PLATFORM_LEVEL}
	-DANDROID_NATIVE_API_LEVEL:STRING=${ANDROID_NATIVE_API_LEVEL}
	-DANDROID_TOOLCHAIN:STRING=${ANDROID_TOOLCHAIN}
	-DANDROID_STL:STRING=c++_static
	-DCMAKE_TOOLCHAIN_FILE:PATH=${CMAKE_TOOLCHAIN_FILE}
	-DOPENSSL_USE_STATIC_LIBS:BOOL=TRUE
	)

# --------------------------------------------------------
# build boost
set(BOOST_VERSION2 1_72_0)
set(_BOOST_ROOT "${CMAKE_CURRENT_BINARY_DIR}/boost/build/Android/${ANDROID_ABI}")
ExternalProject_Add( Boost
	PREFIX boost
	SOURCE_DIR    "${THIRDPARTY_DIR}/boost"
	CONFIGURE_COMMAND  ""
	PATCH_COMMAND ${CMAKE_COMMAND} -E copy_directory ${CMAKE_CURRENT_SOURCE_DIR}/Boost-build ${THIRDPARTY_DIR}/boost
	BUILD_COMMAND  <SOURCE_DIR>/build.sh "${_BOOST_ROOT}" ${ANDROID_ABI} "${THIRDPARTY_DIR}/boost" ${CMAKE_BUILD_TYPE} $ENV{ANDROID_NDK}
	INSTALL_COMMAND ""
	UPDATE_COMMAND ""
)

set(Boost_NO_SYSTEM_PATHS  ON)
set(Boost_USE_STATIC_LIBS  ON)
set(BOOST_ROOT ${_BOOST_ROOT})
set(_Boost_INCLUDE_DIR  ${BOOST_ROOT}/include)
set(BOOST_LIBRARYDIR ${BOOST_ROOT}/lib)
set(Boost_DIR "${BOOST_LIBRARYDIR}/cmake/Boost-1.72.0")
set(boost_headers_DIR "${BOOST_LIBRARYDIR}/cmake/boost_headers-1.72.0")
set(boost_random_DIR "${BOOST_LIBRARYDIR}/cmake/boost_random-1.72.0")
set(boost_system_DIR "${BOOST_LIBRARYDIR}/cmake/boost_system-1.72.0")
set(boost_filesystem_DIR "${BOOST_LIBRARYDIR}/cmake/boost_filesystem-1.72.0")
set(boost_program_options_DIR "${BOOST_LIBRARYDIR}/cmake/boost_program_options-1.72.0")
set(boost_date_time_DIR "${BOOST_LIBRARYDIR}/cmake/boost_date_time-1.72.0")
set(boost_regex_DIR "${BOOST_LIBRARYDIR}/cmake/boost_regex-1.72.0")
print("boost dir ${_BOOST_ROOT}")
print("boost lib ${BOOST_LIBRARYDIR}")

if(_BOOST_INCLUDE_DIR)
else()
   set(_BOOST_INCLUDE_DIR "${Boost_INCLUDE_DIRS}")
   set(BOOST_LIBRARY_DIR "${Boost_LIBRARIES}")
endif()

set(BOOST_INCLUDE_DIR ${_Boost_INCLUDE_DIR})
set(_BOOST_CACHE_ARGS
   -DBOOST_ROOT:PATH=${BOOST_ROOT}
   -DBoost_USE_MULTITHREADED:BOOL=ON
   -DBoost_USE_STATIC_RUNTIME:BOOL=ON
   -DBoost_USE_STATIC_LIBS:BOOL=ON
   -DBoost_NO_SYSTEM_PATHS:BOOL=ON
   -DBoost_INCLUDE_DIR:PATH=${_Boost_INCLUDE_DIR}
   -DBOOST_LIBRARYDIR:PATH=${BOOST_LIBRARYDIR}
   -DBOOST_MIN_VERSION:STRING=1.70.0
   -DBoost_DIR:PATH=${Boost_DIR}
   -Dboost_headers_DIR:PATH=${boost_headers_DIR}
   -Dboost_random_DIR:PATH=${boost_random_DIR}
   -Dboost_system_DIR:PATH=${boost_system_DIR}
   -Dboost_filesystem_DIR:PATH=${boost_filesystem_DIR}
   -Dboost_program_options_DIR:PATH=${boost_program_options_DIR}
   -Dboost_date_time_DIR:PATH=${boost_date_time_DIR}
   -Dboost_regex_DIR:PATH=${boost_regex_DIR}
)

# --------------------------------------------------------
# build OpenSSL

if(ANDROID_ABI STREQUAL "arm64-v8a")
	set(_abi android-arm64)
elseif(ANDROID_ABI STREQUAL "armeabi-v7a")
	set(_abi android-arm)
elseif(ANDROID_ABI STREQUAL "x86")
	set(_abi android-x86)
elseif(ANDROID_ABI STREQUAL "x86_64")
	set(_abi android-x86_64)
endif()
message("android abi is ${_abi}")

set(_openssl_BUILD_ROOT "${CMAKE_CURRENT_BINARY_DIR}/openssl/build/Android/${ANDROID_ABI}")
ExternalProject_Add(openssl
	PREFIX openssl
	GIT_SHALLOW TRUE
	SOURCE_DIR    "${THIRDPARTY_DIR}/openssl"
	CONFIGURE_COMMAND  ""
	BUILD_COMMAND  ${CMAKE_CURRENT_SOURCE_DIR}/Openssl-build/build.sh --abi=${_abi} --api-level=${ANDROID_NATIVE_API_LEVEL} --build-dir=${_openssl_BUILD_ROOT} --env_path=$ENV{PATH} --env_android_ndk=$ENV{ANDROID_NDK} --env_android_toolchain=$ENV{ANDROID_TOOLCHAIN}
	BUILD_IN_SOURCE  FALSE
	UPDATE_COMMAND ""
	INSTALL_COMMAND make install_dev
)

print("openssl ${_openssl_BUILD_ROOT}")
set(_OPENSSL_INCLUDE_DIR ${_openssl_BUILD_ROOT}/include)
set(_OPENSSL_CACHE_ARGS
	  -DOPENSSL_USE_STATIC_LIBS:BOOL=ON
	  -DOPENSSL_ROOT_DIR:PATH=${_openssl_BUILD_ROOT}
	  -DOPENSSL_INCLUDE_DIR:PATH=${_OPENSSL_INCLUDE_DIR}
    -DOPENSSL_LIBRARIES:PATH=${_openssl_BUILD_ROOT}/lib
    -DOPENSSL_CRYPTO_LIBRARY:PATH=${_openssl_BUILD_ROOT}/lib/libcrypto${CMAKE_STATIC_LIBRARY_SUFFIX}
    -DOPENSSL_SSL_LIBRARY:PATH=${_openssl_BUILD_ROOT}/lib/libssl${CMAKE_STATIC_LIBRARY_SUFFIX}
)

# --------------------------------------------------------
# set config for grpc
set(_grpc_EXTRA_PARAM
	-DgRPC_BUILD_GRPC_PYTHON_PLUGIN:BOOL=OFF
	-DgRPC_BUILD_GRPC_RUBY_PLUGIN:BOOL=OFF
	-DgRPC_BUILD_GRPC_PHP_PLUGIN:BOOL=OFF
	-DgRPC_BUILD_GRPC_OBJECTIVE_C_PLUGIN:BOOL=OFF
	-DgRPC_BUILD_GRPC_NODE_PLUGIN:BOOL=OFF
	-DgRPC_BUILD_GRPC_CSHARP_PLUGIN:BOOL=OFF
	-DgRPC_BUILD_GRPC_CPP_PLUGIN:BOOL=OFF
	-DgRPC_BUILD_CSHARP_EXT:BOOL=OFF
  -DgRPC_BUILD_CODEGEN:BOOL=OFF
  -DCMAKE_CXX_FLAGS:STRING=${CMAKE_CXX_FLAGS}\ -llog\ -Wno-unused-command-line-argument
)

# --------------------------------------------------------
# set config for rocksdb
set(_rocksdb_EXTRA_PARAM
    -DROCKSDB_LITE:BOOL=ON
)


# --------------------------------------------------------
# Build protobuf project from the git submodule for local executation of protoc.
ExternalProject_Add(protobuf
  PREFIX protobuf
  BINARY_DIR "${CMAKE_CURRENT_BINARY_DIR}/protobuf"
  SOURCE_DIR "${THIRDPARTY_DIR}/grpc/third_party/protobuf/cmake"
  CMAKE_CACHE_ARGS
        -Dprotobuf_BUILD_TESTS:BOOL=OFF
        -Dprotobuf_WITH_ZLIB:BOOL=OFF
        -Dprotobuf_MSVC_STATIC_RUNTIME:BOOL=OFF
        -DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_CURRENT_BINARY_DIR}/protobuf
        -Dprotobuf_BUILD_PROTOC_BINARIES:BOOL=ON
  DEPENDS
)
set(PROTOC_EXECUTABLE "${CMAKE_CURRENT_BINARY_DIR}/protobuf/bin/protoc")
set(_PROTOBUF_TARGET protobuf)

# --------------------------------------------------------
# set config for ed25519 crypto
set(_ED25519_EDIIMPL ref10)
set(_ED25519_HASH sha3_brainhub)
set(_ED25519_RANDOM dev_urandom)

# --------------------------------------------------------
# Set config for libp2p
set(_libp2p_BUILD_EXAMPLES OFF)

# --------------------------------------------------------
# Set config for kompute
set(_KOMPUTE_EXTRA_PARAM
	-DKOMPUTE_OPT_ANDROID_BUILD:BOOL=ON
	-DCMAKE_ANDROID_STL_TYPE:STRING=stlport_static
)

# --------------------------------------------------------
# Allow multiple definitions
set(FORCE_MULTILE OFF)

# --------------------------------------------------------
# build common targets
include(../CommonTargets.CMake)
