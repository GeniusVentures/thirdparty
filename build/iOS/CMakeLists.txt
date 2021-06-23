# special settings for Windows build on windows machine
# this is the common stuff for building
cmake_minimum_required(VERSION 3.15)

if(POLICY CMP0025)
	#NEW: report OS X version of Clang as "AppleClang"
  cmake_policy(SET CMP0025 NEW)
endif()
if(POLICY CMP0042)
  #NEW: set TARGET PROPERTY MACOSX_RPATH to on by default
  cmake_policy(SET CMP0042 NEW)
endif()

project(iOS_SHARED_THIRD_PARTY)


message("---${CMAKE_HOST_SYSTEM_NAME}")

if (${CMAKE_HOST_SYSTEM_NAME} MATCHES "Darwin")

	set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM "BOTH")

	set (CPACK_PACKAGE_VERSION_MAJOR "0")
	set (CPACK_PACKAGE_VERSION_MINOR "2")
	set (CPACK_PACKAGE_VERSION_PATCH "1")
	set (CPACK_PACKAGE_VERSION_PRE_RELEASE "1")
	set (CPACK_PACKAGE_VENDOR "Genius Ventures")

	set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

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
 	  #-DCMAKE_C_FLAGS:STRING=${CMAKE_C_FLAGS}
 	  #-DCMAKE_CXX_FLAGS:STRING=${CMAKE_CXX_FLAGS}
	)
	set(CMAKE_SYSTEM_NAME "iOS")
	set(_CMAKE_COMMON_BUILD_PARAMS
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
	#	-DCMAKE_SYSTEM_PROCESSOR:STRING=${CMAKE_SYSTEM_PROCESSOR}
	)
	include(ExternalProject)
# Config Paths by Platforms
	set(_CXX_FLAGS_FOR_P2P " -std=c++17")
	#set(Boost_USE_STATIC_LIBS OFF)
	set(_FINDPACKAGE_PROTOBUF_CONFIG_DIR "${CMAKE_CURRENT_BINARY_DIR}/protobuf/lib/cmake/protobuf")

