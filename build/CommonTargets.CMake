# --------------------------------------------------------
# Find json library
set(JSON_FOR_MODERN_CXX_INCLUDE_DIR "${THIRDPARTY_DIR}/json")
find_path(JSON_FOR_MODERN_CXX_INCLUDE_DIR NAMES nlohmann/json.hpp)
include_directories(${JSON_FOR_MODERN_CXX_INCLUDE_DIR})
mark_as_advanced(JSON_FOR_MODERN_CXX_INCLUDE_DIR)

# --------------------------------------------------------
# Set config for spdlog config path
set(_FINDPACKAGE_SPDLOG_CONFIG_DIR "${CMAKE_CURRENT_BINARY_DIR}/spdlog/lib/cmake/spdlog")

# --------------------------------------------------------
# Builds GTest project from the git submodule.
ExternalProject_Add(GTest
  PREFIX GTest
  SOURCE_DIR "${THIRDPARTY_DIR}/GTest"
  CMAKE_CACHE_ARGS
        -DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_CURRENT_BINARY_DIR}/GTest
        -DCMAKE_CXX_STANDARD:STRING=17
        ${_CMAKE_COMMON_BUILD_PARAMS}
)
set(_FINDPACKAGE_GTEST_CONFIG_DIR "${CMAKE_CURRENT_BINARY_DIR}/GTest/lib/cmake/GTest")

# --------------------------------------------------------
# Set Protobuf library path
if (NOT DEFINED _PROTOBUF_CONFIG_DIR)
    set(_PROTOBUF_CONFIG_DIR "${CMAKE_CURRENT_BINARY_DIR}/grpc/lib/cmake/protobuf")
endif()
set(_FINDPACKAGE_PROTOBUF_CONFIG_DIR "${_PROTOBUF_CONFIG_DIR}")
print("PROTOBUF_CONFIG_DIR: ${_FINDPACKAGE_PROTOBUF_CONFIG_DIR}")

if (NOT DEFINED _PROTOBUF_INCLUDE_DIR)
    set(_PROTOBUF_INCLUDE_DIR "${CMAKE_CURRENT_BINARY_DIR}/grpc/include")
endif()
set(_FINDPACKAGE_PROTOBUF_INCLUDE_DIR "${_PROTOBUF_INCLUDE_DIR}")
print("PROTOBUF_INCLUDE_DIR: ${_FINDPACKAGE_PROTOBUF_INCLUDE_DIR}")

if (NOT DEFINED _PROTOBUF_LIB_DIR)
    set(_PROTOBUF_LIB_DIR "${CMAKE_CURRENT_BINARY_DIR}/grpc/lib")
endif()
set(_FINDPACKAGE_PROTOBUF_LIB_DIR "${_PROTOBUF_LIB_DIR}")
print("PROTOBUF_LIB_DIR: ${_FINDPACKAGE_PROTOBUF_LIB_DIR}")

if (NOT DEFINED PROTOC_EXECUTABLE)
    set(PROTOC_EXECUTABLE "${CMAKE_CURRENT_BINARY_DIR}/grpc/bin/protoc${CMAKE_EXECUTABLE_SUFFIX}")
endif()
set(_PROTOBUF_PROTOC_EXEC "${PROTOC_EXECUTABLE}")
print("PROTOBUF_PROTOC_EXECUTABLE: ${_PROTOBUF_PROTOC_EXEC}")

ExternalProject_Add(grpc
  PREFIX grpc
  BINARY_DIR "${CMAKE_CURRENT_BINARY_DIR}/grpc/build"
  SOURCE_DIR "${THIRDPARTY_DIR}/grpc"
  CMAKE_ARGS
        -DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_CURRENT_BINARY_DIR}/grpc
  CMAKE_CACHE_ARGS
        -DgRPC_INSTALL:BOOL=ON
        -DgRPC_BUILD_TESTS:BOOL=OFF
        -DABSL_ENABLE_INSTALL:BOOL=ON
        -DgRPC_SSL_PROVIDER:STRING=package
        ${_OPENSSL_CACHE_ARGS}
        ${_CMAKE_COMMON_BUILD_PARAMS}
        ${_grpc_EXTRA_PARAM}
  ${grpc_patch}
  DEPENDS openssl # protobuf # zlib absl
)

