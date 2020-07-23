# special settings for Windows build on windows machine
# this is the common stuff for building
cmake_minimum_required(VERSION 3.15)

# if on Windows system, build the windows executables
if (${CMAKE_HOST_SYSTEM_NAME} MATCHES "Windows")

project(WINDOWS_SHARED_THIRD_PARTY)

set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} /MT")
set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} /MTd")
set(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE} /MT")
set(CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG} /MTd")

if (CMAKE_BUILD_TYPE EQUAL Debug)
  set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} /MTd")
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /MTd")  
  set(MSVC_RUNTIME_LIBRARY_OPTION "MultiThreaded$<$<CONFIG:Debug>:Debug>")  
endif (CMAKE_BUILD_TYPE EQUAL Debug) 

if (CMAKE_BUILD_TYPE EQUAL Release)
  set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} /MT")
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /MT")  
  set(MSVC_RUNTIME_LIBRARY_OPTION "MultiThreaded$<$<CONFIG:Realease>:Release>")  
endif (CMAKE_BUILD_TYPE EQUAL Release) 

function(print)
  message(STATUS "[${CMAKE_PROJECT_NAME}] ${ARGV}")
endfunction()

print("CMAKE_BUILD_TYPE: ${CMAKE_BUILD_TYPE}")
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

print("C flags: ${CMAKE_C_FLAGS}")
print("CXX flags: ${CMAKE_CXX_FLAGS}")
print("C Debug flags: ${CMAKE_C_FLAGS_DEBUG}")
print("CXX Debug flags: ${CMAKE_CXX_FLAGS_DEBUG}")
print("C Release flags: ${CMAKE_C_FLAGS_RELEASE}")
print("CXX Release flags: ${CMAKE_CXX_FLAGS_RELEASE}")

#include(../cmake.in/functions.cmake)	
include(ExternalProject)
	
# Config Paths by Platforms
#	set(CXX_FLAGS_FOR_P2P "${CMAKE_CXX_FLAGS}")	
#	set(Boost_USE_STATIC_LIBS ON)	
set(_FINDPACKAGE_PROTOBUF_CONFIG_DIR "${CMAKE_CURRENT_BINARY_DIR}/protobuf/cmake")  
set(_PROTOBUF_PROTOC_EXECUTABLE "${CMAKE_CURRENT_BINARY_DIR}/protobuf/bin/protoc")
set(_FORCE_MULTILE ON)

# Set Third party directory
set(THIRDPARTY_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../..")

set(CMAKE_CHCHE_ARGS_CFLAGES_ADD
      -DCMAKE_CXX_FLAGS:STRING=${CMAKE_CXX_FLAGS}
      -DCMAKE_C_FLAGS:STRING=${CMAKE_C_FLAGS}
      -DCMAKE_CXX_FLAGS_RELEASE:STRING=${CMAKE_CXX_FLAGS_RELEASE}
      -DCMAKE_C_FLAGS_RELEASE:STRING=${CMAKE_C_FLAGS_RELEASE}
      -DCMAKE_CXX_FLAGS_DEBUG:STRING=${CMAKE_CXX_FLAGS_DEBUG}
      -DCMAKE_C_FLAGS_DEBUG:STRING=${CMAKE_C_FLAGS_DEBUG}
      -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
)
# Common build by platforms
include(../CommonTargets.CMake)
  
# Build curl 7.60
	ExternalProject_Add(curl
	PREFIX curl
	SOURCE_DIR "${THIRDPARTY_DIR}/curl-android-ios/curl"
	CMAKE_CACHE_ARGS
		-DBUILD_TESTING:BOOL=OFF
		-DCMAKE_USE_OPENSSL:BOOL=ON
		-DCURL_STATICLIB:BOOL=ON
		-DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_CURRENT_BINARY_DIR}/curl
	)
endif (${CMAKE_HOST_SYSTEM_NAME} MATCHES "Windows")

