# special settings for Windows build on windows machine
# this is the common stuff for building
cmake_minimum_required(VERSION 3.15)

project(LINUX_SHARED_THIRD_PARTY)


if("${LINUX_TARGET_ARCHITECTURES}" STREQUAL "")
    set(LINUX_TARGET_ARCHITECTURES "${CMAKE_HOST_SYSTEM_PROCESSOR}")
endif("${LINUX_TARGET_ARCHITECTURES}" STREQUAL "")

	set (CPACK_PACKAGE_VERSION_MAJOR "0")
	set (CPACK_PACKAGE_VERSION_MINOR "2")
	set (CPACK_PACKAGE_VERSION_PATCH "1")
	set (CPACK_PACKAGE_VERSION_PRE_RELEASE "1")
	set (CPACK_PACKAGE_VENDOR "Genius Ventures")

	# set(CMAKE_CXX_STANDARD 17)
	# set(CMAKE_CXX_STANDARD_REQUIRED ON)
	# set(CMAKE_CXX_EXTENSIONS OFF)
	# set(CMAKE_POSITION_INDEPENDENT_CODE TRUE)

	#set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} /MT")
	#set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} /MTd")
	#include(../cmake.in/functions.cmake)

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

	set(CMAKE_CACHE_ARGS_CFLAGES_ADD
    #   -DCMAKE_CXX_FLAGS:STRING=${CMAKE_CXX_FLAGS}
    #   -DCMAKE_C_FLAGS:STRING=${CMAKE_C_FLAGS}
    #   -DCMAKE_CXX_FLAGS_RELEASE:STRING=${CMAKE_CXX_FLAGS_RELEASE}
    #   -DCMAKE_C_FLAGS_RELEASE:STRING=${CMAKE_C_FLAGS_RELEASE}
    #   -DCMAKE_CXX_FLAGS_DEBUG:STRING=${CMAKE_CXX_FLAGS_DEBUG}
    #   -DCMAKE_C_FLAGS_DEBUG:STRING=${CMAKE_C_FLAGS_DEBUG}
      -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}      
	)

	set(_CMAKE_COMMON_BUILD_PARAMS 
	#-DBoost_DIR:PATH=${Boost_DIR}
	#-DBoost_NO_SYSTEM_PATHS:BOOL=ON
   	# -DCMAKE_SYSTEM_NAME:STRING=${CMAKE_SYSTEM_NAME}
	)
	include(ExternalProject)
# Config Paths by Platforms
	set(CXX_FLAGS_FOR_P2P "")
	# set(_CXX_FLAGS_FOR_P2P "${CMAKE_CXX_FLAGS}")

# Set config path for protobuf	
	# set(_FINDPACKAGE_PROTOBUF_CONFIG_DIR "${CMAKE_CURRENT_BINARY_DIR}/protobuf/lib/cmake/protobuf")
	set(_FINDPACKAGE_PROTOBUF_CONFIG_DIR "${CMAKE_CURRENT_BINARY_DIR}/grpc/lib/cmake/protobuf")
	# set(_PROTOBUF_PROTOC_EXECUTABLE "${CMAKE_CURRENT_BINARY_DIR}/protobuf/bin/protoc")
# Set grpc config
	set(_grpc_BUILD_PARAMS
		-DCMAKE_PROGRAM_PATH:PATH=${CMAKE_CURRENT_BINARY_DIR}/protobuf/bin# :${CMAKE_CURRENT_BINARY_DIR}/grpc/src/grpc-build:${CMAKE_CURRENT_BINARY_DIR}/grpc/bin
	)
	