# --------------------------------------------------------
# Builds rocksdb
ExternalProject_Add(rocksdb
  PREFIX rocksdb
  SOURCE_DIR "${THIRDPARTY_DIR}/rocksdb"
  CMAKE_CACHE_ARGS
        -DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_CURRENT_BINARY_DIR}/rocksdb
        -DROCKSDB_BUILD_SHARED:BOOL=OFF
        -DWITH_ALL_TESTS:BOOL=OFF
        -DWITH_TESTS:BOOL=OFF
        -DWITH_TOOLS:BOOL=OFF
        -DWITH_CORE_TOOLS:BOOL=OFF
        -DWITH_BENCHMARK_TOOLS:BOOL=OFF
        -DWITH_RUNTIME_DEBUG:BOOL=ON
        -DWITH_MD_LIBRARY:BOOL=OFF
        -DROCKSDB_INSTALL_ON_WINDOWS:BOOL=ON
        -DWITH_GFLAGS:BOOL=OFF
        -DPORTABLE:BOOL=ON
        -DWITH_GFLAGS:BOOL=OFF
        -DFAIL_ON_WARNINGS:BOOL=OFF
        ${_rocksdb_EXTRA_PARAM}
        ${_CMAKE_COMMON_BUILD_PARAMS}
)
set(_FINDPACKAGE_ROCKSDB_DIR "${CMAKE_CURRENT_BINARY_DIR}/rocksdb/lib/cmake/rocksdb")
set(_FINDPACKAGE_ROCKSDB_INCLUDE_DIR "${CMAKE_CURRENT_BINARY_DIR}/rocksdb/include")

# --------------------------------------------------------
# Builds Microsoft.GSL
ExternalProject_Add(Microsoft.GSL
  PREFIX Microsoft.GSL
  SOURCE_DIR "${THIRDPARTY_DIR}/GSL"
  CMAKE_CACHE_ARGS
        -DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_CURRENT_BINARY_DIR}/GSL
        -DGSL_TEST:BOOL=OFF
        ${_CMAKE_COMMON_BUILD_PARAMS}
)
set(_FINDPACKAGE_GSL_INCLUDE_DIR "${CMAKE_CURRENT_BINARY_DIR}/GSL/include")

# --------------------------------------------------------
ExternalProject_Add(fmt
  PREFIX fmt
  SOURCE_DIR "${THIRDPARTY_DIR}/fmt"
  CMAKE_CACHE_ARGS
        -DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_CURRENT_BINARY_DIR}/fmt
        ${_CMAKE_COMMON_BUILD_PARAMS}
        -DFORCE_MULTILE:BOOL=${_FORCE_MULTILE}
        -DBUILD_SHARED_LIBS:BOOL=OFF
        -DFMT_TEST:BOOL=OFF
)

set(_FINDPACKAGE_FMT_CONFIG_DIR "${CMAKE_CURRENT_BINARY_DIR}/fmt/lib/cmake/fmt")
set(_FINDPACKAGE_FMT_LIBRARY_DIR "${CMAKE_CURRENT_BINARY_DIR}/fmt/lib")
set(_FINDPACKAGE_FMT_INCLUDE_DIR "${CMAKE_CURRENT_BINARY_DIR}/fmt/include")

# --------------------------------------------------------
# Builds spdlog v1.4.2
ExternalProject_Add(spdlog
  PREFIX spdlog
  SOURCE_DIR "${THIRDPARTY_DIR}/spdlog"
  CMAKE_CACHE_ARGS
        -DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_CURRENT_BINARY_DIR}/spdlog
        -DSPDLOG_BUILD_EXAMPLE:BOOL=OFF
        -DSPDLOG_FMT_EXTERNAL:BOOL=ON
        -Dfmt_DIR:PATH=${_FINDPACKAGE_FMT_CONFIG_DIR}
        ${_CMAKE_COMMON_BUILD_PARAMS}
  DEPENDS fmt
)
set(_FINDPACKAGE_SPDLOG_INCLUDE_DIR "${CMAKE_CURRENT_BINARY_DIR}/spdlog/include")
set(_FINDPACKAGE_SPDLOG_CONFIG_DIR "${CMAKE_CURRENT_BINARY_DIR}/spdlog/lib/cmake/spdlog")

# --------------------------------------------------------
# Builds tsl_hat_trie
ExternalProject_Add(tsl_hat_trie
  PREFIX tsl_hat_trie
  SOURCE_DIR "${THIRDPARTY_DIR}/hat-trie"
  CMAKE_CACHE_ARGS
        -DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_CURRENT_BINARY_DIR}/hat-trie
        ${_tsl_hat_trie_patch}
)
set(_FINDPACKAGE_TSL_HAT_TRIE_CONFIG_DIR "${CMAKE_CURRENT_BINARY_DIR}/hat-trie/lib/cmake/tsl_hat_trie")
set(_FINDPACKAGE_TSL_HAT_TRIE_INCLUDE_DIR "${CMAKE_CURRENT_BINARY_DIR}/hat-trie/include")

