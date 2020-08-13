# special settings for Windows build on windows machine
# this is the common stuff for building
cmake_minimum_required(VERSION 3.15)

project(iOS_SHARED_THIRD_PARTY)

message("---${CMAKE_HOST_SYSTEM_NAME}")

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

	SET(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -arch ${IOS_ARCH}")
 	SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -arch ${IOS_ARCH}")
	
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
		-DENABLE_BITCODE:STRING=${ENABLED_BITCODE}
		-DENABLE_VISIBILITY:STRING=${ENABLED_VISIBILITY}
		-DCMAKE_OSX_ARCHITECTURES:STRING=${CMAKE_OSX_ARCHITECTURES}
		-DIOS_SDK_VERSION:STRING=${IOS_SDK_VERSION}
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
message("---boost dir ${Boost_DIR}")
set(boost_headers_DIR "${BOOST_ROOT}/lib/release/${iOS_ABI}/cmake/boost_headers-1.72.0")
set(boost_random_DIR "${BOOST_ROOT}/lib/release/${iOS_ABI}/cmake/boost_random-1.72.0")
set(boost_system_DIR "${BOOST_ROOT}/lib/release/${iOS_ABI}/cmake/boost_system-1.72.0")
set(boost_filesystem_DIR "${BOOST_ROOT}/lib/release/${iOS_ABI}/cmake/boost_filesystem-1.72.0")
set(boost_program_options_DIR "${BOOST_ROOT}/lib/release/${iOS_ABI}/cmake/boost_program_options-1.72.0")

find_package(Boost REQUIRED  random filesystem program_options)
#message("---BOOST ${Boost_INCLUDE_DIRS}")
if(BOOST_INCLUDE_DIR)
else()
	set(BOOST_INCLUDE_DIR "${Boost_INCLUDE_DIRS}")
	set(BOOST_LIBRARY_DIR "${Boost_LIBRARIES}")
endif()
	message("---boost include ${BOOST_INCLUDE_DIR}")


# If OPENSSL_ROOT_DIR is set, propagate that hint path to the external projects with OpenSSL dependency.
	set(_CMAKE_ARGS_OPENSSL_ROOT_DIR "")
     
	message("${OPENSSL_ROOT_DIR}---")
	string(COMPARE NOTEQUAL "${OPENSSL_ROOT_DIR}" "" not_empty)
        set(OPENSSL)
	if (OPENSSL_ROOT_DIR)
	  message("openssl root dir is set.")
	  set(_CMAKE_ARGS_OPENSSL_ROOT_DIR "-DOPENSSL_ROOT_DIR:PATH=${OPENSSL_ROOT_DIR}")
	  set(OPENSSL_INCLUDE_DIR  "${OPENSSL_ROOT_DIR}/include")
	else()
	  message("openssl root dir is not set.")
	endif()
	SET(OPENSSL_CRYPTO_LIBRARY "${OPENSSL_ROOT_DIR}/lib")
	
    set(OPENSSL_USE_STATIC_LIBS TRUE)
	#SET(OPENSSL_LIBRARIES )
	find_package(OpenSSL REQUIRED)

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
