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
   set(CMAKE_CHCHE_ARGS_CFLAGES_ADD            
      #-DCMAKE_CXX_FLAGS_RELEASE:STRING=${CMAKE_CXX_FLAGS_RELEASE}
      #-DCMAKE_CXX_FLAGS_DEBUG:STRING=${CMAKE_CXX_FLAGS_DEBUG}
      -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
	)
## Config param for android
   set(_CMAKE_COMMON_BUILD_PARAMS 
   	-DCMAKE_SYSTEM_NAME:STRING=${CMAKE_SYSTEM_NAME}
	-DBoost_DIR:PATH=${Boost_DIR}
	-DBoost_NO_SYSTEM_PATHS:BOOL=ON
	-DBoost_USE_STATIC_LIBS:BOOL=ON	
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
# Set boost config
   set(Boost_NO_SYSTEM_PATHS  ON)
   #set(CMAKE_FIND_USE_PACKAGE_ROOT_PATH ON)
   #set(Boost_NO_BOOST_CMAKE  OFF)
   #set(Boost_DIR "${BOOST_LIBRARY_DIR}/cmake/Boost-1.72.0")
	message("---size of  -- ${CMAKE_SIZEOF_VOID_P}")
   	set(boost_headers_DIR "${BOOST_ROOT}/libs/${ANDROID_ABI}/cmake/boost_headers-1.72.0")
	set(boost_random_DIR "${BOOST_ROOT}/libs/${ANDROID_ABI}/cmake/boost_random-1.72.0")
	set(boost_system_DIR "${BOOST_ROOT}/libs/${ANDROID_ABI}/cmake/boost_system-1.72.0")
	set(boost_filesystem_DIR "${BOOST_ROOT}/libs/${ANDROID_ABI}/cmake/boost_filesystem-1.72.0")
	set(boost_program_options_DIR "${BOOST_ROOT}/libs/${ANDROID_ABI}/cmake/boost_program_options-1.72.0")
   #message("${boost_random_DIR}")
   find_package(Boost  REQUIRED COMPONENTS random filesystem program_options)
##### Test find openssl
	
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


#message("---${OPENSSL_INCLUDE_DIR}")
	if(BOOST_INCLUDE_DIR)
	else()
		set(BOOST_INCLUDE_DIR "${Boost_INCLUDE_DIRS}")
		set(BOOST_LIBRARY_DIR "${Boost_LIBRARIES}")
	endif()

# Set config for grpc
  set(_grpc_BUILD_PARAMS
	-Dprotobuf_BUILD_PROTOC_BINARIES:BOOL=OFF
	)
# set config for ed25519 crypto
	set(_ED25519_EDIIMPL ref10) 
	set(_ED25519_HASH sha3_brainhub) 
	set(_ED25519_RANDOM dev_urandom) 

# Common build by platforms
	#include(../CommonTargets.CMake)
# Build grpc

find_program(MAKE_EXE NAMES gmake nmake make)

##message("--grpc source dir ${CMAKE_CURRENT_SOURCE_DIR}grpc/src/grpc-build")

ExternalProject_Add(grpc
  PREFIX grpc
  SOURCE_DIR "${THIRDPARTY_DIR}/grpc"
  CMAKE_CACHE_ARGS
	-DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_CURRENT_BINARY_DIR}/grpc
        -DgRPC_INSTALL:BOOL=OFF
        ${_CMAKE_ARGS_OPENSSL_ROOT_DIR}	
        -DgRPC_BUILD_TESTS:BOOL=OFF
	-DgRPC_BUILD_GRPC_PYTHON_PLUGIN:BOOL=OFF
	-DgRPC_BUILD_GRPC_RUBY_PLUGIN:BOOL=OFF
	-DgRPC_BUILD_GRPC_PHP_PLUGIN:BOOL=OFF
	-DgRPC_BUILD_GRPC_OBJECTIVE_C_PLUGIN:BOOL=OFF
	-DgRPC_BUILD_GRPC_NODE_PLUGIN:BOOL=OFF	
	-DgRPC_BUILD_GRPC_CSHARP_PLUGIN:BOOL=OFF
	-DgRPC_BUILD_GRPC_CPP_PLUGIN:BOOL=OFF
	-DgRPC_BUILD_CSHARP_EXT:BOOL=OFF
        -DgRPC_BUILD_CODEGEN:BOOL=OFF
	${_CMAKE_COMMON_BUILD_PARAMS}
	${_grpc_BUILD_PARAMS}
  BUILD_COMMAND     ${MAKE_EXE} grpc++
  COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_CURRENT_BINARY_DIR}/grpc/lib
  COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_CURRENT_BINARY_DIR}/grpc/include
  COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_BINARY_DIR}/grpc/src/grpc-build/libgrpc.a ${CMAKE_CURRENT_BINARY_DIR}/grpc/src/grpc-build/libgrpc++.a ${CMAKE_CURRENT_BINARY_DIR}/grpc/src/grpc-build/libgpr.a ${CMAKE_CURRENT_BINARY_DIR}/grpc/src/grpc-build/libaddress_sorting.a ${CMAKE_CURRENT_BINARY_DIR}/grpc/src/grpc-build/libupb.a  ${CMAKE_CURRENT_BINARY_DIR}/grpc/lib  
  COMMAND ${CMAKE_COMMAND} -E copy_directory ${THIRDPARTY_DIR}/grpc/include ${CMAKE_CURRENT_BINARY_DIR}/grpc/include
  INSTALL_COMMAND ""
)

