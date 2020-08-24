# special settings for Android build on windows machine
# this is the common stuff for building

cmake_minimum_required(VERSION 3.15)

project(ANDROID_SHARED_THIRD_PARTY)

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
## Config param for cxx flags
   set(CMAKE_CACHE_ARGS_CFLAGES_ADD            
      #-DCMAKE_CXX_FLAGS_RELEASE:STRING=${CMAKE_CXX_FLAGS_RELEASE}
      #-DCMAKE_CXX_FLAGS_DEBUG:STRING=${CMAKE_CXX_FLAGS_DEBUG}
      -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
	)
## Config param for android
   set(_CMAKE_COMMON_BUILD_PARAMS 
   	-DCMAKE_SYSTEM_NAME:STRING=${CMAKE_SYSTEM_NAME}
	# -DBoost_DIR:PATH=${Boost_DIR}
	# -DBoost_NO_SYSTEM_PATHS:BOOL=ON
	# -DBoost_USE_STATIC_LIBS:BOOL=ON	
	-DANDROID_ABI:STRING=${ANDROID_ABI}
	-DANDROID_NATIVE_API_LEVEL:STRING=${ANDROID_NATIVE_API_LEVEL}
	-DANDROID_TOOLCHAIN:STRING=${ANDROID_TOOLCHAIN}		
	-DANDROID_STL:STRING=c++_static
	-DCMAKE_TOOLCHAIN_FILE:PATH=${CMAKE_TOOLCHAIN_FILE}
	-DOPENSSL_USE_STATIC_LIBS:BOOL=TRUE
#	-DOPENSSL_ROOT_DIR:PATH=${OPENSSL_ROOT_DIR}
	)
	include(ExternalProject)
# Config Paths by Platforms
	set(_CXX_FLAGS_FOR_P2P " -std=c++17")
	#set(Boost_USE_STATIC_LIBS OFF)
	set(_FINDPACKAGE_PROTOBUF_CONFIG_DIR "${CMAKE_CURRENT_BINARY_DIR}/protobuf/lib/cmake/protobuf")