# --------------------------------------------------------
# Builds Boost.DI
ExternalProject_Add(Boost.DI
  PREFIX Boost.DI
  SOURCE_DIR "${THIRDPARTY_DIR}/Boost.DI"
  CMAKE_CACHE_ARGS
        -DBOOST_DI_OPT_BUILD_TESTS:BOOL=OFF
        -DBOOST_DI_OPT_BUILD_EXAMPLES:BOOL=OFF
        -DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_CURRENT_BINARY_DIR}/Boost.DI
        ${_CMAKE_COMMON_BUILD_PARAMS}
)
set(_FINDPACKAGE_BOOST_DI_CONFIG_DIR "${CMAKE_CURRENT_BINARY_DIR}/Boost.DI/lib/cmake/Boost.DI")
set(_FINDPACKAGE_BOOST_DI_INCLUDE_DIR "${CMAKE_CURRENT_BINARY_DIR}/Boost.DI/include")


# --------------------------------------------------------
## Builds delta-enabled-crdts
#ExternalProject_Add(delta-enabled-crdts
#  PREFIX delta-enabled-crdts
#  SOURCE_DIR "${THIRDPARTY_DIR}/delta-enabled-crdts"
#  CMAKE_CACHE_ARGS
#        -DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_CURRENT_BINARY_DIR}/delta-enabled-crdts
#        -DELTACRDTS_BUILD_TESTS:BOOL=ON
#        -DELTACRDTS_INSTALL:BOOL=ON
#  PATCH_COMMAND ${CMAKE_COMMAND} -E copy
#        "${PROJECT_BUILD_FOLDER}/cmake.in/delta-enabled-crdts-patch/CMakeLists.txt" <SOURCE_DIR>/CMakeLists.txt
#)

#set(_FINDPACKAGE_DELTA_ENABLED_CRDTS_INCLUDE_DIR "${CMAKE_CURRENT_BINARY_DIR}/delta-enabled-crdts/include")

ExternalProject_Add(yaml-cpp
  PREFIX yaml-cpp
  SOURCE_DIR "${THIRDPARTY_DIR}/yaml-cpp"
  CMAKE_CACHE_ARGS
        -DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_CURRENT_BINARY_DIR}/yaml-cpp
        -DBUILD_SHARED_LIBS:BOOL=OFF
        -DYAML_BUILD_SHARED_LIBS:BOOL=OFF
        -DYAML_MSVC_SHARED_RT:BOOL=OFF
        ${_CMAKE_COMMON_BUILD_PARAMS}
)

set(_FINDPACKAGE_YAMLCPP_CONFIG_DIR "${CMAKE_CURRENT_BINARY_DIR}/yaml-cpp/share/cmake/yaml-cpp")
set(_FINDPACKAGE_YAMLCPP_LIBRARY_DIR "${CMAKE_CURRENT_BINARY_DIR}/yaml-cpp/lib")
set(_FINDPACKAGE_YAMLCPP_INCLUDE_DIR "${CMAKE_CURRENT_BINARY_DIR}/yaml-cpp/include")

ExternalProject_Add(cares
  PREFIX cares
  SOURCE_DIR "${THIRDPARTY_DIR}/c-ares"
  CMAKE_CACHE_ARGS
        -DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_CURRENT_BINARY_DIR}/cares
        -DCARES_STATIC:BOOL=ON
        -DCARES_SHARED:BOOL=OFF
        ${_CMAKE_COMMON_BUILD_PARAMS}
)

set(_FINDPACKAGE_CARES_CONFIG_DIR "${CMAKE_CURRENT_BINARY_DIR}/cares/lib/cmake/c-ares")
set(_FINDPACKAGE_CARES_LIBRARY_DIR "${CMAKE_CURRENT_BINARY_DIR}/cares/lib")
set(_FINDPACKAGE_CARES_INCLUDE_DIR "${CMAKE_CURRENT_BINARY_DIR}/cares/include")

