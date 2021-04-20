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

if (CMAKE_BUILD_TYPE STREQUAL Debug)
  set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} /MTd")
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /MTd")  
  set(MSVC_RUNTIME_LIBRARY_OPTION "MultiThreaded$<$<CONFIG:Debug>:Debug>")  
endif (CMAKE_BUILD_TYPE STREQUAL Debug) 

if (CMAKE_BUILD_TYPE STREQUAL "Release")
  set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} /MT")
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /MT")  
  message("-----------Release --")
  set(MSVC_RUNTIME_LIBRARY_OPTION "MultiThreaded$<$<CONFIG:Realease>:Release>")  
endif (CMAKE_BUILD_TYPE STREQUAL "Release") 

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
set(_CXX_FLAGS_FOR_P2P "${CMAKE_CXX_FLAGS}")

# set(_FINDPACKAGE_PROTOBUF_CONFIG_DIR "${CMAKE_CURRENT_BINARY_DIR}/protobuf/cmake")  
set(_FINDPACKAGE_PROTOBUF_CONFIG_DIR "${CMAKE_CURRENT_BINARY_DIR}/grpc/cmake")
# set(_PROTOBUF_PROTOC_EXECUTABLE "${CMAKE_CURRENT_BINARY_DIR}/protobuf/bin/protoc")
set(_PROTOBUF_PROTOC_EXECUTABLE "${CMAKE_CURRENT_BINARY_DIR}/grpc/bin/protoc")

set(_FORCE_MULTILE ON)

# Set Third party directory
set(THIRDPARTY_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../..")

set(_CMAKE_COMMON_BUILD_PARAMS 
   #-DCMAKE_SYSTEM_NAME:STRING=${CMAKE_SYSTEM_NAME}
)
set(CMAKE_CACHE_ARGS_CFLAGES_ADD
      -DCMAKE_CXX_FLAGS:STRING=${CMAKE_CXX_FLAGS}
      -DCMAKE_C_FLAGS:STRING=${CMAKE_C_FLAGS}
      -DCMAKE_CXX_FLAGS_RELEASE:STRING=${CMAKE_CXX_FLAGS_RELEASE}
      -DCMAKE_C_FLAGS_RELEASE:STRING=${CMAKE_C_FLAGS_RELEASE}
      -DCMAKE_CXX_FLAGS_DEBUG:STRING=${CMAKE_CXX_FLAGS_DEBUG}
      -DCMAKE_C_FLAGS_DEBUG:STRING=${CMAKE_C_FLAGS_DEBUG}
      -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}      
)

#message("----cmake cache ${CMAKE_CHCHE_ARGS_CFLAGES_ADD}")

# set config for ed25519 crypto
set(_ED25519_EDIIMPL ref10) 
set(_ED25519_HASH sha3_brainhub) 
set(_ED25519_RANDOM bcryptgen) 
# Set config for spdlog config path
set(_FINDPACKAGE_SPDLOG_CONFIG_DIR "${CMAKE_CURRENT_BINARY_DIR}/spdlog/lib/cmake/spdlog")
# set(_FINDPACKAGE_SPDLOG_CONFIG_DIR "${CMAKE_CURRENT_BINARY_DIR}/spdlog/lib/cmake/spdlog")
##find_package(Boost REQUIRED  random filesystem program_options)
##message("---include -- ${BOOST_INCLUDE_DIR}")

# build ------------boost ---------------------# 

set(_BOOST_SRC_DIR "${CMAKE_CURRENT_BINARY_DIR}/Boost/src/Boost")

set(VC_PLATFORMTOOLSET "vc141")
set(BOOST_TOOLSET "msvc-14.1")
if(MSVC_VERSION AND MSVC_VERSION GREATER_EQUAL 1920) # v142 toolset
	set(VC_PLATFORMTOOLSET "vc142")
	set(BOOST_TOOLSET "msvc-14.2")
endif()

