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
SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /EHsc")

# Enable cross-platform preprocessor syntax
# https://docs.microsoft.com/en-us/cpp/preprocessor/preprocessor-experimental-overview?view=msvc-160
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /Zc:preprocessor")

# --------------------------------------------------------
# build common libraries by platforms
include(../CommonCompilerOptions.CMake)

# ------------------------------------------
# Set Windows specific protobuf options
set(_PROTOBUF_CONFIG_DIR "${CMAKE_CURRENT_BINARY_DIR}/grpc/cmake")

# --------------------------------------------------------
# Set Boost Windows specific configurations
set(VC_PLATFORMTOOLSET "vc141")
set(BOOST_TOOLSET "msvc-14.1")
if(MSVC_VERSION AND MSVC_VERSION GREATER_EQUAL 1920) # v142 toolset
	set(VC_PLATFORMTOOLSET "vc142")
	set(BOOST_TOOLSET "msvc-14.2")
endif()

# --------------------------------------------------------
# builds boost
set(_BOOST_ROOT "${CMAKE_CURRENT_BINARY_DIR}/boost/build/${CMAKE_SYSTEM_NAME}")

ExternalProject_Add(Boost
      PREFIX "${THIRDPARTY_DIR}/boost"
      GIT_REPOSITORY    "https://github.com/boostorg/boost.git"
      GIT_TAG           "boost-1.72.0"
      #GIT_SUBMODULES_RECURSE  TRUE
      UPDATE_COMMAND ${CMAKE_COMMAND} -E copy ${THIRDPARTY_DIR}/build/cmake.in/boost-patch/system_category_win32.hpp ${THIRDPARTY_DIR}/boost/src/Boost/libs/system/include/boost/system/detail/system_category_win32.hpp
      PATCH_COMMAND ./bootstrap.bat ${VC_PLATFORMTOOLSET}
      CONFIGURE_COMMAND  ""
      BUILD_COMMAND ./b2.exe headers
      BUILD_IN_SOURCE  TRUE
      INSTALL_COMMAND ./b2.exe toolset=${BOOST_TOOLSET} runtime-link=static cxxflags="-fPIC ${CMAKE_CXX_FLAGS}"  --build-type=minimal --with-thread --with-program_options --with-system --with-date_time --with-regex --with-chrono --with-atomic --with-random --with-filesystem --with-log  address-model=64 architecture=x86  variant=release,debug  link=static threading=multi   --stagedir=stage/x64  --build-dir=${_BOOST_ROOT}  --prefix=${_BOOST_ROOT}   --libdir=${_BOOST_ROOT}/lib install
)
set(BOOST_LIB_CMAKE_DIR "${_BOOST_ROOT}/lib/cmake")
set(_Boost_INCLUDE_DIR "${_BOOST_ROOT}/include/boost-1_72")

set(_BOOST_CACHE_ARGS
      -Dboost_headers_DIR:PATH=${BOOST_LIB_CMAKE_DIR}/boost_headers-1.72.0
      -Dboost_random_DIR:PATH=${BOOST_LIB_CMAKE_DIR}/boost_random-1.72.0
      -Dboost_system_DIR:PATH=${BOOST_LIB_CMAKE_DIR}/boost_system-1.72.0
      -Dboost_filesystem_DIR:PATH=${BOOST_LIB_CMAKE_DIR}/boost_filesystem-1.72.0
      -Dboost_program_options_DIR:PATH=${BOOST_LIB_CMAKE_DIR}/boost_program_options-1.72.0
      -DBoost_DIR:PATH=${BOOST_LIB_CMAKE_DIR}/Boost-1.72.0
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
	GIT_REPOSITORY "https://github.com/openssl/openssl.git"
	GIT_TAG "OpenSSL_1_1_1g"
	#GIT_SUBMODULES_RECURSE TRUE
	SOURCE_DIR  "${THIRDPARTY_DIR}/openssl/src"
	CONFIGURE_COMMAND perl ./Configure ${OPENSSL_CONFIG_MODE} enable-capieng no-shared no-asm --prefix=${_openssl_BUILD_ROOT} --openssldir=${_openssl_BUILD_ROOT}
	BUILD_COMMAND nmake
	BUILD_IN_SOURCE  TRUE
	INSTALL_COMMAND nmake install
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
# Set ed25519 OS specific configurations
set(_ED25519_EDIIMPL ref10)
set(_ED25519_HASH sha3_brainhub)
set(_ED25519_RANDOM bcryptgen)

# --------------------------------------------------------
# Set config for libp2p
set(_libp2p_BUILD_EXAMPLES ON)

# --------------------------------------------------------
# Allow multiple definitions
set(FORCE_MULTILE ON)
set(MULTIPLE_OPTION /FORCE:MULTIPLE)

# --------------------------------------------------------
# build common targets
include(../CommonTargets.CMake)
