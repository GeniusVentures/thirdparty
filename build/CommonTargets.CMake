
# Set Third party directory
set(THIRDPARTY_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../..")

set(JSON_FOR_MODERN_CXX_INCLUDE_DIR "${THIRDPARTY_DIR}/json")

# Find json library
find_path(JSON_FOR_MODERN_CXX_INCLUDE_DIR NAMES nlohmann/json.hpp)
include_directories(${JSON_FOR_MODERN_CXX_INCLUDE_DIR})
mark_as_advanced(JSON_FOR_MODERN_CXX_INCLUDE_DIR)

set(PROTOBUF_ROOT_DIR "${THIRDPARTY_DIR}/grpc/third_party/protobuf")
set(PROTOBUF_SRC_DIR "${PROTOBUF_ROOT_DIR}/cmake")


# Builds Microsoft.GSL
ExternalProject_Add(GSL
  PREFIX GSL
  SOURCE_DIR "${THIRDPARTY_DIR}/GSL"
  CMAKE_CACHE_ARGS
        -DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_CURRENT_BINARY_DIR}/GSL
        -DGSL_TEST:BOOL=OFF
)
set(_FINDPACKAGE_GSL_INCLUDE_DIR "${CMAKE_CURRENT_BINARY_DIR}/GSL/include")


# Builds GTest project from the git submodule.
ExternalProject_Add(GTest
  PREFIX GTest
  SOURCE_DIR "${THIRDPARTY_DIR}/GTest"  
  CMAKE_CACHE_ARGS                
        -DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_CURRENT_BINARY_DIR}/GTest
)

set(GTest_DIR "${CMAKE_CURRENT_BINARY_DIR}/GTest/lib/cmake/GTest")

# Build protobuf project from the git submodule.
ExternalProject_Add(protobuf
  PREFIX protobuf
  SOURCE_DIR "${PROTOBUF_SRC_DIR}"
  CMAKE_CACHE_ARGS
        -Dprotobuf_BUILD_TESTS:BOOL=OFF
        -Dprotobuf_WITH_ZLIB:BOOL=OFF
        -Dprotobuf_MSVC_STATIC_RUNTIME:BOOL=OFF
        -DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_CURRENT_BINARY_DIR}/protobuf
)

# The location where protobuf-config.cmake will be installed varies by platform
if (WIN32)
set(_FINDPACKAGE_PROTOBUF_CONFIG_DIR "${CMAKE_CURRENT_BINARY_DIR}/protobuf/cmake")
else()
set(_FINDPACKAGE_PROTOBUF_CONFIG_DIR "${CMAKE_CURRENT_BINARY_DIR}/protobuf/lib/cmake/protobuf")
endif()
set(_FINDPACKAGE_PROTOBUF_INCLUDE_DIR "${CMAKE_CURRENT_BINARY_DIR}/protobuf/include")
set(_FINDPACKAGE_PROTOBUF_LIB_DIR "${CMAKE_CURRENT_BINARY_DIR}/protobuf/lib")


# If OPENSSL_ROOT_DIR is set, propagate that hint path to the external projects with OpenSSL dependency.
set(_CMAKE_ARGS_OPENSSL_ROOT_DIR "")
if (OPENSSL_ROOT_DIR)
  set(_CMAKE_ARGS_OPENSSL_ROOT_DIR "-DOPENSSL_ROOT_DIR:PATH=${OPENSSL_ROOT_DIR}")
  set(OPENSSL_INCLUDE_DIR, "${OPENSSL_ROOT_DIR}/include")
endif()

# Builds spdlog v1.4.2
ExternalProject_Add(spdlog
  PREFIX spdlog
  SOURCE_DIR "${THIRDPARTY_DIR}/spdlog"
  CMAKE_CACHE_ARGS
        -DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_CURRENT_BINARY_DIR}/spdlog
)
set(_FINDPACKAGE_SPDLOG_CONFIG_DIR "${CMAKE_CURRENT_BINARY_DIR}/spdlog/lib/spdlog/cmake")
set(_FINDPACKAGE_SPDLOG_INCLUDE_DIR "${CMAKE_CURRENT_BINARY_DIR}/spdlog/include")