ExternalProject_Add( Boost
      PREFIX "${THIRDPARTY_DIR}/boost"   ## --- Use thirdparty root directory, not build directory to avoid duplicate cloning ----
      GIT_REPOSITORY    "https://github.com/boostorg/boost.git"
      GIT_TAG           "boost-1.72.0"
      GIT_SUBMODULES_RECURSE  TRUE
      # SOURCE_DIR       "${THIRDPARTY_DIR}/boost/src"      
      UPDATE_COMMAND ${CMAKE_COMMAND} -E copy "${CMAKE_CURRENT_SOURCE_DIR}/../cmake.in/boost-patch/system_category_win32.hpp" <SOURCE_DIR>/libs/system/include/boost/system/detail/system_category_win32.hpp
      PATCH_COMMAND <SOURCE_DIR>/bootstrap.bat ${VC_PLATFORMTOOLSET}
      CONFIGURE_COMMAND  ""
      BUILD_COMMAND <SOURCE_DIR>/b2.exe headers
      BUILD_IN_SOURCE  TRUE
      INSTALL_COMMAND <SOURCE_DIR>/b2.exe toolset=${BOOST_TOOLSET} runtime-link=static cxxflags="${CMAKE_CXX_FLAGS}"  --build-type=minimal --with-thread --with-program_options --with-system --with-date_time --with-regex --with-chrono --with-atomic --with-random --with-filesystem --with-log  address-model=64 architecture=x86  variant=release,debug  link=static threading=multi   --stagedir=stage/x64  --build-dir=<SOURCE_DIR>/../build  --prefix=<SOURCE_DIR>/../..   --libdir=<SOURCE_DIR>/../../lib install
)
set(_BOOST_ROOT "${THIRDPARTY_DIR}/boost")
set(boost_headers_DIR "${_BOOST_ROOT}/lib/cmake/boost_headers-1.72.0")
set(boost_random_DIR "${BOOST_ROOT}/lib/cmake/boost_random-1.72.0")
set(boost_system_DIR "${BOOST_ROOT}/lib/cmake/boost_system-1.72.0")
set(boost_filesystem_DIR "${BOOST_ROOT}/lib/cmake/boost_filesystem-1.72.0")
set(boost_program_options_DIR "${BOOST_ROOT}/lib/cmake/boost_program_options-1.72.0")
set(boost_DIR "${_BOOST_ROOT}/lib/cmake/Boost-1.72.0")
set(_Boost_INCLUDE_DIR "${_BOOST_ROOT}/include/boost-1_72")

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
      #-DBoost_INCLUDE_DIR:PATH=${_BOOST_ROOT}/include/boost-1_72      
)
message("---opensssl root=${OPENSSL_ROOT_DIR}")
set(OPENSSL_MSVC_STATIC_RT  ON)
set(OPENSSL_USE_STATIC_LIBS  ON)
# OpenSSL 
find_package(OpenSSL)

if(OPENSSL_FOUND)
  message("openssl package is found. include path is ${OPENSSL_INCLUDE_DIR}")
  set(_OPENSSL_INCLUDE_DIR ${OPENSSL_INCLUDE_DIR})
  set(_OPENSSL_CACHE_ARGS 
      #-DOPENSSL_USE_STATIC_LIBS:BOOL=OFF    
      -DOPENSSL_INCLUDE_DIR:STRING=${_OPENSSL_INCLUDE_DIR}    
  )
else()
  message(FATAL_ERROR "OpenSSL is not found. Please specify OPENSSL_ROOT_DIR")
endif()

# Set config for patching binaryen 
set(_binaryen_patch
 PATCH_COMMAND ${CMAKE_COMMAND} -E copy "${CMAKE_CURRENT_SOURCE_DIR}/../cmake.in/binaryen-patch/parser.h" <SOURCE_DIR>/src/emscripten-optimizer/parser.h)

# build common libraries by platforms
  include(../CommonTargets.CMake)
  
# Build curl 7.60
# 	ExternalProject_Add(curl
# 	PREFIX curl
# 	SOURCE_DIR "${THIRDPARTY_DIR}/curl-android-ios/curl"
# 	CMAKE_CACHE_ARGS
# 		-DBUILD_TESTING:BOOL=OFF
# 	-DCMAKE_USE_OPENSSL:BOOL=ON
# 	-DCURL_STATICLIB:BOOL=ON
# 	-DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_CURRENT_BINARY_DIR}/curl
# )
endif (${CMAKE_HOST_SYSTEM_NAME} MATCHES "Windows")