ExternalProject_Add(soralog
  PREFIX soralog
  SOURCE_DIR "${THIRDPARTY_DIR}/soralog"
  CMAKE_CACHE_ARGS
        -DHUNTER_ENABLED:BOOL=OFF
        -DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_CURRENT_BINARY_DIR}/soralog
        -DEXAMPLES:BOOL=OFF
        -DTESTING:BOOL=OFF
        -Dyaml-cpp_DIR:PATH=${_FINDPACKAGE_YAMLCPP_CONFIG_DIR}
        -Dfmt_DIR:PATH=${_FINDPACKAGE_FMT_CONFIG_DIR}
        ${_CMAKE_COMMON_BUILD_PARAMS}
        -DCMAKE_CXX_STANDARD:STRING=17
  DEPENDS fmt yaml-cpp
)

set(_FINDPACKAGE_SORALOG_CONFIG_DIR "${CMAKE_CURRENT_BINARY_DIR}/soralog/lib/cmake/soralog")
set(_FINDPACKAGE_SORALOG_LIBRARY_DIR "${CMAKE_CURRENT_BINARY_DIR}/soralog/lib")
set(_FINDPACKAGE_SORALOG_INCLUDE_DIR "${CMAKE_CURRENT_BINARY_DIR}/soralog/include")

ExternalProject_Add(sqlite3
  PREFIX sqlite3
  SOURCE_DIR "${THIRDPARTY_DIR}/sqlite3"
  CMAKE_CACHE_ARGS
        -DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_CURRENT_BINARY_DIR}/sqlite3
        ${_CMAKE_COMMON_BUILD_PARAMS}
)

set(_FINDPACKAGE_SQLITE3_CONFIG_DIR "${CMAKE_CURRENT_BINARY_DIR}/sqlite3/lib/cmake/sqlite3")
set(_FINDPACKAGE_SQLITE3_LIBRARY_DIR "${CMAKE_CURRENT_BINARY_DIR}/sqlite3/lib")
set(_FINDPACKAGE_SQLITE3_INCLUDE_DIR "${CMAKE_CURRENT_BINARY_DIR}/sqlite3/include")

ExternalProject_Add(SQLiteModernCpp
  PREFIX SQLiteModernCpp
  SOURCE_DIR "${THIRDPARTY_DIR}/libp2p-sqlite-modern-cpp"
  CMAKE_CACHE_ARGS
        -DHUNTER_ENABLED:BOOL=OFF
        -DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_CURRENT_BINARY_DIR}/SQLiteModernCpp
        -Dsqlite3_DIR:PATH=${_FINDPACKAGE_SQLITE3_CONFIG_DIR}
        ${_CMAKE_COMMON_BUILD_PARAMS}
  DEPENDS sqlite3
)

set(_FINDPACKAGE_SQLITECPP_CONFIG_DIR "${CMAKE_CURRENT_BINARY_DIR}/SQLiteModernCpp/lib/cmake/SQLiteModernCpp")
set(_FINDPACKAGE_SQLITECPP_LIBRARY_DIR "${CMAKE_CURRENT_BINARY_DIR}/SQLiteModernCpp/lib")
set(_FINDPACKAGE_SQLITECPP_INCLUDE_DIR "${CMAKE_CURRENT_BINARY_DIR}/SQLiteModernCpp/include")