#message("${THIRDPARTY_DIR}")
# Set Protobug library path
set(PROTOBUF_ROOT_DIR "${THIRDPARTY_DIR}/grpc/third_party/protobuf")
set(PROTOBUF_SRC_DIR "${PROTOBUF_ROOT_DIR}/cmake")


# Builds GTest project from the git submodule.
ExternalProject_Add(GTest
  PREFIX GTest
  SOURCE_DIR "${THIRDPARTY_DIR}/GTest"  
  CMAKE_CACHE_ARGS                
        -DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_CURRENT_BINARY_DIR}/GTest
)

set(_FINDPACKAGE_GTEST_CONFIG_DIR "${CMAKE_CURRENT_BINARY_DIR}/GTest/lib/cmake/GTest")


# Build protobuf project from the git submodule.
ExternalProject_Add(protobuf
  PREFIX protobuf
  SOURCE_DIR "${PROTOBUF_SRC_DIR}"
  CMAKE_CACHE_ARGS
        -Dprotobuf_BUILD_TESTS:BOOL=OFF
        -Dprotobuf_WITH_ZLIB:BOOL=OFF
        -Dprotobuf_MSVC_STATIC_RUNTIME:BOOL=OFF
        -DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_CURRENT_BINARY_DIR}/protobuf
	-Dprotobuf_BUILD_PROTOC_BINARIES:BOOL=OFF
        ${CMAKE_CHCHE_ARGS_CFLAGES_ADD}
	${_CMAKE_COMMON_BUILD_PARAMS}
)

# The location where protobuf-config.cmake will be installed varies by platform
set(Protobuf_DIR "${_FINDPACKAGE_PROTOBUF_CONFIG_DIR}")
set(_FINDPACKAGE_PROTOBUF_INCLUDE_DIR "${CMAKE_CURRENT_BINARY_DIR}/protobuf/include")
set(_FINDPACKAGE_PROTOBUF_LIB_DIR "${CMAKE_CURRENT_BINARY_DIR}/protobuf/lib")
set(_PROTOBUF_PROTOC_EXEC "${CMAKE_CURRENT_BINARY_DIR}/protobuf/bin/protoc")