# Builds tsl_hat_trie 343e0dac54fc8491065e8a059a02db9a2b1248ab
ExternalProject_Add(tsl_hat_trie
  PREFIX tsl_hat_trie
  SOURCE_DIR "${THIRDPARTY_DIR}/hat-trie"
  CMAKE_CACHE_ARGS
        -DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_CURRENT_BINARY_DIR}/hat-trie
)
set(_FINDPACKAGE_TSL_HAT_TRIE_CONFIG_DIR "${CMAKE_CURRENT_BINARY_DIR}/hat-trie/lib/cmake/tsl_hat_trie")

#set(CMAKE_PREFIX_PATH "${CMAKE_PREFIX_PATH} ${CMAKE_CURRENT_BINARY_DIR}/hat-trie/lib/cmake/tsl_hat_trie")
#message("${CMAKE_PREFIX_PATH}")

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

# BOOST library 
#set(Boost_USE_STATIC_LIBS ON)   #This parameter is at config file for each platform 
set(Boost_USE_MULTITHREADED ON)  
set(Boost_USE_STATIC_RUNTIME OFF) 
if(NOT Boost_USE_STATIC_LIBS)
  find_package(Boost REQUIRED COMPONENTS date_time filesystem random program_options) # header only libraries must not be added here
endif()

#OpenSSL library
set(CMAKE_USE_OPENSSL ON)
if(CMAKE_USE_OPENSSL)
  find_package(OpenSSL REQUIRED)
  set(SSL_ENABLED ON)
  set(USE_OPENSSL ON)
endif()

#set(tsl_hat_trie_DIR "${_FINDPACKAGE_TSL_HAT_TRIE_CONFIG_DIR}")
#find_package(tsl_hat_trie  REQUIRED)

# Builds libp2p
#message(${CMAKE_CXX_FLAGS})
ExternalProject_Add(libp2p
  PREFIX libp2p
  SOURCE_DIR "${THIRDPARTY_DIR}/libp2p"  
  CMAKE_CACHE_ARGS
        ${_CMAKE_ARGS_OPENSSL_ROOT_DIR}
        -DCMAKE_USE_OPENSSL:BOOL=ON
        -DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_CURRENT_BINARY_DIR}/libp2p
        -DTESTING:BOOL=OFF 
        -DBUILD_EXAMPLES:BOOL=OFF
        -DBUILD_TESTING:BOOL=OFF
        -DEXPOSE_MOCKS:BOOL=ON
        -DHUNTER_ENABLED:BOOL=OFF        
        -DProtobuf_DIR:PATH=${_FINDPACKAGE_PROTOBUF_CONFIG_DIR}
        -DProtobuf_INCLUDE_DIR:PATH=${_FINDPACKAGE_PROTOBUF_INCLUDE_DIR}
        -DProtobuf_LIBRARIES:PATH=${_FINDPACKAGE_PROTOBUF_LIB_DIR}
        -Dspdlog_DIR:PATH=${_FINDPACKAGE_SPDLOG_CONFIG_DIR}
        -DBoost.DI_DIR:PATH=${_FINDPACKAGE_BOOST_DI_CONFIG_DIR}
        -DBoost_ROOT:PATH=${BOOST_ROOT}
        -DBoost_INCLUDE_DIR:PATH=${BOOST_INCLUDE_DIR}
        -DBoost_LIBRARY_DIR:PATH=${BOOST_LIBRARY_DIR}
        -Dtsl_hat_trie_DIR:PATH=${_FINDPACKAGE_TSL_HAT_TRIE_CONFIG_DIR}
        -DGSL_ROOT:PATH=${CMAKE_CURRENT_BINARY_DIR}/GSL
        -DGSL_DIR:PATH=${CMAKE_CURRENT_BINARY_DIR}/GSL
        -DGSL_INCLUDE_DIR:PATH=${_FINDPACKAGE_GSL_INCLUDE_DIR}    
        -DCMAKE_FIND_USE_PACKAGE_ROOT_PATH:BOOL=ON
        -DCLANG_TIDY:BOOL=OFF
        -DGTest_DIR:PATH=${GTest_DIR}
        -DGMock_DIR:PATH=${GTest_DIR}
        -DCMAKE_CXX_FLAGS:STRING=-I\ ${BOOST_INCLUDE_DIR}\ -I\ ${_FINDPACKAGE_GSL_INCLUDE_DIR}\ -I\ ${_FINDPACKAGE_TSL_HAT_TRIE_CONFIG_DIR}\ -I\ ${_FINDPACKAGE_SPDLOG_INCLUDE_DIR}\ -I\ \\\"${OPENSSL_INCLUDE_DIR}\\\"\ -I\ ${_FINDPACKAGE_PROTOBUF_INCLUDE_DIR}\ ${CXX_FLAGS_FOR_P2P} 

  DEPENDS protobuf spdlog tsl_hat_trie Boost.DI GSL
)

