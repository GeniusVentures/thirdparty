# special settings for Windows build on windows machine
# this is the common stuff for building
cmake_minimum_required(VERSION 3.15)

# if on Windows system, build the windows executables
if (NOT ${CMAKE_HOST_SYSTEM_NAME} MATCHES "Windows")
    message(FATAL_ERROR "${CMAKE_HOST_SYSTEM_NAME} host system name does not match Windows - Please select the correct folder for configuring project")
endif()

project(WINDOWS_SHARED_THIRD_PARTY)

# ------------------------------------------
# Set Windows specific runtime options
if (CMAKE_BUILD_TYPE STREQUAL Debug)
  set(MSVC_RUNTIME_LIBRARY_OPTION "MultiThreaded$<$<CONFIG:Debug>:Debug>")
endif()
if (CMAKE_BUILD_TYPE STREQUAL "Release")
    set(MSVC_RUNTIME_LIBRARY_OPTION "MultiThreaded$<$<CONFIG:Realease>:Release>")
endif()

# ------------------------------------------
# Enable c++ exceptions
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /EHsc /MP")

# --------------------------------------------------------
# build common libraries by platforms
include(../CommonCompilerOptions.CMake)

# ------------------------------------------
# Set Windows specific protobuf options
set(_PROTOBUF_CONFIG_DIR "${CMAKE_CURRENT_BINARY_DIR}/grpc/cmake")

# --------------------------------------------------------
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

# --------------------------------------------------------
# builds boost
set(_BOOST_ROOT "${CMAKE_CURRENT_BINARY_DIR}/boost/build/${CMAKE_SYSTEM_NAME}")
set(Boost_NO_SYSTEM_PATHS  ON)
set(Boost_USE_STATIC_LIBS  ON)
set(Boost_USE_STATIC_RUNTIME ON)
if (${CMAKE_BUILD_TYPE} STREQUAL "Debug")
	set(BOOST_VARIANT "debug")
else()
	set(BOOST_VARIANT "release")
endif(${CMAKE_BUILD_TYPE} STREQUAL "Debug")

ExternalProject_Add(Boost
      PREFIX boost
      SOURCE_DIR  "${THIRDPARTY_DIR}/boost"
	  LOG_MERGED_STDOUTERR  TRUE
	  LOG_OUTPUT_ON_FAILURE TRUE
	  LOG_CONFIGURE ON
	  LOG_BUILD OFF
	  LOG_INSTALL ON
      #UPDATE_COMMAND ${CMAKE_COMMAND} -E copy ${THIRDPARTY_DIR}/build/cmake.in/boost-patch/system_category_win32.hpp ${THIRDPARTY_DIR}/boost/libs/system/include/boost/system/detail/system_category_win32.hpp
      PATCH_COMMAND ./bootstrap.bat ${VC_PLATFORMTOOLSET}
      CONFIGURE_COMMAND ""
      BUILD_COMMAND ./b2.exe headers
	  BUILD_IN_SOURCE  TRUE
      INSTALL_COMMAND ./b2.exe toolset=${BOOST_TOOLSET} runtime-link=static visibility=global --build-type=minimal --with-thread --with-program_options --with-system --with-date_time --with-regex --with-chrono --with-atomic --with-random --with-filesystem --with-log --with-container --with-test address-model=64 architecture=x86  variant=${BOOST_VARIANT}  link=static threading=multi   --stagedir=stage/x64  --build-dir=${_BOOST_ROOT}  --prefix=${_BOOST_ROOT}   --libdir=${_BOOST_ROOT}/lib install
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
      -DBoost_DIR:PATH=${BOOST_LIB_CMAKE_DIR}/Boost-${BOOST_VERSION}
      -DBoost_INCLUDE_DIR:PATH=${_Boost_INCLUDE_DIR}
      -DBoost_USE_MULTITHREADED:BOOL=ON
      -DBoost_USE_STATIC_RUNTIME:BOOL=ON
      -DBoost_USE_STATIC_LIBS:BOOL=ON
      -DBoost_NO_SYSTEM_PATHS:BOOL=ON
)

# --------------------------------------------------------
# builds openssl
set(_openssl_BUILD_ROOT "${CMAKE_CURRENT_BINARY_DIR}/openssl/build/${CMAKE_SYSTEM_NAME}")

set(OPENSSL_CONFIG_MODE VC-WIN64A)
if (CMAKE_BUILD_TYPE STREQUAL "Debug")
    set(OPENSSL_CONFIG_MODE VC-WIN64A --debug)
endif()

ExternalProject_Add(openssl
	PREFIX openssl
	SOURCE_DIR  "${THIRDPARTY_DIR}/openssl"
	CONFIGURE_COMMAND perl ${THIRDPARTY_DIR}/openssl/Configure ${OPENSSL_CONFIG_MODE} enable-capieng no-shared no-asm --prefix=${_openssl_BUILD_ROOT} --openssldir=${_openssl_BUILD_ROOT}
	BUILD_COMMAND nmake build_libs
	BUILD_IN_SOURCE  false
	INSTALL_COMMAND nmake install_dev
	)
if (${CMAKE_SYSTEM_NAME} STREQUAL "Windows" AND CMAKE_BUILD_TYPE STREQUAL "Debug")
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
	-DgRPC_MSVC_STATIC_RUNTIME:BOOL=ON
	-Dprotobuf_MSVC_STATIC_RUNTIME:BOOL=ON
	-Dprotobuf_BUILD_TESTS:BOOL=OFF
	-DBUILD_SHARED_LIBS:BOOL=OFF

)

# --------------------------------------------------------
# Set ed25519 OS specific configurations
set(_ED25519_EDIIMPL ref10)
set(_ED25519_HASH sha3_brainhub)
set(_ED25519_RANDOM bcryptgen)

# --------------------------------------------------------
# Set config for libp2p/ifps modules
set(_libp2p_BUILD_EXAMPLES OFF)
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

# --------------------------------------------------------
# Allow multiple definitions
set(FORCE_MULTILE ON)
set(MULTIPLE_OPTION /FORCE:MULTIPLE)

# --------------------------------------------------------
# build common targets
include(../CommonTargets.CMake)

# for rocksdb windows needs > windows 8
set(rocksdb_EXTRA_PARAM
	-D_WIN32_WINNT:STRING=_WIN32_WINNT_WIN8
)