# --------------------------------------------------------
# Builds libp2p
ExternalProject_Add(libp2p
  PREFIX libp2p
  SOURCE_DIR "${THIRDPARTY_DIR}/libp2p"
  CMAKE_CACHE_ARGS
        -DGTest_DIR:PATH=${_FINDPACKAGE_GTEST_CONFIG_DIR}
        -DCMAKE_USE_OPENSSL:BOOL=ON
        -DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_CURRENT_BINARY_DIR}/libp2p
        -DTESTING:BOOL=OFF
        -DEXPOSE_MOCKS:BOOL=ON
        -DHUNTER_ENABLED:BOOL=OFF
        -DBUILD_EXAMPLES:BOOL=${_libp2p_BUILD_EXAMPLES}
        -DCMAKE_FIND_USE_PACKAGE_ROOT_PATH:BOOL=ON
        -DBoost_NO_SYSTEM_PATHS:BOOL=ON
        -DProtobuf_DIR:PATH=${_FINDPACKAGE_PROTOBUF_CONFIG_DIR}
        -DProtobuf_INCLUDE_DIR:PATH=${_FINDPACKAGE_PROTOBUF_INCLUDE_DIR}
        -DProtobuf_LIBRARIES:PATH=${_FINDPACKAGE_PROTOBUF_LIB_DIR}
        -DProtobuf_PROTOC_EXECUTABLE:PATH=${_PROTOBUF_PROTOC_EXEC}
        -Dspdlog_DIR:PATH=${_FINDPACKAGE_SPDLOG_CONFIG_DIR}
        -Dtsl_hat_trie_DIR:PATH=${_FINDPACKAGE_TSL_HAT_TRIE_CONFIG_DIR}
        -DBoost.DI_DIR:PATH=${_FINDPACKAGE_BOOST_DI_CONFIG_DIR}
        -Dc-ares_DIR:PATH=${_FINDPACKAGE_CARES_CONFIG_DIR}
        -Dfmt_DIR:PATH=${_FINDPACKAGE_FMT_CONFIG_DIR}
        -Dyaml-cpp_DIR:PATH=${_FINDPACKAGE_YAMLCPP_CONFIG_DIR}
        -Dsoralog_DIR:PATH=${_FINDPACKAGE_SORALOG_CONFIG_DIR}
        -DSQLiteModernCpp_DIR:PATH=${_FINDPACKAGE_SQLITECPP_CONFIG_DIR}
        -Dsqlite3_DIR:PATH=${_FINDPACKAGE_SQLITE3_CONFIG_DIR}
        ${_BOOST_CACHE_ARGS}
        ${_OPENSSL_CACHE_ARGS}
        ${_CMAKE_COMMON_BUILD_PARAMS}
        -DCMAKE_CXX_FLAGS:STRING=${CMAKE_CXX_FLAGS}\ -Wno-error=deprecated-declarations\ -I\ ${_Boost_INCLUDE_DIR}\ -I\ ${_FINDPACKAGE_GSL_INCLUDE_DIR}\ -I\ ${_FINDPACKAGE_SPDLOG_INCLUDE_DIR}\ -I\ ${_OPENSSL_INCLUDE_DIR}\ -I\ ${_FINDPACKAGE_PROTOBUF_INCLUDE_DIR}\ -I\ ${_FINDPACKAGE_TSL_HAT_TRIE_INCLUDE_DIR}\ -I\ ${_FINDPACKAGE_BOOST_DI_INCLUDE_DIR}\ -I\ ${_FINDPACKAGE_CARES_INCLUDE_DIR}\ -I\ ${_FINDPACKAGE_FMT_INCLUDE_DIR}\ -I\ ${_FINDPACKAGE_YAMLCPP_INCLUDE_DIR}\ -I\ ${_FINDPACKAGE_SORALOG_INCLUDE_DIR}\ -I\ ${_FINDPACKAGE_SQLITECPP_INCLUDE_DIR}\ -I\ ${_FINDPACKAGE_SQLITE3_INCLUDE_DIR}
        -DFORCE_MULTILE:BOOL=${_FORCE_MULTILE}
        -DMULTIPLE_OPTION:STRING=${MULTIPLE_OPTION}
        -DCMAKE_CXX_STANDARD:STRING=17
  DEPENDS GTest grpc ${_PROTOBUF_TARGET} spdlog tsl_hat_trie Boost.DI Microsoft.GSL Boost openssl cares fmt yaml-cpp soralog
)
set(_FINDPACKAGE_libp2p_CONFIG_DIR "${CMAKE_CURRENT_BINARY_DIR}/libp2p/lib/cmake/libp2p")
set(_FINDPACKAGE_libp2p_LIBRARY_DIR "${CMAKE_CURRENT_BINARY_DIR}/libp2p/lib")
set(_FINDPACKAGE_LIBP2P_INCLUDE_DIR "${CMAKE_CURRENT_BINARY_DIR}/libp2p/include")