# Set Third party directory
	set(THIRDPARTY_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../..")

# Config for Boost
set(Boost_NO_SYSTEM_PATHS  ON)
set(Boost_USE_STATIC_LIBS ON)

# build boost
if(CMAKE_SIZEOF_VOID_P EQUAL 4)
	set(address_model 32)
else()
	set(address_model 64)
endif()
set(BOOST_ROOT "${THIRDPARTY_DIR}/boost/build/iOS/${iOS_ABI}")

ExternalProject_Add( Boost
	PREFIX  "${THIRDPARTY_DIR}/boost"
	SOURCE_DIR    "${THIRDPARTY_DIR}/boost/src"
	BINARY_DIR    "${THIRDPARTY_DIR}/boost"
	CONFIGURE_COMMAND  ""
	PATCH_COMMAND ${CMAKE_COMMAND} -E copy_directory  ${CMAKE_CURRENT_SOURCE_DIR}/Boost-build ${THIRDPARTY_DIR}/boost
	BUILD_COMMAND ./build.sh -ios --boost-version 1.72.0 --build-dir ${BOOST_ROOT}
	INSTALL_COMMAND ""
	UPDATE_COMMAND ""
)

message("---boost dir ${Boost_DIR}")
set(boost_headers_DIR "${BOOST_ROOT}/lib/cmake/boost_headers-1.72.0")
set(boost_random_DIR "${BOOST_ROOT}/lib/cmake/boost_random-1.72.0")
set(boost_system_DIR "${BOOST_ROOT}/lib/cmake/boost_system-1.72.0")
set(boost_filesystem_DIR "${BOOST_ROOT}/lib/cmake/boost_filesystem-1.72.0")
set(boost_program_options_DIR "${BOOST_ROOT}/lib/cmake/boost_program_options-1.72.0")
set(BOOST_INCLUDE_DIR ${BOOST_ROOT}/include)
set(_BOOST_CACHE_ARGS
	-DBOOST_ROOT:PATH=${BOOST_ROOT}
	-Dboost_headers_DIR:PATH=${boost_headers_DIR}
	-Dboost_random_DIR:PATH=${boost_random_DIR}
	-Dboost_system_DIR:PATH=${boost_system_DIR}
	-Dboost_filesystem_DIR:PATH=${boost_filesystem_DIR}
	-Dboost_program_options_DIR:PATH=${boost_program_options_DIR}
	-DBoost_DIR:PATH=${Boost_DIR}
	-DBoost_USE_MULTITHREADED:BOOL=ON
	-DBoost_USE_STATIC_RUNTIME:BOOL=OFF
	-DBoost_USE_STATIC_LIBS:BOOL=ON
	-DBoost_NO_SYSTEM_PATHS:BOOL=ON
	-DBoost_INCLUDE_DIR:PATH=${BOOST_INCLUDE_DIR}
)

# build OpenSSL
ExternalProject_Add(openssl
	PREFIX "${THIRDPARTY_DIR}/openssl"
	SOURCE_DIR    "${THIRDPARTY_DIR}/openssl/src"
	BINARY_DIR    "${THIRDPARTY_DIR}/openssl"
	CONFIGURE_COMMAND  ""
	PATCH_COMMAND ${CMAKE_COMMAND} -E copy_directory  ${CMAKE_CURRENT_SOURCE_DIR}/Openssl-build ${THIRDPARTY_DIR}/openssl
	BUILD_COMMAND ./build-libssl.sh --version=1.1.1g --targets=ios64-cross-arm64 --build-dir=${THIRDPARTY_DIR}/openssl/build/iOS/${iOS_ABI}
	INSTALL_COMMAND ""
	UPDATE_COMMAND ""
)

set(_OPENSSL_INCLUDE_DIR ${THIRDPARTY_DIR}/openssl/build/iOS/${iOS_ABI}/include)
set(_OPENSSL_target openssl)

set(OPENSSL_USE_STATIC_LIBS  ON)
# find_package(OpenSSL)
set(_OPENSSL_CACHE_ARGS
	-DOPENSSL_USE_STATIC_LIBS:BOOL=ON
	-DOPENSSL_ROOT_DIR:STRING=${THIRDPARTY_DIR}/openssl/build/iOS/${iOS_ABI}
	-DOPENSSL_INCLUDE_DIR:PATH=${_OPENSSL_INCLUDE_DIR}
	-DOPENSSL_CRYPTO_LIBRARY:PATH=${THIRDPARTY_DIR}/openssl/build/iOS/${iOS_ABI}/lib
	-DOPENSSL_SSL_LIBRARY:PATH=${THIRDPARTY_DIR}/openssl/build/iOS/${iOS_ABI}/lib
)

set(_grpc_SSL_PARAM
		-DgRPC_SSL_PROVIDER:STRING=package
		${_OPENSSL_CACHE_ARGS}
	    -DgRPC_BUILD_GRPC_PYTHON_PLUGIN:BOOL=OFF
        -DgRPC_BUILD_GRPC_RUBY_PLUGIN:BOOL=OFF
        -DgRPC_BUILD_GRPC_PHP_PLUGIN:BOOL=OFF
        -DgRPC_BUILD_GRPC_OBJECTIVE_C_PLUGIN:BOOL=OFF
        -DgRPC_BUILD_GRPC_NODE_PLUGIN:BOOL=OFF
        -DgRPC_BUILD_GRPC_CSHARP_PLUGIN:BOOL=OFF
)

# set config for ed25519 crypto
set(_ED25519_EDIIMPL ref10)
set(_ED25519_HASH sha3_brainhub)
set(_ED25519_RANDOM dev_urandom)
message("----target platform IOS=${IOS}")
# Common build by platforms
	include(CommonTargetsForiOS.CMake)

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