# Set Third party directory
	set(THIRDPARTY_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../..")

	message("--opessl ${OPENSSL_ROOT_DIR}")
	set(BOOST_VERSION2 1_72_0)
# Set boost config
# build boost 
	set(_BOOST_ROOT "${THIRDPARTY_DIR}/boost/build/Android")

	ExternalProject_Add( Boost
		PREFIX boost
		GIT_REPOSITORY    "https://github.com/boostorg/boost.git"
		GIT_TAG           "boost-1.72.0"
		GIT_SUBMODULES_RECURSE  TRUE
		GIT_SHALLOW TRUE		
		SOURCE_DIR    "${THIRDPARTY_DIR}/boost/src"	
		CONFIGURE_COMMAND  ""
		PATCH_COMMAND cp -R  ${CMAKE_CURRENT_SOURCE_DIR}/Boost-build/ ${CMAKE_CURRENT_BINARY_DIR}/boost/src  #  <SOURCE_DIR>/bootstrap.sh	
		BUILD_COMMAND  ./build.sh  "${_BOOST_ROOT}"  "${ANDROID_ABI}" "${THIRDPARTY_DIR}/boost/src"#   <SOURCE_DIR>/b2 headers
		# BUILD_IN_SOURCE  TRUE
		INSTALL_COMMAND ""   # <SOURCE_DIR>/b2 runtime-link=static link=static threading=multi  --build-type=minimal --with-thread --with-program_options --with-system --with-date_time --with-regex --with-chrono --with-atomic --with-random --with-filesystem  address-model=64 architecture=x86  variant=release   --stagedir=stage/x64  --build-dir=${_BOOST_BUILD_ROOT}  --prefix=${_BOOST_BUILD_ROOT}   --libdir=${_BOOST_BUILD_ROOT}/lib install
		UPDATE_COMMAND ""
		# WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/Boost-for-Android"
		# DEPENDS Boost_Download
	)

   set(Boost_NO_SYSTEM_PATHS  ON)
   set(Boost_USE_STATIC_LIBS  ON)
    # set(Boost_USE_STATIC_RUNTIME OFF)
    # set(Boost_USE_MULTITHREADED OFF)
   set(BOOST_ROOT ${_BOOST_ROOT})
   set(Boost_INCLUDE_DIR  ${BOOST_ROOT}/include)
#    set(BOOST_INCLUDEDIR ${Boost_INCLUDE_DIR})
   set(BOOST_LIBRARYDIR ${BOOST_ROOT}/libs/${ANDROID_ABI})
   
   #set(CMAKE_FIND_USE_PACKAGE_ROOT_PATH ON)
   #set(Boost_NO_BOOST_CMAKE  OFF)
   set(Boost_DIR "${BOOST_LIBRARYDIR}/cmake/Boost-1.72.0")
	# message("---size of  -- ${CMAKE_SIZEOF_VOID_P}")
   	set(boost_headers_DIR "${BOOST_ROOT}/libs/${ANDROID_ABI}/cmake/boost_headers-1.72.0")
	set(boost_random_DIR "${BOOST_ROOT}/libs/${ANDROID_ABI}/cmake/boost_random-1.72.0")
	set(boost_system_DIR "${BOOST_ROOT}/libs/${ANDROID_ABI}/cmake/boost_system-1.72.0")
	set(boost_filesystem_DIR "${BOOST_ROOT}/libs/${ANDROID_ABI}/cmake/boost_filesystem-1.72.0")
	set(boost_program_options_DIR "${BOOST_ROOT}/libs/${ANDROID_ABI}/cmake/boost_program_options-1.72.0")
	set(boost_date_time_DIR "${BOOST_ROOT}/libs/${ANDROID_ABI}/cmake/boost_date_time-1.72.0")
	set(boost_regex_DIR "${BOOST_ROOT}/libs/${ANDROID_ABI}/cmake/boost_regex-1.72.0")
   message("---boost dir ${Boost_USE_STATIC_RUNTIME}")
   message("---boost lib ${Boost_USE_MULTITHREADED}")
    # find_package(Boost   COMPONENTS random filesystem program_options date_time regex)

   if(BOOST_INCLUDE_DIR)
   else()
	   set(BOOST_INCLUDE_DIR "${Boost_INCLUDE_DIRS}")
	   set(BOOST_LIBRARY_DIR "${Boost_LIBRARIES}")
   endif()
   
	message("---include-  ${Boost_INCLUDE_DIR}")
	message("----- lib ${BOOST_LIBRARYDIR}")
	set(BOOST_INCLUDE_DIR ${Boost_INCLUDE_DIR})
   set(_BOOST_CACHE_ARGS   
   -DBOOST_ROOT:PATH=${BOOST_ROOT}
   -DBoost_USE_MULTITHREADED:BOOL=ON
   -DBoost_USE_STATIC_RUNTIME:BOOL=ON
   -DBoost_USE_STATIC_LIBS:BOOL=ON
   -DBoost_NO_SYSTEM_PATHS:BOOL=ON
   -DBoost_INCLUDE_DIR:PATH=${Boost_INCLUDE_DIR}
#    -DBOOST_INCLUDEDIR:PATH=${Boost_INCLUDE_DIR}
   -DBOOST_LIBRARYDIR:PATH=${BOOST_LIBRARYDIR}  
   -DBOOST_MIN_VERSION:STRING="1.70.0"
#    -DBoost_LIBRARY_DIR:PATH=${Boost_LIBRARIES}  
#    -DBoost_ADDITIONAL_VERSIONS:STRING="1.72.0"
#    -DBoost_LIBRARIES:PATH=${Boost_LIBRARIES}  
   -DBoost_DIR:PATH=${Boost_DIR}
   -Dboost_headers_DIR:PATH=${boost_headers_DIR}
   -Dboost_random_DIR:PATH=${boost_random_DIR}
   -Dboost_system_DIR:PATH=${boost_system_DIR}
   -Dboost_filesystem_DIR:PATH=${boost_filesystem_DIR}
   -Dboost_program_options_DIR:PATH=${boost_program_options_DIR}
   -Dboost_date_time_DIR:PATH=${boost_date_time_DIR}
   -Dboost_regex_DIR:PATH=${boost_regex_DIR}
)
##### Test find openssl


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
message("--- android abi is ${_abi}")
set(_openssl_BUILD_ROOT "${THIRDPARTY_DIR}/openssl/build/Android/${ANDROID_ABI}")
ExternalProject_Add(openssl
	PREFIX openssl	
	GIT_REPOSITORY "https://github.com/openssl/openssl.git"
	GIT_TAG "OpenSSL_1_1_1g"
	GIT_SUBMODULES_RECURSE  TRUE
	GIT_SHALLOW TRUE	
	SOURCE_DIR    "${THIRDPARTY_DIR}/openssl/src"	
	CONFIGURE_COMMAND  <SOURCE_DIR>/Configure ${_abi} -D__ANDROID_API__=${ANDROID_NATIVE_API_LEVEL} --prefix=${_openssl_BUILD_ROOT} --openssldir=${_openssl_BUILD_ROOT}
	PATCH_COMMAND ""
	BUILD_COMMAND make
	BUILD_IN_SOURCE  TRUE
	INSTALL_COMMAND make install
	UPDATE_COMMAND ""  
)

# set(OPENSSL_USE_STATIC_LIBS  ON)
set(_OPENSSL_INCLUDE_DIR ${THIRDPARTY_DIR}/openssl/build/Android/${ANDROID_ABI}/include)
set(_OPENSSL_CACHE_ARGS 
	-DOPENSSL_USE_STATIC_LIBS:BOOL=ON
	-DOPENSSL_ROOT_DIR:PATH=${THIRDPARTY_DIR}/openssl/build/Android/${ANDROID_ABI}  
	-DOPENSSL_INCLUDE_DIR:PATH=${_OPENSSL_INCLUDE_DIR}
	-DOPENSSL_CRYPTO_LIBRARY:PATH=${THIRDPARTY_DIR}/openssl/build/Android/${ANDROID_ABI}/lib
	-DOPENSSL_SSL_LIBRARY:PATH=${THIRDPARTY_DIR}/openssl/build/Android/${ANDROID_ABI}/lib
)

set(_OPENSSL_target openssl)
#-----------------------------#

#message("---${OPENSSL_INCLUDE_DIR}")


# Set config for grpc
  set(_grpc_BUILD_PARAMS
	-Dprotobuf_BUILD_PROTOC_BINARIES:BOOL=OFF
	)
# set config for ed25519 crypto
	set(_ED25519_EDIIMPL ref10) 
	set(_ED25519_HASH sha3_brainhub) 
	set(_ED25519_RANDOM dev_urandom) 

# Common build by platforms

include(CommonTargetsForAndroid.CMake)


#message("${boost_random_DIR}")

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
   