# --------------------------------------------------------
# builds ipfs-lite-cpp
ExternalProject_Add(ipfs-lite-cpp
  PREFIX ipfs-lite-cpp
  SOURCE_DIR "${THIRDPARTY_DIR}/ipfs-lite-cpp"
  CMAKE_CACHE_ARGS
        -DGTest_DIR:PATH=${_FINDPACKAGE_GTEST_CONFIG_DIR}
        -DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_CURRENT_BINARY_DIR}/ipfs-lite-cpp
        -Dspdlog_DIR:PATH=${_FINDPACKAGE_SPDLOG_CONFIG_DIR}
        -Dtsl_hat_trie_DIR:PATH=${_FINDPACKAGE_TSL_HAT_TRIE_CONFIG_DIR}
        -Dlibp2p_DIR:PATH=${_FINDPACKAGE_libp2p_CONFIG_DIR}
        -DProtobuf_DIR:PATH=${_FINDPACKAGE_PROTOBUF_CONFIG_DIR}
        -DProtobuf_INCLUDE_DIR:PATH=${_FINDPACKAGE_PROTOBUF_INCLUDE_DIR}
        -DProtobuf_LIBRARIES:PATH=${_FINDPACKAGE_PROTOBUF_LIB_DIR}
        -DProtobuf_PROTOC_EXECUTABLE:PATH=${_PROTOBUF_PROTOC_EXEC}
        -DRocksDB_DIR:PATH=${_FINDPACKAGE_ROCKSDB_DIR}
        -Dc-ares_DIR:PATH=${_FINDPACKAGE_CARES_CONFIG_DIR}
        -Dfmt_DIR:PATH=${_FINDPACKAGE_FMT_CONFIG_DIR}
        -Dsoralog_DIR:PATH=${_FINDPACKAGE_SORALOG_CONFIG_DIR}
        -Dyaml-cpp_DIR:PATH=${_FINDPACKAGE_YAMLCPP_CONFIG_DIR}
        -DTESTING:BOOL=${TESTING}
        ${_CMAKE_COMMON_BUILD_PARAMS}
        ${_BOOST_CACHE_ARGS}
        ${_OPENSSL_CACHE_ARGS}
        -DCMAKE_CXX_STANDARD:STRING=17
        -DCMAKE_CXX_FLAGS:STRING=${CMAKE_CXX_FLAGS}\ -I\ ${_Boost_INCLUDE_DIR}\ -I\ ${_FINDPACKAGE_GSL_INCLUDE_DIR}\ -I\ ${_FINDPACKAGE_SPDLOG_INCLUDE_DIR}\ -I\ ${_OPENSSL_INCLUDE_DIR}\ -I\ ${_FINDPACKAGE_PROTOBUF_INCLUDE_DIR}\ -I\ ${_FINDPACKAGE_BOOST_DI_INCLUDE_DIR}\ -I\ ${_FINDPACKAGE_ROCKSDB_INCLUDE_DIR}
  DEPENDS GTest Microsoft.GSL spdlog tsl_hat_trie libp2p grpc ${_PROTOBUF_TARGET} rocksdb Boost.DI
)

# --------------------------------------------------------
# builds ipfs-pubsub
ExternalProject_Add(ipfs-pubsub
  PREFIX ipfs-pubsub
  SOURCE_DIR "${THIRDPARTY_DIR}/ipfs-pubsub"
  CMAKE_CACHE_ARGS
        -DGTest_DIR:PATH=${_FINDPACKAGE_GTEST_CONFIG_DIR}
        -DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_CURRENT_BINARY_DIR}/ipfs-pubsub
        -Dspdlog_DIR:PATH=${_FINDPACKAGE_SPDLOG_CONFIG_DIR}
        -Dtsl_hat_trie_DIR:PATH=${_FINDPACKAGE_TSL_HAT_TRIE_CONFIG_DIR}
        -Dlibp2p_DIR:PATH=${_FINDPACKAGE_libp2p_CONFIG_DIR}
        -DProtobuf_DIR:PATH=${_FINDPACKAGE_PROTOBUF_CONFIG_DIR}
        -DProtobuf_INCLUDE_DIR:PATH=${_FINDPACKAGE_PROTOBUF_INCLUDE_DIR}
        -DProtobuf_LIBRARIES:PATH=${_FINDPACKAGE_PROTOBUF_LIB_DIR}
        -DProtobuf_PROTOC_EXECUTABLE:PATH=${_PROTOBUF_PROTOC_EXEC}
        -DBoost.DI_DIR:PATH=${_FINDPACKAGE_BOOST_DI_CONFIG_DIR}
        -Dc-ares_DIR:PATH=${_FINDPACKAGE_CARES_CONFIG_DIR}
        -Dfmt_DIR:PATH=${_FINDPACKAGE_FMT_CONFIG_DIR}
        -Dsoralog_DIR:PATH=${_FINDPACKAGE_SORALOG_CONFIG_DIR}
        -Dyaml-cpp_DIR:PATH=${_FINDPACKAGE_YAMLCPP_CONFIG_DIR}
        -DTESTING:BOOL=${TESTING}
        ${_CMAKE_COMMON_BUILD_PARAMS}
        ${_BOOST_CACHE_ARGS}
        ${_OPENSSL_CACHE_ARGS}
        -DCMAKE_CXX_STANDARD:STRING=17
        -DCMAKE_CXX_FLAGS:STRING=${CMAKE_CXX_FLAGS}\ -I\ ${_Boost_INCLUDE_DIR}\ -I\ ${_FINDPACKAGE_GSL_INCLUDE_DIR}\ -I\ ${_FINDPACKAGE_SPDLOG_INCLUDE_DIR}\ -I\ ${_OPENSSL_INCLUDE_DIR}\ -I\ ${_FINDPACKAGE_PROTOBUF_INCLUDE_DIR}\ -I\ ${_FINDPACKAGE_BOOST_DI_INCLUDE_DIR}
  DEPENDS GTest Microsoft.GSL spdlog tsl_hat_trie libp2p  Boost.DI
)