# Set Third party directory
	set(THIRDPARTY_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../..")

# set config for ed25519 crypto
	set(_ED25519_EDIIMPL ref10) 
	set(_ED25519_HASH sha3_brainhub) 
	set(_ED25519_RANDOM dev_urandom) 

# Set config for spdlog config path
	set(_FINDPACKAGE_SPDLOG_CONFIG_DIR "${CMAKE_CURRENT_BINARY_DIR}/spdlog/lib/spdlog/cmake")

# build boost 
	set(_BOOST_BUILD_ROOT "${THIRDPARTY_DIR}/boost/build/Linux")

	ExternalProject_Add( Boost
		PREFIX boost
		GIT_REPOSITORY    "https://github.com/boostorg/boost.git"
		GIT_TAG           "boost-1.72.0"
		GIT_SUBMODULES_RECURSE  TRUE
		GIT_SHALLOW TRUE		
		SOURCE_DIR    "${THIRDPARTY_DIR}/boost/src"	
		CONFIGURE_COMMAND  ""		
		PATCH_COMMAND <SOURCE_DIR>/bootstrap.sh
		BUILD_COMMAND <SOURCE_DIR>/b2 headers
		BUILD_IN_SOURCE  TRUE
		INSTALL_COMMAND <SOURCE_DIR>/b2 runtime-link=static link=static threading=multi  --build-type=minimal --with-thread --with-program_options --with-system --with-date_time --with-regex --with-chrono --with-atomic --with-random --with-filesystem --with-log  address-model=64 architecture=x86  variant=release   --stagedir=stage/x64  --build-dir=${_BOOST_BUILD_ROOT}  --prefix=${_BOOST_BUILD_ROOT}   --libdir=${_BOOST_BUILD_ROOT}/lib install
		UPDATE_COMMAND ""
		# DEPENDS Boost_Download
	)
	
	# set(boost_headers_DIR "${_BOOST_ROOT}/lib/cmake/boost_headers-1.72.0")
	# set(boost_random_DIR "${BOOST_ROOT}/lib/cmake/boost_random-1.72.0")
	# set(boost_system_DIR "${BOOST_ROOT}/lib/cmake/boost_system-1.72.0")
	# set(boost_filesystem_DIR "${BOOST_ROOT}/lib/cmake/boost_filesystem-1.72.0")
	# set(boost_program_options_DIR "${BOOST_ROOT}/lib/cmake/boost_program_options-1.72.0")

	set(boost_DIR "${_BOOST_BUILD_ROOT}/lib/cmake/Boost-1.72.0")
	set(_Boost_INCLUDE_DIR "${_BOOST_BUILD_ROOT}/include")

	set(_BOOST_CACHE_ARGS
		# -Dboost_headers_DIR:PATH=${boost_headers_DIR}
		# -Dboost_random_DIR:PATH=${boost_random_DIR}
		# -Dboost_system_DIR:PATH=${boost_system_DIR}
		# -Dboost_filesystem_DIR:PATH=${boost_filesystem_DIR}
		# -Dboost_program_options_DIR:PATH=${boost_program_options_DIR}
		-DBoost_DIR:PATH=${boost_DIR}
		-DBoost_USE_MULTITHREADED:BOOL=ON
		-DBoost_USE_STATIC_RUNTIME:BOOL=ON
		-DBoost_USE_STATIC_LIBS:BOOL=ON
		-DBoost_NO_SYSTEM_PATHS:BOOL=ON
		-DBoost_INCLUDE_DIR:PATH=${_Boost_INCLUDE_DIR}
	)
# build openssl
	set(_openssl_BUILD_ROOT "${THIRDPARTY_DIR}/openssl/build/Linux")
	# ExternalProject_Add(openssl_download
	# 	PREFIX "${THIRDPARTY_DIR}/openssl/download"		
	# 	GIT_REPOSITORY "https://github.com/openssl/openssl.git"
	# 	GIT_TAG "OpenSSL_1_1_1g"
	# 	GIT_SUBMODULES_RECURSE  TRUE
	# 	SOURCE_DIR "${THIRDPARTY_DIR}/openssl/src"		
	# 	CONFIGURE_COMMAND  "" 
	# 	PATCH_COMMAND ""
	# 	BUILD_COMMAND ""
	# 	BUILD_IN_SOURCE  TRUE
	# 	INSTALL_COMMAND ""
	# 	UPDATE_COMMAND ""  
	# )

	ExternalProject_Add(openssl
		PREFIX openssl
		GIT_REPOSITORY "https://github.com/openssl/openssl.git"
		GIT_TAG "OpenSSL_1_1_1g"
		GIT_SUBMODULES_RECURSE  TRUE
		# TMP_DIR  ${CMAKE_BINARY_DIR}/openssl/tmp
		# STAMP_DIR ${CMAKE_BINARY_DIR}/openssl/stamp
		SOURCE_DIR  "${THIRDPARTY_DIR}/openssl/src"
		CONFIGURE_COMMAND  <SOURCE_DIR>/config --prefix=${_openssl_BUILD_ROOT} --openssldir=${_openssl_BUILD_ROOT}
		PATCH_COMMAND ""
		BUILD_COMMAND make
		BUILD_IN_SOURCE  TRUE
		INSTALL_COMMAND make install
		UPDATE_COMMAND ""  
		# DEPENDS openssl_download
	   )
	# check openssl installed 
	# set(OPENSSL_USE_STATIC_LIBS ON)
	# set(OPENSSL_ROOT_DIR ${_openssl_BUILD_ROOT})  
	# set(OPENSSL_INCLUDE_DIR ${_openssl_BUILD_ROOT}/include)
	# set(OPENSSL_CRYPTO_LIBRARY ${_openssl_BUILD_ROOT}/lib)
	# set(OPENSSL_SSL_LIBRARY ${_openssl_BUILD_ROOT}/lib)
	# find_package(OpenSSL)
	set(_OPENSSL_CACHE_ARGS 
			-DOPENSSL_USE_STATIC_LIBS:BOOL=ON
			-DOPENSSL_ROOT_DIR:STRING=${_openssl_BUILD_ROOT}  
			-DOPENSSL_INCLUDE_DIR:PATH=${_openssl_BUILD_ROOT}/include
			-DOPENSSL_LIBRARIES:PATH=${_openssl_BUILD_ROOT}/lib
			# -DOPENSSL_CRYPTO_LIBRARY:PATH=${_openssl_BUILD_ROOT}/lib
			# -DOPENSSL_SSL_LIBRARY:PATH=${_openssl_BUILD_ROOT}/lib
		)
	set(_OPENSSL_INCLUDE_DIR ${_openssl_BUILD_ROOT}/include)
	set(_OPENSSL_target openssl)
	# if(OPENSSL_FOUND)
	# 	message("openssl package is found. include path is ${OPENSSL_INCLUDE_DIR}")
	# 	set(_OPENSSL_INCLUDE_DIR ${OPENSSL_INCLUDE_DIR})
	# 	set(_OPENSSL_CACHE_ARGS 
	# 		-DOPENSSL_USE_STATIC_LIBS:BOOL=ON
	# 		-DOPENSSL_INCLUDE_DIR:STRING=${_OPENSSL_INCLUDE_DIR}    
	# 	)
	# else()
	   
	# endif()

#find_package(Boost REQUIRED  random filesystem program_options)
#message("---BOOST ${Boost_INCLUDE_DIRS}")
# if(BOOST_INCLUDE_DIR)
# else()
# 	set(BOOST_INCLUDE_DIR "${Boost_INCLUDE_DIRS}")
# 	set(BOOST_LIBRARY_DIR "${Boost_LIBRARIES}")
# endif()
# 	message("---boost include ${BOOST_INCLUDE_DIR}")
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


