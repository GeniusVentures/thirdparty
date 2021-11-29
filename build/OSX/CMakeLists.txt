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

project(OSX_SHARED_THIRD_PARTY)

# --------------------------------------------------------
# build common libraries by platforms
include(../CommonCompilerOptions.CMake)

# ------------------------------------------
# Set OSX specific runtime options

set(CMAKE_OSX_ARCHITECTURES "arm64;x86_64")
set(CMAKE_MACOSX_RPATH 1)
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM "BOTH")
set(_CMAKE_COMMON_BUILD_PARAMS ${_CMAKE_COMMON_BUILD_PARAMS}
   	-DCMAKE_SYSTEM_NAME:STRING=${CMAKE_SYSTEM_NAME}
    -DCMAKE_OSX_ARCHITECTURES:STRING=${CMAKE_OSX_ARCHITECTURES}
)

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
	PATCH_COMMAND <SOURCE_DIR>/bootstrap.sh
	BUILD_COMMAND <SOURCE_DIR>/b2 headers
	BUILD_IN_SOURCE  TRUE
	INSTALL_COMMAND <SOURCE_DIR>/b2 cxxflags="-std=c++17" runtime-link=static link=static threading=multi  --build-type=minimal  --with-log --with-thread --with-program_options --with-system --with-date_time --with-regex --with-chrono --with-atomic --with-random --with-filesystem  address-model=${address_model} architecture=x86  variant=release   --stagedir=stage/x64  --build-dir=<SOURCE_DIR>${_BOOST_ROOT}  --prefix=${_BOOST_ROOT}   --libdir=${_BOOST_ROOT}/lib  install
	UPDATE_COMMAND ""
)
set(boost_headers_DIR "${_BOOST_ROOT}/lib/cmake/boost_headers-1.72.0")
set(boost_random_DIR "${_BOOST_ROOT}/lib/cmake/boost_random-1.72.0")
set(boost_system_DIR "${_BOOST_ROOT}/lib/cmake/boost_system-1.72.0")
set(boost_filesystem_DIR "${_BOOST_ROOT}/lib/cmake/boost_filesystem-1.72.0")
set(boost_program_options_DIR "${_BOOST_ROOT}/lib/cmake/boost_program_options-1.72.0")
set(boost_DIR "${_BOOST_ROOT}/lib/cmake/Boost-1.72.0")
set(_Boost_INCLUDE_DIR "${_BOOST_ROOT}/include")

set(_BOOST_CACHE_ARGS
	-Dboost_headers_DIR:PATH=${boost_headers_DIR}
	-Dboost_random_DIR:PATH=${boost_random_DIR}
	-Dboost_system_DIR:PATH=${boost_system_DIR}
	-Dboost_filesystem_DIR:PATH=${boost_filesystem_DIR}
	-Dboost_program_options_DIR:PATH=${boost_program_options_DIR}
	-DBoost_DIR:PATH=${boost_DIR}
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
    PREFIX "${THIRDPARTY_DIR}/openssl/"
	SOURCE_DIR    "${THIRDPARTY_DIR}/openssl"
	CONFIGURE_COMMAND  <SOURCE_DIR>/config --prefix=${_openssl_BUILD_ROOT} --openssldir=${_openssl_BUILD_ROOT}
    PATCH_COMMAND ""
    BUILD_COMMAND make build_libs
    #BUILD_IN_SOURCE  TRUE
    INSTALL_COMMAND make install_dev
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

# --------------------------------------------------------
# set config for grpc
set(_grpc_EXTRA_PARAM
    -D_gRPC_PROTOBUF_PROTOC_EXECUTABLE:STRING=${CMAKE_CURRENT_BINARY_DIR}/grpc/build/third_party/protobuf/protoc
    -D_gRPC_CPP_PLUGIN:STRING=${CMAKE_CURRENT_BINARY_DIR}/grpc/build/grpc_cpp_plugin
		-DgRPC_SSL_PROVIDER:STRING=package
	  -DgRPC_BUILD_GRPC_PYTHON_PLUGIN:BOOL=OFF
    -DgRPC_BUILD_GRPC_RUBY_PLUGIN:BOOL=OFF
    -DgRPC_BUILD_GRPC_PHP_PLUGIN:BOOL=OFF
    -DgRPC_BUILD_GRPC_OBJECTIVE_C_PLUGIN:BOOL=OFF
    -DgRPC_BUILD_GRPC_CPP_PLUGIN:BOOL=ON
    -DgRPC_BUILD_GRPC_NODE_PLUGIN:BOOL=OFF
    -DgRPC_BUILD_GRPC_CSHARP_PLUGIN:BOOL=OFF
)

# ------------------------------------------
# set config for ed25519 crypto
set(_ED25519_EDIIMPL ref10)
set(_ED25519_HASH sha3_brainhub)
set(_ED25519_RANDOM dev_urandom)

# --------------------------------------------------------
# Set config for libp2p
set(_libp2p_BUILD_EXAMPLES ON)

# --------------------------------------------------------
# Allow multiple definitions
set(FORCE_MULTILE ON)
set(MULTIPLE_OPTION "-Xlink=-force:multiple")

# --------------------------------------------------------
# build common targets
include(../CommonTargets.CMake)