# --------------------------------------------------------
# builds ipfs-bitswap-cpp
#ExternalProject_Add(ipfs-bitswap-cpp
#  PREFIX ipfs-bitswap-cpp
#  SOURCE_DIR "${THIRDPARTY_DIR}/ipfs-bitswap-cpp"
#  CMAKE_CACHE_ARGS
#        -DGTest_DIR:PATH=${_FINDPACKAGE_GTEST_CONFIG_DIR}
#        -DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_CURRENT_BINARY_DIR}/ipfs-bitswap-cpp
#        -Dspdlog_DIR:PATH=${_FINDPACKAGE_SPDLOG_CONFIG_DIR}
#        -Dlibp2p_DIR:PATH=${_FINDPACKAGE_libp2p_CONFIG_DIR}
#        -DProtobuf_DIR:PATH=${_FINDPACKAGE_PROTOBUF_CONFIG_DIR}
#        -DProtobuf_INCLUDE_DIR:PATH=${_FINDPACKAGE_PROTOBUF_INCLUDE_DIR}
#        -DProtobuf_LIBRARIES:PATH=${_FINDPACKAGE_PROTOBUF_LIB_DIR}
#        -DProtobuf_PROTOC_EXECUTABLE:PATH=${_PROTOBUF_PROTOC_EXEC}
#        -DTESTING:BOOL=${TESTING}
#        ${_CMAKE_COMMON_BUILD_PARAMS}
#        ${_BOOST_CACHE_ARGS}
#        ${_OPENSSL_CACHE_ARGS}
#        -DCMAKE_CXX_FLAGS:STRING=${CMAKE_CXX_FLAGS}\ -I\ ${_Boost_INCLUDE_DIR}\ -I\ ${_FINDPACKAGE_SPDLOG_INCLUDE_DIR}\ -I\ ${_OPENSSL_INCLUDE_DIR}\ -I\ ${_FINDPACKAGE_PROTOBUF_INCLUDE_DIR}\ -std=c++17
#  DEPENDS GTest spdlog libp2p Boost
#)

# --------------------------------------------------------
# Builds ed25519
ExternalProject_Add(ed25519
  PREFIX ed25519
  SOURCE_DIR "${THIRDPARTY_DIR}/ed25519"
  CMAKE_CACHE_ARGS
        -DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_CURRENT_BINARY_DIR}/ed25519
        -DHUNTER_ENABLED:BOOL=OFF
        -DEDIMPL:STRING=${_ED25519_EDIIMPL}
        -DHASH:STRING=${_ED25519_HASH}
        -DRANDOM:STRING=${_ED25519_RANDOM}
        -DBUILD:STRING=STATIC
        -DTESTING:BOOL=OFF
        -DGTest_DIR:PATH=${_FINDPACKAGE_GTEST_CONFIG_DIR}
        ${_CMAKE_COMMON_BUILD_PARAMS}
)
set(_FINDPACKAGE_ed25519_CONFIG_DIR "${CMAKE_CURRENT_BINARY_DIR}/ed25519/lib/cmake/ed25519")

# --------------------------------------------------------
# Builds sr25519-donna
ExternalProject_Add(sr25519-donna
  PREFIX sr25519-donna
  SOURCE_DIR "${THIRDPARTY_DIR}/sr25519-donna"
  CMAKE_CACHE_ARGS
        -DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_CURRENT_BINARY_DIR}/sr25519-donna
        -DTESTING:BOOL=OFF
        -DBUILD_SHARED_LIBS:BOOL=OFF
        -DHASH_USE_SHA3_BRAINHUB:BOOL=ON
        ${_CMAKE_COMMON_BUILD_PARAMS}
)

