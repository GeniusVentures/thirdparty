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

	SET(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -arch armv7")
 	SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -arch armv7")
	
	set(CMAKE_CHCHE_ARGS_CFLAGES_ADD            
      #-DCMAKE_CXX_FLAGS_RELEASE:STRING=${CMAKE_CXX_FLAGS_RELEASE}
	  #-DCMAKE_CXX_FLAGS_DEBUG:STRING=${CMAKE_CXX_FLAGS_DEBUG}
	  -DCMAKE_C_FLAGS:STRING=${CMAKE_C_FLAGS}
	  -DCMAKE_CXX_FLAGS:STRING=${CMAKE_CXX_FLAGS}
	  -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
	  -DCMAKE_SYSTEM_NAME:STRING=${CMAKE_SYSTEM_NAME}
	)
	set(_CMAKE_COMMON_BUILD_PARAMS 
	-DBoost_DIR:PATH=${Boost_DIR}
	-DBoost_NO_SYSTEM_PATHS:BOOL=ON
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
find_package(Boost REQUIRED  random filesystem program_options)
#message("---BOOST ${Boost_INCLUDE_DIRS}")
if(BOOST_INCLUDE_DIR)
else()
	set(BOOST_INCLUDE_DIR "${Boost_INCLUDE_DIRS}")
	set(BOOST_LIBRARY_DIR "${Boost_LIBRARIES}")
endif()
	message("---boost include ${BOOST_INCLUDE_DIR}")
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
