# special settings for Windows build on windows machine
# this is the common stuff for building
cmake_minimum_required(VERSION 3.15)

project(OSX_SHARED_THIRD_PARTY)


if (${CMAKE_HOST_SYSTEM_NAME} MATCHES "Darwin")

	set (CPACK_PACKAGE_VERSION_MAJOR "0")
	set (CPACK_PACKAGE_VERSION_MINOR "2")
	set (CPACK_PACKAGE_VERSION_PATCH "1")
	set (CPACK_PACKAGE_VERSION_PRE_RELEASE "1")
	set (CPACK_PACKAGE_VENDOR "Genius Ventures")

	set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} /MT")
	set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} /MTd")
	set(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE} /MT")
	set(CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG} /MTd")

	if (CMAKE_BUILD_TYPE EQUAL Debug)
	  set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} /MTd")
	  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /MTd")
	endif (CMAKE_BUILD_TYPE EQUAL Debug) 

	if (CMAKE_BUILD_TYPE EQUAL Release)
	  set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} /MT")
	  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /MT")
	endif (CMAKE_BUILD_TYPE EQUAL Release) 
	
	set(CompilerFlags
			CMAKE_CXX_FLAGS
			CMAKE_CXX_FLAGS_DEBUG
			CMAKE_CXX_FLAGS_RELEASE
			CMAKE_C_FLAGS
			CMAKE_C_FLAGS_DEBUG
			CMAKE_C_FLAGS_RELEASE
			)
	foreach(CompilerFlag ${CompilerFlags})
	  string(REPLACE "/MD" "/MT" ${CompilerFlag} "${${CompilerFlag}}")
	endforeach()

	set(CMAKE_CHCHE_ARGS_CFLAGES_ADD            
      #-DCMAKE_CXX_FLAGS_RELEASE:STRING=${CMAKE_CXX_FLAGS_RELEASE}
      #-DCMAKE_CXX_FLAGS_DEBUG:STRING=${CMAKE_CXX_FLAGS_DEBUG}
      -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
	)
	set(_CMAKE_COMMON_BUILD_PARAMS 
	-DBoost_DIR:PATH=${Boost_DIR}
	-DBoost_NO_SYSTEM_PATHS:BOOL=ON
	-DBoost_USE_STATIC_LIBS:BOOL=ON	
   	-DCMAKE_SYSTEM_NAME:STRING=${CMAKE_SYSTEM_NAME}
	)
	include(ExternalProject)
# Config Paths by Platforms
	set(CXX_FLAGS_FOR_P2P "")
	#set(Boost_USE_STATIC_LIBS OFF)
	set(_FINDPACKAGE_PROTOBUF_CONFIG_DIR "${CMAKE_CURRENT_BINARY_DIR}/protobuf/lib/cmake/protobuf")

# Set Third party directory
	set(THIRDPARTY_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../..")

# set config for ed25519 crypto
	set(_ED25519_EDIIMPL ref10) 
	set(_ED25519_HASH sha3_brainhub) 
	set(_ED25519_RANDOM dev_urandom) 

# Set config for spdlog config path
set(_FINDPACKAGE_SPDLOG_CONFIG_DIR "${CMAKE_CURRENT_BINARY_DIR}/spdlog/lib/cmake/spdlog")

# find_package(Boost REQUIRED  random filesystem program_options)
#message("---BOOST ${Boost_INCLUDE_DIRS}")
# if(BOOST_INCLUDE_DIR)
# else()
# 	set(BOOST_INCLUDE_DIR "${Boost_INCLUDE_DIRS}")
# 	set(BOOST_LIBRARY_DIR "${Boost_LIBRARIES}")
# endif()
# 	message("---boost include ${BOOST_INCLUDE_DIR}")
# 	message("-cmake system name ${CMAKE_SYSTEM_NAME}")
# build boost 
if(CMAKE_SIZEOF_VOID_P EQUAL 4)
	set(address_model 32)
else()
	set(address_model 64)
endif()

ExternalProject_Add( Boost
	PREFIX  "${THIRDPARTY_DIR}/boost"  
	GIT_REPOSITORY    "https://github.com/boostorg/boost.git"
	GIT_TAG           "boost-1.72.0"
	GIT_SUBMODULES_RECURSE  TRUE
	# SOURCE_DIR    "${THIRDPARTY_DIR}/boost/src"
	CONFIGURE_COMMAND  ""
	PATCH_COMMAND <SOURCE_DIR>/bootstrap.sh
	BUILD_COMMAND <SOURCE_DIR>/b2 headers
	BUILD_IN_SOURCE  TRUE
	INSTALL_COMMAND <SOURCE_DIR>/b2 cxxflags=-std=c++17 runtime-link=static link=static threading=multi  --build-type=minimal --with-thread --with-program_options --with-system --with-date_time --with-regex --with-chrono --with-atomic --with-random --with-filesystem  address-model=${address_model} architecture=x86  variant=release   --stagedir=stage/x64  --build-dir=<SOURCE_DIR>/../../build/OSX/  --prefix=<SOURCE_DIR>/../../build/OSX/   --libdir=<SOURCE_DIR>/../../build/OSX/lib  install
	UPDATE_COMMAND ""
)
set(_BOOST_ROOT "${THIRDPARTY_DIR}/boost/build/OSX")
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
# build OpenSSL 
ExternalProject_Add(openssl
PREFIX "${THIRDPARTY_DIR}/openssl"
#URL   https://github.com/openssl/openssl/archive/OpenSSL_1_1_1g.tar.gz
GIT_REPOSITORY "https://github.com/openssl/openssl.git"
GIT_TAG "OpenSSL_1_1_1g"
GIT_SUBMODULES_RECURSE  TRUE
# DOWNLOAD_DIR  "${THIRDPARTY_DIR}/openssl/download"
# SOURCE_DIR    "${THIRDPARTY_DIR}/openssl/src"
CONFIGURE_COMMAND  <SOURCE_DIR>/config --prefix=<SOURCE_DIR>/../../build/OSX --openssldir=<SOURCE_DIR>/../../build/OSX
PATCH_COMMAND ""
BUILD_COMMAND make
BUILD_IN_SOURCE  TRUE
INSTALL_COMMAND make install
UPDATE_COMMAND ""  
)
set(OPENSSL_USE_STATIC_LIBS  ON)
# find_package(OpenSSL)
set(_OPENSSL_CACHE_ARGS 
	-DOPENSSL_USE_STATIC_LIBS:BOOL=ON
	-DOPENSSL_ROOT_DIR:STRING=${THIRDPARTY_DIR}/openssl/build/OSX  
)
set(_OPENSSL_INCLUDE_DIR ${THIRDPARTY_DIR}/openssl/build/OSX/include)
set(_OPENSSL_target openssl)
# Common build by platforms
include(../CommonTargets.CMake)
# Build curl 7.60
	# ExternalProject_Add(curl
	# PREFIX curl
	# SOURCE_DIR "${THIRDPARTY_DIR}/curl-android-ios/curl"
	# CMAKE_CACHE_ARGS
	# 	-DBUILD_TESTING:BOOL=OFF
	# 	-DCMAKE_USE_OPENSSL:BOOL=ON
	# 	-DCURL_STATICLIB:BOOL=ON
	# 	-DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_CURRENT_BINARY_DIR}/curl
	# )

endif()