# --------------------------------------------------------
# Builds rapidjson
ExternalProject_Add(rapidjson
  PREFIX rapidjson
  SOURCE_DIR "${THIRDPARTY_DIR}/rapidjson"
  CMAKE_CACHE_ARGS
        -DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_CURRENT_BINARY_DIR}/rapidjson
        -DRAPIDJSON_BUILD_TESTS:BOOL=OFF
        -DRAPIDJSON_BUILD_EXAMPLES:BOOL=OFF
        -DHUNTER_ENABLED:BOOL=OFF
        -DBUILD_SHARED_LIBS:BOOL=FALSE
        -DGTest_DIR:PATH=${_FINDPACKAGE_GTEST_CONFIG_DIR}
        ${_CMAKE_COMMON_BUILD_PARAMS}
)

# --------------------------------------------------------
# Builds binaryen
ExternalProject_Add(binaryen
  PREFIX binaryen
  URL https://github.com/Warchant/binaryen/archive/1.38.28-p0.zip
  CMAKE_CACHE_ARGS
        -DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_CURRENT_BINARY_DIR}/binaryen
        -DBUILD_STATIC_LIB:BOOL=ON
        -DBUILD_TOOLS:BOOL=OFF
        -DENABLE_WERROR:BOOL=OFF
        ${_CMAKE_COMMON_BUILD_PARAMS}
)


# --------------------------------------------------------
# Builds libsecp256k1
ExternalProject_Add(libsecp256k1
    PREFIX libsecp256k1
    URL https://github.com/soramitsu/soramitsu-libsecp256k1/archive/c7630e1bac638c0f16ee66d4dce7b5c49eecbaa5.zip
    URL_HASH    SHA1=179e316b0fe5150f1b05ca70ec2ac1490fe2cb3b
    CMAKE_CACHE_ARGS
      -DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_CURRENT_BINARY_DIR}/libsecp256k1
      -DSECP256K1_BUILD_TEST:BOOL=OFF
      ${_CMAKE_COMMON_BUILD_PARAMS}
    PATCH_COMMAND ${CMAKE_COMMAND} -E copy
      "${PROJECT_BUILD_FOLDER}/cmake.in/libsecp256k1-patch/CMakeLists.txt" <SOURCE_DIR>/CMakeLists.txt
)

# --------------------------------------------------------
# Builds xxhash
ExternalProject_Add( xxhash
    PREFIX xxhash
    URL https://github.com/hunter-packages/xxHash/archive/0.6.5-p0.tar.gz
    CMAKE_CACHE_ARGS
          -DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_CURRENT_BINARY_DIR}/xxhash
          -DSECP256K1_BUILD_TEST:BOOL=OFF
          ${_CMAKE_COMMON_BUILD_PARAMS}
)

# --------------------------------------------------------
# jsonrpc-lean
install(
        DIRECTORY ${THIRDPARTY_DIR}/jsonrpc-lean
        DESTINATION ${CMAKE_CURRENT_BINARY_DIR}/jsonrpc-lean
    )

# --------------------------------------------------------
#ExternalProject_Add( hawktracer
#PREFIX hawktracer
#URL https://github.com/amzn/hawktracer/archive/v0.10.0.zip
## GIT_TAG           "v0.10.0"
## GIT_SHALLOW TRUE
##URL_HASH    SHA1=179e316b0fe5150f1b05ca70ec2ac1490fe2cb3b
#CMAKE_CACHE_ARGS
#	  -DBUILD_STATIC_LIB:BOOL=ON
#      -DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_CURRENT_BINARY_DIR}/hawktracer
#      ${_CMAKE_COMMON_BUILD_PARAMS}
#)


## --------------------------------------------------------
## build third party for grpc
#ExternalProject_Add(gnostic
#    PREFIX gnostic
#    URL https://github.com/googleapis/gnostic/archive/v0.5.1.zip
#    CONFIGURE_COMMAND  ""
#    BUILD_COMMAND go install .
#    INSTALL_COMMAND  ""
#    BUILD_IN_SOURCE  TRUE
#)

## --------------------------------------------------------
## build third party for grpc
#ExternalProject_ADd(gnostic-grpc
#    PREFIX gnostic-grpc
#    URL https://github.com/googleapis/gnostic-grpc/archive/v0.1.0.zip
#    CONFIGURE_COMMAND  ""
#    BUILD_COMMAND go install .
#    INSTALL_COMMAND  ""
#    BUILD_IN_SOURCE  TRUE
#)