# Builds leveldb
ExternalProject_Add(leveldb
  PREFIX leveldb
  SOURCE_DIR "${THIRDPARTY_DIR}/leveldb"
  CMAKE_CACHE_ARGS
        -DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_CURRENT_BINARY_DIR}/leveldb
        ${CMAKE_CHCHE_ARGS_CFLAGES_ADD}
        ${_CMAKE_COMMON_BUILD_PARAMS}
)
set(_FINDPACKAGE_LEVELDB_DIR "${CMAKE_CURRENT_BINARY_DIR}/leveldb/lib/cmake/leveldb")
set(_FINDPACKAGE_LEVELDB_INCLUDE_DIR "${CMAKE_CURRENT_BINARY_DIR}/leveldb/include")

# Builds Microsoft.GSL
ExternalProject_Add(Microsoft.GSL
  PREFIX Microsoft.GSL
  SOURCE_DIR "${THIRDPARTY_DIR}/GSL"
  CMAKE_CACHE_ARGS
        -DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_CURRENT_BINARY_DIR}/GSL
        -DGSL_TEST:BOOL=OFF
)
set(_FINDPACKAGE_GSL_INCLUDE_DIR "${CMAKE_CURRENT_BINARY_DIR}/GSL/include")
# Builds spdlog v1.4.2
ExternalProject_Add(spdlog
  PREFIX spdlog
  SOURCE_DIR "${THIRDPARTY_DIR}/spdlog"
  CMAKE_CACHE_ARGS
        -DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_CURRENT_BINARY_DIR}/spdlog
        # -DSPDLOG_FMT_EXTERNAL:BOOL=ON
	-DSPDLOG_BUILD_EXAMPLE:BOOL=OFF
        ${CMAKE_CHCHE_ARGS_CFLAGES_ADD}
	${_CMAKE_COMMON_BUILD_PARAMS}
)

set(_FINDPACKAGE_SPDLOG_CONFIG_DIR "${CMAKE_CURRENT_BINARY_DIR}/spdlog/lib/cmake/spdlog")
set(_FINDPACKAGE_SPDLOG_INCLUDE_DIR "${CMAKE_CURRENT_BINARY_DIR}/spdlog/include")

# Builds tsl_hat_trie 343e0dac54fc8491065e8a059a02db9a2b1248ab
ExternalProject_Add(tsl_hat_trie
  PREFIX tsl_hat_trie
  SOURCE_DIR "${THIRDPARTY_DIR}/hat-trie"
  CMAKE_CACHE_ARGS
        -DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_CURRENT_BINARY_DIR}/hat-trie
)
set(_FINDPACKAGE_TSL_HAT_TRIE_CONFIG_DIR "${CMAKE_CURRENT_BINARY_DIR}/hat-trie/lib/cmake/tsl_hat_trie")
set(_FINDPACKAGE_TSL_HAT_TRIE_INCLUDE_DIR "${CMAKE_CURRENT_BINARY_DIR}/hat-trie/include")
# Builds Boost.DI c5287ee710ad90f5286d0cc2b9e49b72d89267a6
ExternalProject_Add(Boost.DI
  PREFIX Boost.DI
  SOURCE_DIR "${THIRDPARTY_DIR}/Boost.DI"
  CMAKE_CACHE_ARGS
        -DBOOST_DI_OPT_BUILD_TESTS:BOOL=OFF
        -DBOOST_DI_OPT_BUILD_EXAMPLES:BOOL=OFF
        -DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_CURRENT_BINARY_DIR}/Boost.DI
)
set(_FINDPACKAGE_BOOST_DI_CONFIG_DIR "${CMAKE_CURRENT_BINARY_DIR}/Boost.DI/lib/cmake/Boost.DI")
set(_FINDPACKAGE_BOOST_DI_INCLUDE_DIR "${CMAKE_CURRENT_BINARY_DIR}/Boost.DI/include")


# Builds libp2p