# Builds absl project from the git submodule.
ExternalProject_Add(absl
  PREFIX absl
  SOURCE_DIR "${THIRDPARTY_DIR}/grpc/third_party/abseil-cpp"
  CMAKE_CACHE_ARGS
        -DCMAKE_POSITION_INDEPENDENT_CODE:BOOL=TRUE
        -DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_CURRENT_BINARY_DIR}/absl
)

# Builds c-ares project from the git submodule.
ExternalProject_Add(c-ares
  PREFIX c-ares
  SOURCE_DIR "${THIRDPARTY_DIR}/grpc/third_party/cares/cares"
  CMAKE_CACHE_ARGS
        -DCARES_SHARED:BOOL=OFF
        -DCARES_STATIC:BOOL=ON
        -DCARES_STATIC_PIC:BOOL=ON
        -DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_CURRENT_BINARY_DIR}/c-ares
)



# Builds zlib project from the git submodule.
ExternalProject_Add(zlib
  PREFIX zlib
  SOURCE_DIR "${THIRDPARTY_DIR}/grpc/third_party/zlib"
  CMAKE_CACHE_ARGS
        -DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_CURRENT_BINARY_DIR}/zlib
)

# Builds gRPC based on locally checked-out sources and set arguments so that all the dependencies
# are correctly located.
ExternalProject_Add(grpc
  PREFIX grpc
  SOURCE_DIR "${THIRDPARTY_DIR}/grpc"
  CMAKE_CACHE_ARGS
        -DgRPC_INSTALL:BOOL=ON
        -DgRPC_BUILD_TESTS:BOOL=OFF
        -DgRPC_PROTOBUF_PROVIDER:STRING=package
        -DgRPC_PROTOBUF_PACKAGE_TYPE:STRING=CONFIG
        -DProtobuf_DIR:PATH=${_FINDPACKAGE_PROTOBUF_CONFIG_DIR}
        -DgRPC_ZLIB_PROVIDER:STRING=package
        -DZLIB_ROOT:STRING=${CMAKE_CURRENT_BINARY_DIR}/zlib
        -DgRPC_ABSL_PROVIDER:STRING=package
        -Dabsl_DIR:STRING=${CMAKE_CURRENT_BINARY_DIR}/absl/lib/cmake/absl
        -DgRPC_CARES_PROVIDER:STRING=package
        -Dc-ares_DIR:PATH=${CMAKE_CURRENT_BINARY_DIR}/c-ares/lib/cmake/c-ares
        -DgRPC_SSL_PROVIDER:STRING=package
        ${_CMAKE_ARGS_OPENSSL_ROOT_DIR}
        -DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_CURRENT_BINARY_DIR}/grpc
  DEPENDS c-ares protobuf zlib absl
)