ExternalProject_Add(libp2p
  PREFIX libp2p
  SOURCE_DIR "${THIRDPARTY_DIR}/libp2p"
  CMAKE_CACHE_ARGS
        ${_CMAKE_ARGS_OPENSSL_ROOT_DIR}
        -DGTest_DIR:PATH=${_FINDPACKAGE_GTEST_CONFIG_DIR}
        -DCMAKE_USE_OPENSSL:BOOL=ON
        -DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_CURRENT_BINARY_DIR}/libp2p
        -DTESTING:BOOL=OFF 
        -DEXPOSE_MOCKS:BOOL=ON
        -DHUNTER_ENABLED:BOOL=OFF
        -DBUILD_EXAMPLES:BOOL=OFF
        -DProtobuf_DIR:PATH=${_FINDPACKAGE_PROTOBUF_CONFIG_DIR}
        -DProtobuf_INCLUDE_DIR:PATH=${_FINDPACKAGE_PROTOBUF_INCLUDE_DIR}
        -DProtobuf_LIBRARIES:PATH=${_FINDPACKAGE_PROTOBUF_LIB_DIR}
        -DProtobuf_PROTOC_EXECUTABLE:PATH=${_PROTOBUF_PROTOC_EXEC}
        -Dspdlog_DIR:PATH=${_FINDPACKAGE_SPDLOG_CONFIG_DIR}
        -Dtsl_hat_trie_DIR:PATH=${_FINDPACKAGE_TSL_HAT_TRIE_CONFIG_DIR}
        -DBoost.DI_DIR:PATH=${_FINDPACKAGE_BOOST_DI_CONFIG_DIR}
        -DBOOST_ROOT:PATH=${BOOST_ROOT}
        -DBOOST_INCLUDE_DIR:PATH=${BOOST_INCLUDE_DIR}
        -DBOOST_LIBRARY_DIR:PATH=${BOOST_LIBRARY_DIR}
        -DBoost_LIB_DIR_STR:STRING="${BOOST_LIBRARY_DIR}"
        -Dboost_headers_DIR:PATH=${boost_headers_DIR}
	-Dboost_random_DIR:PATH=${boost_random_DIR}
	-Dboost_system_DIR:PATH=${boost_system_DIR}
	-Dboost_filesystem_DIR:PATH=${boost_filesystem_DIR}
	-Dboost_program_options_DIR:PATH=${boost_program_options_DIR}
	${_CMAKE_COMMON_BUILD_PARAMS}
        -DOPENSSL_CRYPTO_LIBRARY:PATH=${OPENSSL_CRYPTO_LIBRARY}
	-DOPENSSL_SSL_LIBRARY:PATH=${OPENSSL_CRYPTO_LIBRARY}
        -DOPENSSL_INCLUDE_DIR:STRING=${OPENSSL_ROOT_DIR}/include
     	-DOPENSSL_LIBRARIES:PATH=${OPENSSL_LIBRARIES}
#        -DCMAKE_FIND_USE_PACKAGE_ROOT_PATH:BOOL=ON
        -DBoost_NO_SYSTEM_PATHS:BOOL=ON
#        -DCLANG_FORMAT:BOOL=OFF
#	-DCLANG_TIDY:BOOL=OFF
        ${CMAKE_CHCHE_ARGS_CFLAGES_ADD}            
        -DCMAKE_CXX_FLAGS:STRING=-I\ ${BOOST_INCLUDE_DIR}\ -I\ ${_FINDPACKAGE_GSL_INCLUDE_DIR}\ -I\ ${_FINDPACKAGE_SPDLOG_INCLUDE_DIR}\ -I\ \\\"${OPENSSL_INCLUDE_DIR}\\\"\ -I\ ${_FINDPACKAGE_PROTOBUF_INCLUDE_DIR}\ -I\ ${_FINDPACKAGE_TSL_HAT_TRIE_INCLUDE_DIR}\ -I\ ${_FINDPACKAGE_BOOST_DI_INCLUDE_DIR}\ ${_CXX_FLAGS_FOR_P2P}
        -DFORCE_MULTILE:BOOL=${_FORCE_MULTILE}
        ${_CMAKE_COMMON_BUILD_PARAMS}
#	-DBoost_ARCHITECTURE:STRING="-x64"

  DEPENDS GTest protobuf spdlog tsl_hat_trie Boost.DI Microsoft.GSL
)

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
   


