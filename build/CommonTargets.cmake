# Python3 — required by shaderc patch step (git-sync-deps)
find_package(Python3 COMPONENTS Interpreter REQUIRED)

# GTest
ExternalProject_Add(GTest
    PREFIX GTest
    SOURCE_DIR "${THIRDPARTY_DIR}/GTest"
   CMAKE_CACHE_ARGS
    -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>
    ${_CMAKE_COMMON_CACHE_ARGS}
)
set(_FINDPACKAGE_GTEST_CONFIG_DIR "${CMAKE_CURRENT_BINARY_DIR}/GTest/lib/cmake/GTest")

# Build protoc for host OS.
if(CMAKE_CROSSCOMPILING)
    set(PROTOBUF_HOST_PREFIX "${CMAKE_CURRENT_BINARY_DIR}/protobuf_host")
    set(PROTOBUF_TARGET protobuf_host)

    ExternalProject_Add(protobuf_host
        PREFIX ${PROTOBUF_HOST_PREFIX}
        SOURCE_DIR "${THIRDPARTY_DIR}/protobuf"
           CMAKE_ARGS
        -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>
        CMAKE_CACHE_ARGS
        -DABSL_BUILD_TESTING:BOOL=OFF
        -DBUILD_TESTING:BOOL=OFF
        -DCMAKE_BUILD_TYPE:STRING=Release
        -DCMAKE_CXX_STANDARD:STRING=${CMAKE_CXX_STANDARD}
        # Match _CMAKE_COMMON_CACHE_ARGS: pin libdir so EL hosts (lib64 default)
        # land in the hardcoded ${PROTOBUF_HOST_PREFIX}/lib layout below.
        -DCMAKE_INSTALL_LIBDIR:STRING=lib
        -Dprotobuf_BUILD_TESTS:BOOL=OFF
        -Dprotobuf_MODULE_COMPATIBLE:BOOL=ON
        -Dprotobuf_INSTALL:BOOL=ON
        ${_PROTOBUF_HOST_EXTRA_CACHE_ARGS}
    )
else()
    set(PROTOBUF_HOST_PREFIX "${CMAKE_CURRENT_BINARY_DIR}/protobuf")
    set(PROTOBUF_TARGET protobuf)
endif()

set(absl_HOST_DIR "${PROTOBUF_HOST_PREFIX}/lib/cmake/absl")
set(Protobuf_HOST_DIR "${PROTOBUF_HOST_PREFIX}/lib/cmake/protobuf")
set(utf8_range_HOST_DIR "${PROTOBUF_HOST_PREFIX}/lib/cmake/utf8_range")

set(PROTOBUF_HOST_INCLUDE_DIR "${PROTOBUF_HOST_PREFIX}/include")
set(PROTOBUF_HOST_LIB_DIR "${PROTOBUF_HOST_PREFIX}/lib")
set(PROTOC_EXECUTABLE "${PROTOBUF_HOST_PREFIX}/bin/protoc${CMAKE_EXECUTABLE_SUFFIX}")

# zlib
ExternalProject_Add(zlib
    PREFIX zlib
    SOURCE_DIR "${THIRDPARTY_DIR}/zlib"
    CMAKE_CACHE_ARGS
    -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>
    -DZLIB_BUILD_SHARED:BOOL=OFF
    -DZLIB_BUILD_STATIC:BOOL=ON
    -DZLIB_BUILD_TESTING:BOOL=OFF
    -DZLIB_INSTALL:BOOL=ON
    ${_CMAKE_COMMON_CACHE_ARGS}
    -DCMAKE_CXX_FLAGS:STRING=${CMAKE_CXX_FLAGS}
)

ExternalProject_Get_Property(zlib INSTALL_DIR)
set(_FINDPACKAGE_ZLIB_INSTALL_DIR "${INSTALL_DIR}")
set(_FINDPACKAGE_ZLIB_DIR "${INSTALL_DIR}/lib/cmake/zlib")
set(_FINDPACKAGE_ZLIB_INCLUDE_DIR "${INSTALL_DIR}/include")
set(_ZLIB_PACKAGE_ARGS
    -DCMAKE_PREFIX_PATH:PATH=${_FINDPACKAGE_ZLIB_INSTALL_DIR}
    -Dzlib_DIR:PATH=${_FINDPACKAGE_ZLIB_DIR}
    -DZLIB_DIR:PATH=${_FINDPACKAGE_ZLIB_DIR}
    -DZLIB_ROOT:PATH=${_FINDPACKAGE_ZLIB_INSTALL_DIR}
    -DZLIB_USE_STATIC_LIBS:BOOL=ON
)
if(CMAKE_CROSSCOMPILING)
    set(_PROTOBUF_PLUGIN_ZLIB_PACKAGE_ARGS)
else()
    set(_PROTOBUF_PLUGIN_ZLIB_PACKAGE_ARGS ${_ZLIB_PACKAGE_ARGS} "-DCMAKE_FIND_PACKAGE_PREFER_CONFIG:BOOL=ON")
endif()
ExternalProject_Add_StepDependencies(Boost build zlib)
ExternalProject_Add_StepDependencies(Boost install zlib)

# c-ares
ExternalProject_Add(cares
    PREFIX cares
    SOURCE_DIR "${THIRDPARTY_DIR}/c-ares"
   CMAKE_CACHE_ARGS
    -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>
    -DCARES_STATIC:BOOL=ON
    -DCARES_SHARED:BOOL=OFF
    ${_CMAKE_COMMON_CACHE_ARGS}
)
ExternalProject_Get_Property(cares INSTALL_DIR)
set(_FINDPACKAGE_CARES_CONFIG_DIR "${INSTALL_DIR}/lib/cmake/c-ares")
set(_FINDPACKAGE_CARES_LIBRARY_DIR "${INSTALL_DIR}/lib")
set(_FINDPACKAGE_CARES_INCLUDE_DIR "${INSTALL_DIR}/include")

# Protobuf
ExternalProject_Add(protobuf
    PREFIX protobuf
    SOURCE_DIR "${THIRDPARTY_DIR}/protobuf"
   CMAKE_ARGS
    -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>
    CMAKE_CACHE_ARGS
    ${_CMAKE_COMMON_CACHE_ARGS}
    -DABSL_ENABLE_INSTALL:BOOL=ON
    -DBUILD_SHARED_LIBS:BOOL=OFF
    -DBUILD_TESTING:BOOL=OFF
    ${_ZLIB_PACKAGE_ARGS}
    -Dprotobuf_MODULE_COMPATIBLE:BOOL=ON
    -Dprotobuf_MSVC_STATIC_RUNTIME:BOOL=ON
    DEPENDS zlib
)
ExternalProject_Get_Property(protobuf INSTALL_DIR)
set(absl_DIR "${INSTALL_DIR}/lib/cmake/absl")
set(utf8_range_DIR "${INSTALL_DIR}/lib/cmake/utf8_range")
set(Protobuf_DIR "${INSTALL_DIR}/lib/cmake/protobuf")

# Snappy for RocksDB compression
ExternalProject_Add(snappy
    PREFIX snappy
    SOURCE_DIR "${THIRDPARTY_DIR}/snappy"
   CMAKE_ARGS
    CMAKE_CACHE_ARGS
    -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>
    -DFAIL_ON_WARNINGS:BOOL=OFF
    -DSNAPPY_BUILD_TESTS:BOOL=OFF
    -DSNAPPY_BUILD_BENCHMARKS:BOOL=OFF
    ${_CMAKE_COMMON_CACHE_ARGS}
    # these need to be at the end to override previous cached args line
    -DCMAKE_CXX_FLAGS_DEBUG:STRING=${CMAKE_CXX_FLAGS_DEBUG}\ -DNDEBUG
    -DCMAKE_C_FLAGS_DEBUG:STRING=${CMAKE_C_FLAGS_DEBUG}\ -DNDEBUG
    BUILD_BYPRODUCTS
    "${CMAKE_CURRENT_BINARY_DIR}/snappy/lib/libsnappy.a"
)

set(_FINDPACKAGE_SNAPPY_DIR "${CMAKE_CURRENT_BINARY_DIR}/snappy/lib/cmake/Snappy")
set(_FINDPACKAGE_SNAPPY_INCLUDE_DIR "${CMAKE_CURRENT_BINARY_DIR}/snappy/include")

# RocksDB
ExternalProject_Add(rocksdb
    PREFIX rocksdb
    SOURCE_DIR "${THIRDPARTY_DIR}/rocksdb"
   CMAKE_ARGS
    -DWITH_TRACE_TOOLS:BOOL=$<CONFIG:Debug>
    CMAKE_CACHE_ARGS
    -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>
    -DFAIL_ON_WARNINGS:BOOL=OFF
    -DPORTABLE:BOOL=ON
    -DROCKSDB_BUILD_SHARED:BOOL=OFF
    -DROCKSDB_INSTALL_ON_WINDOWS:BOOL=ON
    -DWITH_ALL_TESTS:BOOL=OFF
    -DWITH_BENCHMARK_TOOLS:BOOL=OFF
    -DWITH_CORE_TOOLS:BOOL=OFF
    -DWITH_GFLAGS:BOOL=OFF
    -DWITH_MD_LIBRARY:BOOL=OFF
    -DWITH_RUNTIME_DEBUG:BOOL=ON
    -DWITH_TESTS:BOOL=OFF
    -DWITH_TOOLS:BOOL=OFF
    -DWITH_SNAPPY:BOOL=ON
    -DSnappy_DIR:PATH=${_FINDPACKAGE_SNAPPY_DIR}
    ${_CMAKE_COMMON_CACHE_ARGS}
    ${_rocksdb_EXTRA_PARAM}
    # these need to be at the end to override previous cached args line
    -DCMAKE_CXX_FLAGS_DEBUG:STRING=${CMAKE_CXX_FLAGS_DEBUG}\ -DNDEBUG
    -DCMAKE_C_FLAGS_DEBUG:STRING=${CMAKE_C_FLAGS_DEBUG}\ -DNDEBUG
    DEPENDS snappy
    BUILD_BYPRODUCTS
    "${CMAKE_CURRENT_BINARY_DIR}/rocksdb/lib/librocksdb.a"
    "${CMAKE_CURRENT_BINARY_DIR}/rocksdb/lib/cmake/rocksdb/RocksDBConfig.cmake"
)
set(_FINDPACKAGE_ROCKSDB_DIR "${CMAKE_CURRENT_BINARY_DIR}/rocksdb/lib/cmake/rocksdb")
set(_FINDPACKAGE_ROCKSDB_INCLUDE_DIR "${CMAKE_CURRENT_BINARY_DIR}/rocksdb/include")

# GSL
ExternalProject_Add(Microsoft.GSL
    PREFIX Microsoft.GSL
    SOURCE_DIR "${THIRDPARTY_DIR}/GSL"
   CMAKE_CACHE_ARGS
    -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>
    -DGSL_TEST:BOOL=OFF
    ${_CMAKE_COMMON_CACHE_ARGS}
)
set(_FINDPACKAGE_GSL_INCLUDE_DIR "${CMAKE_CURRENT_BINARY_DIR}/Microsoft.GSL/include")

# fmt
ExternalProject_Add(fmt
    PREFIX fmt
    SOURCE_DIR "${THIRDPARTY_DIR}/fmt"
   CMAKE_CACHE_ARGS
    -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>
    ${_CMAKE_COMMON_CACHE_ARGS}
    -DBUILD_SHARED_LIBS:BOOL=OFF
    -DFMT_DOC:BOOL=OFF
    -DFMT_TEST:BOOL=OFF
)

set(_FINDPACKAGE_FMT_CONFIG_DIR "${CMAKE_CURRENT_BINARY_DIR}/fmt/lib/cmake/fmt")
set(_FINDPACKAGE_FMT_LIBRARY_DIR "${CMAKE_CURRENT_BINARY_DIR}/fmt/lib")
set(_FINDPACKAGE_FMT_INCLUDE_DIR "${CMAKE_CURRENT_BINARY_DIR}/fmt/include")

# spdlog
ExternalProject_Add(spdlog
    PREFIX spdlog
    SOURCE_DIR "${THIRDPARTY_DIR}/spdlog"
   CMAKE_CACHE_ARGS
    -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>
    -Dfmt_DIR:PATH=${_FINDPACKAGE_FMT_CONFIG_DIR}
    -DSPDLOG_BUILD_EXAMPLE:BOOL=OFF
    -DSPDLOG_FMT_EXTERNAL:BOOL=ON
    ${_CMAKE_COMMON_CACHE_ARGS}
    DEPENDS fmt
)
set(_FINDPACKAGE_SPDLOG_INCLUDE_DIR "${CMAKE_CURRENT_BINARY_DIR}/spdlog/include")
set(_FINDPACKAGE_SPDLOG_CONFIG_DIR "${CMAKE_CURRENT_BINARY_DIR}/spdlog/lib/cmake/spdlog")

# tsl_hat_trie
ExternalProject_Add(tsl_hat_trie
    PREFIX tsl_hat_trie
    SOURCE_DIR "${THIRDPARTY_DIR}/hat-trie"
   CMAKE_CACHE_ARGS
    -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>
    ${_CMAKE_COMMON_CACHE_ARGS}
)
set(_FINDPACKAGE_TSL_HAT_TRIE_CONFIG_DIR "${CMAKE_CURRENT_BINARY_DIR}/tsl_hat_trie/lib/cmake/tsl_hat_trie")
set(_FINDPACKAGE_TSL_HAT_TRIE_INCLUDE_DIR "${CMAKE_CURRENT_BINARY_DIR}/tsl_hat_trie/include")

# Boost.DI
ExternalProject_Add(Boost.DI
    PREFIX Boost.DI
    SOURCE_DIR "${THIRDPARTY_DIR}/Boost.DI"
   CMAKE_CACHE_ARGS
    -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>
    -DBOOST_DI_OPT_BUILD_TESTS:BOOL=OFF
    -DBOOST_DI_OPT_BUILD_EXAMPLES:BOOL=OFF
    -DBOOST_DI_OPT_INSTALL:BOOL=ON
    ${_BOOST_CACHE_ARGS}
    ${_CMAKE_COMMON_CACHE_ARGS}
    DEPENDS Boost
)
set(_FINDPACKAGE_BOOST_DI_CONFIG_DIR "${CMAKE_CURRENT_BINARY_DIR}/Boost.DI/lib/cmake/Boost.DI")
set(_FINDPACKAGE_BOOST_DI_INCLUDE_DIR "${CMAKE_CURRENT_BINARY_DIR}/Boost.DI/include")

# yaml-cpp
ExternalProject_Add(yaml-cpp
    PREFIX yaml-cpp
    SOURCE_DIR "${THIRDPARTY_DIR}/yaml-cpp"
   CMAKE_CACHE_ARGS
    -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>
    -DYAML_BUILD_SHARED_LIBS:BOOL=OFF
    -DYAML_CPP_BUILD_CONTRIB:BOOL=OFF
    -DYAML_CPP_BUILD_TOOLS:BOOL=OFF
    -DYAML_MSVC_SHARED_RT:BOOL=OFF
    ${_CMAKE_COMMON_CACHE_ARGS}
)

set(_FINDPACKAGE_YAMLCPP_CONFIG_DIR "${CMAKE_CURRENT_BINARY_DIR}/yaml-cpp/lib/cmake/yaml-cpp")
set(_FINDPACKAGE_YAMLCPP_LIBRARY_DIR "${CMAKE_CURRENT_BINARY_DIR}/yaml-cpp/lib")
set(_FINDPACKAGE_YAMLCPP_INCLUDE_DIR "${CMAKE_CURRENT_BINARY_DIR}/yaml-cpp/include")

# Copies STB headers
file(GLOB STB_HEADERS "${THIRDPARTY_DIR}/stb/*.h")

ExternalProject_Add(STB
    PREFIX stb
    SOURCE_DIR "${THIRDPARTY_DIR}/stb"
   CONFIGURE_COMMAND ""
    BUILD_COMMAND ""
    INSTALL_COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_CURRENT_BINARY_DIR}/stb/include
    COMMAND ${CMAKE_COMMAND} -E copy_if_different ${STB_HEADERS} ${CMAKE_CURRENT_BINARY_DIR}/stb/include/
)

# soralog
ExternalProject_Add(soralog
    PREFIX soralog
    SOURCE_DIR "${THIRDPARTY_DIR}/soralog"
   CMAKE_CACHE_ARGS
    -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>
    -DHUNTER_ENABLED:BOOL=OFF
    -DEXAMPLES:BOOL=OFF
    -DTESTING:BOOL=OFF
    -Dyaml-cpp_DIR:PATH=${_FINDPACKAGE_YAMLCPP_CONFIG_DIR}
    -Dfmt_DIR:PATH=${_FINDPACKAGE_FMT_CONFIG_DIR}
    ${_CMAKE_COMMON_CACHE_ARGS}
    DEPENDS fmt yaml-cpp
)

set(_FINDPACKAGE_SORALOG_CONFIG_DIR "${CMAKE_CURRENT_BINARY_DIR}/soralog/lib/cmake/soralog")
set(_FINDPACKAGE_SORALOG_LIBRARY_DIR "${CMAKE_CURRENT_BINARY_DIR}/soralog/lib")
set(_FINDPACKAGE_SORALOG_INCLUDE_DIR "${CMAKE_CURRENT_BINARY_DIR}/soralog/include")

# SQLite3
ExternalProject_Add(sqlite3
    PREFIX sqlite3
    SOURCE_DIR "${THIRDPARTY_DIR}/sqlite3"
   CMAKE_ARGS
    -DENABLE_DEBUG:BOOL=$<CONFIG:Debug>
    CMAKE_CACHE_ARGS
    -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>
    -DENABLE_SHARED:BOOL=OFF
    -DENABLE_STATIC:BOOL=ON
    -DBUILD_SHELL:BOOL=OFF
    ${_ZLIB_PACKAGE_ARGS}
    ${_CMAKE_COMMON_CACHE_ARGS}
    DEPENDS zlib
)

set(_FINDPACKAGE_SQLITE3_CONFIG_DIR "${CMAKE_CURRENT_BINARY_DIR}/sqlite3/cmake")
set(_FINDPACKAGE_SQLITE3_LIBRARY_DIR "${CMAKE_CURRENT_BINARY_DIR}/sqlite3/lib")
set(_FINDPACKAGE_SQLITE3_INCLUDE_DIR "${CMAKE_CURRENT_BINARY_DIR}/sqlite3/include")

# SQLiteModernCpp
ExternalProject_Add(SQLiteModernCpp
    PREFIX SQLiteModernCpp
    SOURCE_DIR "${THIRDPARTY_DIR}/SQLiteModernCpp"
   CMAKE_CACHE_ARGS
    -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>
    ${_CMAKE_COMMON_CACHE_ARGS}
    -DHUNTER_ENABLED:BOOL=OFF
    -Dsqlite3_DIR:PATH=${_FINDPACKAGE_SQLITE3_CONFIG_DIR}
    -DENABLE_INSTALL:BOOL=ON
    ${_ZLIB_PACKAGE_ARGS}
    DEPENDS sqlite3 zlib
)

set(_FINDPACKAGE_SQLITECPP_CONFIG_DIR "${CMAKE_CURRENT_BINARY_DIR}/SQLiteModernCpp/lib/cmake/SQLiteModernCpp")
set(_FINDPACKAGE_SQLITECPP_LIBRARY_DIR "${CMAKE_CURRENT_BINARY_DIR}/SQLiteModernCpp/lib")
set(_FINDPACKAGE_SQLITECPP_INCLUDE_DIR "${CMAKE_CURRENT_BINARY_DIR}/SQLiteModernCpp/include")

# libp2p
ExternalProject_Add(libp2p
    PREFIX libp2p
    SOURCE_DIR "${THIRDPARTY_DIR}/libp2p"
   CMAKE_CACHE_ARGS
    -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>
    -Dabsl_DIR:PATH=${absl_DIR}
    -DBoost.DI_DIR:PATH=${_FINDPACKAGE_BOOST_DI_CONFIG_DIR}
    -Dc-ares_DIR:PATH=${_FINDPACKAGE_CARES_CONFIG_DIR}
    -DCLANG_FORMAT:BOOL=OFF
    -DCLANG_TIDY:BOOL=OFF
    -DCMAKE_USE_OPENSSL:BOOL=ON
    -DEXAMPLES:BOOL=OFF
    -DEXPOSE_MOCKS:BOOL=ON
    -Dfmt_DIR:PATH=${_FINDPACKAGE_FMT_CONFIG_DIR}
    -DHUNTER_ENABLED:BOOL=OFF
    -DProtobuf_DIR:PATH=${Protobuf_DIR}
    -Dprotobuf_MODULE_COMPATIBLE:BOOL=ON
    -DProtobuf_PROTOC_EXECUTABLE:FILEPATH=${PROTOC_EXECUTABLE}
    -Dsoralog_DIR:PATH=${_FINDPACKAGE_SORALOG_CONFIG_DIR}
    -Dsqlite3_DIR:PATH=${_FINDPACKAGE_SQLITE3_CONFIG_DIR}
    -DSQLiteModernCpp_DIR:PATH=${_FINDPACKAGE_SQLITECPP_CONFIG_DIR}
    -DTESTING:BOOL=OFF
    -Dtsl_hat_trie_DIR:PATH=${_FINDPACKAGE_TSL_HAT_TRIE_CONFIG_DIR}
    -Dutf8_range_DIR:PATH=${utf8_range_DIR}
    -Dyaml-cpp_DIR:PATH=${_FINDPACKAGE_YAMLCPP_CONFIG_DIR}
    ${_ZLIB_PACKAGE_ARGS}
    ${_BOOST_CACHE_ARGS}
    ${_OPENSSL_CACHE_ARGS}
    ${_CMAKE_COMMON_CACHE_ARGS}
    ${_CMAKE_COMMON_CACHE_ARGS_SYMBOLS}
    -DCMAKE_CXX_FLAGS:STRING=${CMAKE_CXX_FLAGS}\ -I\ ${_FINDPACKAGE_GSL_INCLUDE_DIR}\ -I\ ${_FINDPACKAGE_SQLITE3_INCLUDE_DIR}
    DEPENDS Boost Microsoft.GSL openssl cares ${PROTOBUF_TARGET} fmt yaml-cpp soralog tsl_hat_trie Boost.DI SQLiteModernCpp protobuf
)
set(_FINDPACKAGE_libp2p_CONFIG_DIR "${CMAKE_CURRENT_BINARY_DIR}/libp2p/lib/cmake/libp2p")
set(_FINDPACKAGE_libp2p_LIBRARY_DIR "${CMAKE_CURRENT_BINARY_DIR}/libp2p/lib")
set(_FINDPACKAGE_LIBP2P_INCLUDE_DIR "${CMAKE_CURRENT_BINARY_DIR}/libp2p/include")

# Vulkan-Headers — single build for all platforms.
ExternalProject_Add(
    Vulkan-Headers
    PREFIX Vulkan-Headers
    SOURCE_DIR "${THIRDPARTY_DIR}/Vulkan-Headers"
       CMAKE_CACHE_ARGS
    -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>
    ${_CMAKE_COMMON_CACHE_ARGS}
)

# Vulkan-Loader — desktop only (Android/iOS use platform-native loaders).
if(NOT ANDROID)
    ExternalProject_Add(
        Vulkan-Loader
        PREFIX Vulkan-Loader
        SOURCE_DIR "${THIRDPARTY_DIR}/Vulkan-Loader"
           CMAKE_CACHE_ARGS
        -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>
        -DVulkanHeaders_DIR:PATH=${CMAKE_CURRENT_BINARY_DIR}/Vulkan-Headers/share/cmake/VulkanHeaders
        -DBUILD_WSI_XCB_SUPPORT:BOOL=OFF
        -DBUILD_WSI_XLIB_SUPPORT:BOOL=OFF
        -DBUILD_WSI_WAYLAND_SUPPORT:BOOL=OFF
        -DBUILD_WSI_DIRECTFB_SUPPORT:BOOL=OFF
        -DBUILD_WSI_SCREEN_QNX_SUPPORT:BOOL=OFF
        ${_CMAKE_COMMON_CACHE_ARGS}
        DEPENDS Vulkan-Headers
    )

    set(ENV{VULKAN_SDK} "${CMAKE_CURRENT_BINARY_DIR}/Vulkan-Loader")
    set(vulkanTarget Vulkan-Loader)
endif()

# SPIRV-Tools and SPIRV-Headers are no longer built as standalone ExternalProjects.
# libshaderc_combined (built by shaderc below) statically bundles the exact same SPIRV-Tools
# code at the exact same pinned commit (v2024.3 DEPS), so linking shaderc::shaderc already
# provides all SPIRV-Tools symbols. The spirv-tools include path is added to
# shaderc::shaderc's INTERFACE_INCLUDE_DIRECTORIES below.

# vk-bootstrap — depends on the single Vulkan-Headers build above.
ExternalProject_Add(
    vk-bootstrap
    PREFIX vk-bootstrap
    SOURCE_DIR "${THIRDPARTY_DIR}/vk-bootstrap"
       CMAKE_CACHE_ARGS
    -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>
    -DVulkanHeaders_DIR:PATH=${CMAKE_CURRENT_BINARY_DIR}/Vulkan-Headers/share/cmake/VulkanHeaders
    -DVK_BOOTSTRAP_TEST:BOOL=OFF
    -DVK_BOOTSTRAP_POSITION_INDEPENDENT_CODE:BOOL=ON
    ${_CMAKE_COMMON_CACHE_ARGS}
    DEPENDS Vulkan-Headers
)

# shaderc — GLSL->SPIR-V compilation (SHADER-01). Builds its own nested, non-exported copy of
# glslang/SPIRV-Tools/SPIRV-Headers from third_party/ (populated via shaderc's own
# ./utils/git-sync-deps which reads DEPS for pinned commits).  libshaderc_combined
# statically bundles all of these, so consumers linking shaderc::shaderc automatically
# get SPIRV-Tools symbols for the SHADER-02 spirv-val gate.
ExternalProject_Add(
    shaderc
    PREFIX shaderc
    SOURCE_DIR "${THIRDPARTY_DIR}/shaderc"
    # Short binary dir: the default (<prefix>/src/shaderc-build) pushes spirv-tools'
    # MSBuild .tlog paths past the Windows MAX_PATH (260) limit on runners without
    # OS long-path support (worst path 272 -> 254 chars). Must stay directly under a
    # */src directory: build.yml's tarball step excludes build trees via
    # --exclude='./*/src' — any other location leaks the whole glslang/SPIRV-Tools
    # object tree into the release tarballs and blows the 2 GiB asset limit (HTTP 422).
    # The install tree under <prefix> (= <build>/shaderc) and the shaderc::shaderc
    # target are unaffected.
    BINARY_DIR "${CMAKE_CURRENT_BINARY_DIR}/scb/src"
       PATCH_COMMAND
        ${Python3_EXECUTABLE} "${THIRDPARTY_DIR}/shaderc/utils/git-sync-deps"
       CMAKE_CACHE_ARGS
    -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>
    -DSHADERC_SKIP_TESTS:BOOL=ON
    -DSHADERC_SKIP_EXAMPLES:BOOL=ON
    -DSHADERC_SKIP_COPYRIGHT_CHECK:BOOL=ON
    -DSHADERC_ENABLE_HLSL:BOOL=OFF
    -DSHADERC_ENABLE_WGSL_OUTPUT:BOOL=OFF
    ${_CMAKE_COMMON_CACHE_ARGS}
)

# shaderc installs no CMake package config (confirmed via a real local build+install spike,
# 2026-07-30, and cross-checked against github.com/google/shaderc/issues/1369 and
# github.com/microsoft/vcpkg/issues/23208) — hand-written IMPORTED target required.
# libshaderc_combined statically bundles glslang+SPIRV-Tools, so consumers that link
# shaderc::shaderc automatically get SPIRV-Tools symbols (SHADER-02 spirv-val gate).
# The spirv-tools include path is added here so <spirv-tools/libspirv.hpp> resolves.
if(NOT TARGET shaderc::shaderc)
    add_library(shaderc::shaderc STATIC IMPORTED GLOBAL)
    set_target_properties(shaderc::shaderc PROPERTIES
        IMPORTED_LOCATION "${CMAKE_CURRENT_BINARY_DIR}/shaderc/lib/${CMAKE_STATIC_LIBRARY_PREFIX}shaderc_combined${CMAKE_STATIC_LIBRARY_SUFFIX}"
        INTERFACE_INCLUDE_DIRECTORIES "${CMAKE_CURRENT_BINARY_DIR}/shaderc/include;${THIRDPARTY_DIR}/shaderc/third_party/spirv-tools/include"
    )
    add_dependencies(shaderc::shaderc shaderc)
endif()

if(NOT APPLE OR (APPLE AND CMAKE_OSX_SYSROOT MATCHES "iPhoneOS"))
    ExternalProject_Add(MNN
        PREFIX MNN
        SOURCE_DIR "${THIRDPARTY_DIR}/MNN"
           CMAKE_CACHE_ARGS
        -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>
        -DMNN_BUILD_SHARED_LIBS:BOOL=OFF
        -DMNN_BUILD_TEST:BOOL=${MNN_BUILD_TESTS}
        -DMNN_BUILD_LLM:BOOL=ON
        -DMNN_BUILD_LLM_OMNI:BOOL=ON
        -DMNN_LOW_MEMORY:BOOL=ON
        -DMNN_BUILD_TOOLS:BOOL=OFF
        -DMNN_BUILD_PROTOBUFFER:BOOL=OFF
        -DMNN_VULKAN:BOOL=ON
        -DMNN_VULKAN_IMAGE:BOOL=OFF
        -DMNN_SUPPORT_TRANSFORMER_FUSE:BOOL=${MNN_SUPPORT_TRANSFORMER_FUSE}
        -DMNN_WIN_RUNTIME_MT:BOOL=ON
        -DMNN_LLM_BUILD_DEMO:BOOL=OFF
        ${_CMAKE_COMMON_CACHE_ARGS}
        ${_MNN_EXTRA_PARAM}
        DEPENDS ${_MNN_DEPENDS} ${vulkanTarget}
        BUILD_BYPRODUCTS
            "${CMAKE_CURRENT_BINARY_DIR}/MNN/lib/${CMAKE_STATIC_LIBRARY_PREFIX}MNN${CMAKE_STATIC_LIBRARY_SUFFIX}"
            ${MNN_TEST_BYPRODUCT}
    )

    set(_FINDPACKAGE_MNN_CONFIG_DIR "${CMAKE_CURRENT_BINARY_DIR}/MNN/lib/cmake/MNN")
    set(_FINDPACKAGE_MNN_LIBRARY_DIR "${CMAKE_CURRENT_BINARY_DIR}/MNN/lib")
    set(_FINDPACKAGE_MNN_INCLUDE_DIR "${CMAKE_CURRENT_BINARY_DIR}/MNN/include")
    set(_FINDPACKAGE_MNN_BINARY_DIR "${CMAKE_CURRENT_BINARY_DIR}/MNN/bin")
endif()

# ipfs-lite-cpp
ExternalProject_Add(ipfs-lite-cpp
    PREFIX ipfs-lite-cpp
    SOURCE_DIR "${THIRDPARTY_DIR}/ipfs-lite-cpp"
   CMAKE_CACHE_ARGS
    -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>
    -Dabsl_DIR:PATH=${absl_DIR}
    -DBoost_NO_SYSTEM_PATHS:BOOL=ON
    -DBoost.DI_DIR:PATH=${_FINDPACKAGE_BOOST_DI_CONFIG_DIR}
    -Dc-ares_DIR:PATH=${_FINDPACKAGE_CARES_CONFIG_DIR}
    -Dfmt_DIR:PATH=${_FINDPACKAGE_FMT_CONFIG_DIR}
    -Dlibp2p_DIR:PATH=${_FINDPACKAGE_libp2p_CONFIG_DIR}
    -DProtobuf_DIR:PATH=${Protobuf_DIR}
    -Dprotobuf_MODULE_COMPATIBLE:BOOL=ON
    -DProtobuf_PROTOC_EXECUTABLE:FILEPATH=${PROTOC_EXECUTABLE}
    -DSnappy_DIR:PATH=${_FINDPACKAGE_SNAPPY_DIR}
    -DRocksDB_DIR:PATH=${_FINDPACKAGE_ROCKSDB_DIR}
    -DSnappy_DIR:PATH=${_FINDPACKAGE_SNAPPY_DIR}
    -Dsoralog_DIR:PATH=${_FINDPACKAGE_SORALOG_CONFIG_DIR}
    -Dspdlog_DIR:PATH=${_FINDPACKAGE_SPDLOG_CONFIG_DIR}
    -Dsqlite3_DIR:PATH=${_FINDPACKAGE_SQLITE3_CONFIG_DIR}
    -DSQLiteModernCpp_DIR:PATH=${_FINDPACKAGE_SQLITECPP_CONFIG_DIR}
    -Dtsl_hat_trie_DIR:PATH=${_FINDPACKAGE_TSL_HAT_TRIE_CONFIG_DIR}
    -Dutf8_range_DIR:PATH=${utf8_range_DIR}
    -Dyaml-cpp_DIR:PATH=${_FINDPACKAGE_YAMLCPP_CONFIG_DIR}
    ${_CMAKE_COMMON_CACHE_ARGS}
    -DTESTING:BOOL=${TESTING}
    ${_ZLIB_PACKAGE_ARGS}
    ${_BOOST_CACHE_ARGS}
    ${_OPENSSL_CACHE_ARGS}
    -DCMAKE_CXX_FLAGS:STRING=${CMAKE_CXX_FLAGS}\ -I\ ${_FINDPACKAGE_GSL_INCLUDE_DIR}
    DEPENDS Microsoft.GSL spdlog tsl_hat_trie libp2p protobuf ${PROTOBUF_TARGET} rocksdb Boost.DI
)
set(_FINDPACKAGE_IPFS_LITE_CONFIG_DIR "${CMAKE_CURRENT_BINARY_DIR}/ipfs-lite-cpp/lib/cmake/ipfs-lite-cpp")
set(_FINDPACKAGE_IPFS_LITE_LIBRARY_DIR "${CMAKE_CURRENT_BINARY_DIR}/ipfs-lite-cpp/lib")
set(_FINDPACKAGE_IPFS_LITE_INCLUDE_DIR "${CMAKE_CURRENT_BINARY_DIR}/ipfs-lite-cpp/include")
set(_FINDPACKAGE_CBOR_INCLUDE_DIR "${CMAKE_CURRENT_BINARY_DIR}/ipfs-lite-cpp/include/deps/tinycbor/src")

# ipfs-pubsub
ExternalProject_Add(ipfs-pubsub
    PREFIX ipfs-pubsub
    SOURCE_DIR "${THIRDPARTY_DIR}/ipfs-pubsub"
   CMAKE_CACHE_ARGS
    -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>
    -Dabsl_DIR:PATH=${absl_DIR}
    -DBoost.DI_DIR:PATH=${_FINDPACKAGE_BOOST_DI_CONFIG_DIR}
    -Dc-ares_DIR:PATH=${_FINDPACKAGE_CARES_CONFIG_DIR}
    -Dfmt_DIR:PATH=${_FINDPACKAGE_FMT_CONFIG_DIR}
    -Dipfs-lite-cpp_DIR:PATH=${_FINDPACKAGE_IPFS_LITE_CONFIG_DIR}
    -Dipfs-lite-cpp_INCLUDE_DIR:PATH=${_FINDPACKAGE_IPFS_LITE_INCLUDE_DIR}
    -Dlibp2p_DIR:PATH=${_FINDPACKAGE_libp2p_CONFIG_DIR}
    -DProtobuf_DIR:PATH=${Protobuf_DIR}
    -Dsoralog_DIR:PATH=${_FINDPACKAGE_SORALOG_CONFIG_DIR}
    -Dspdlog_DIR:PATH=${_FINDPACKAGE_SPDLOG_CONFIG_DIR}
    -Dsqlite3_DIR:PATH=${_FINDPACKAGE_SQLITE3_CONFIG_DIR}
    -DSQLiteModernCpp_DIR:PATH=${_FINDPACKAGE_SQLITECPP_CONFIG_DIR}
    -DTESTING:BOOL=${TESTING}
    -Dtsl_hat_trie_DIR:PATH=${_FINDPACKAGE_TSL_HAT_TRIE_CONFIG_DIR}
    -Dutf8_range_DIR:PATH=${utf8_range_DIR}
    -Dyaml-cpp_DIR:PATH=${_FINDPACKAGE_YAMLCPP_CONFIG_DIR}
    ${_CMAKE_COMMON_CACHE_ARGS}
    ${_ZLIB_PACKAGE_ARGS}
    ${_BOOST_CACHE_ARGS}
    ${_OPENSSL_CACHE_ARGS}
    -DCMAKE_CXX_FLAGS:STRING=${CMAKE_CXX_FLAGS}\ -I\ ${_FINDPACKAGE_GSL_INCLUDE_DIR}
    DEPENDS Microsoft.GSL spdlog tsl_hat_trie libp2p Boost.DI ipfs-lite-cpp
)
set(_FINDPACKAGE_IPFS_PUBSUB_CONFIG_DIR "${CMAKE_CURRENT_BINARY_DIR}/ipfs-pubsub/lib/cmake/ipfs-pubsub")
set(_FINDPACKAGE_IPFS_PUBSUB_LIBRARY_DIR "${CMAKE_CURRENT_BINARY_DIR}/ipfs-pubsub/lib")
set(_FINDPACKAGE_IPFS_PUBSUB_INCLUDE_DIR "${CMAKE_CURRENT_BINARY_DIR}/ipfs-pubsub/include")

# ipfs-bitswap-cpp
ExternalProject_Add(ipfs-bitswap-cpp
    PREFIX ipfs-bitswap-cpp
    SOURCE_DIR "${THIRDPARTY_DIR}/ipfs-bitswap-cpp"
   CMAKE_CACHE_ARGS
    -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>
    -Dabsl_DIR:PATH=${absl_DIR}
    -DBoost.DI_DIR:PATH=${_FINDPACKAGE_BOOST_DI_CONFIG_DIR}
    -Dc-ares_DIR:PATH=${_FINDPACKAGE_CARES_CONFIG_DIR}
    -Dfmt_DIR:PATH=${_FINDPACKAGE_FMT_CONFIG_DIR}
    -DGTest_DIR:PATH=${_FINDPACKAGE_GTEST_CONFIG_DIR}
    -Dlibp2p_DIR:PATH=${_FINDPACKAGE_libp2p_CONFIG_DIR}
    -DProtobuf_DIR:PATH=${Protobuf_DIR}
    -DProtobuf_INCLUDE_DIR:PATH=${Protobuf_INCLUDE_DIR}
    -DProtobuf_PROTOC_EXECUTABLE:FILEPATH=${PROTOC_EXECUTABLE}
    -Dsoralog_DIR:PATH=${_FINDPACKAGE_SORALOG_CONFIG_DIR}
    -Dspdlog_DIR:PATH=${_FINDPACKAGE_SPDLOG_CONFIG_DIR}
    -Dsqlite3_DIR:PATH=${_FINDPACKAGE_SQLITE3_CONFIG_DIR}
    -DSQLiteModernCpp_DIR:PATH=${_FINDPACKAGE_SQLITECPP_CONFIG_DIR}
    -Dipfs-lite-cpp_DIR:PATH=${_FINDPACKAGE_IPFS_LITE_CONFIG_DIR}
    -Dipfs-lite-cpp_INCLUDE_DIR:PATH=${_FINDPACKAGE_IPFS_LITE_INCLUDE_DIR}
    -DTESTING:BOOL=${TESTING}
    -Dtsl_hat_trie_DIR:PATH=${_FINDPACKAGE_TSL_HAT_TRIE_CONFIG_DIR}
    -Dutf8_range_DIR:PATH=${utf8_range_DIR}
    -Dyaml-cpp_DIR:PATH=${_FINDPACKAGE_YAMLCPP_CONFIG_DIR}
    ${_CMAKE_COMMON_CACHE_ARGS}
    ${_ZLIB_PACKAGE_ARGS}
    ${_BOOST_CACHE_ARGS}
    ${_OPENSSL_CACHE_ARGS}
    -DCMAKE_CXX_FLAGS:STRING=${CMAKE_CXX_FLAGS}\ -I\ ${_FINDPACKAGE_GSL_INCLUDE_DIR}
    DEPENDS Microsoft.GSL spdlog libp2p Boost GTest ipfs-lite-cpp
)
set(_FINDPACKAGE_IPFS_BITSWAP_CONFIG_DIR "${CMAKE_CURRENT_BINARY_DIR}/ipfs-bitswap-cpp/lib/cmake/ipfs-bitswap-cpp")
set(_FINDPACKAGE_IPFS_BITSWAP_LIBRARY_DIR "${CMAKE_CURRENT_BINARY_DIR}/ipfs-bitswap-cpp/lib")
set(_FINDPACKAGE_IPFS_BITSWAP_INCLUDE_DIR "${CMAKE_CURRENT_BINARY_DIR}/ipfs-bitswap-cpp/include")

# ed25519
ExternalProject_Add(ed25519
    PREFIX ed25519
    SOURCE_DIR "${THIRDPARTY_DIR}/ed25519"
   CMAKE_CACHE_ARGS
    -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>
    -DHUNTER_ENABLED:BOOL=OFF
    -DEDIMPL:STRING=ref10
    -DHASH:STRING=sha3_brainhub
    -DRANDOM:STRING=${_ED25519_RANDOM}
    -DBUILD:STRING=STATIC
    -DTESTING:BOOL=OFF
    ${_CMAKE_COMMON_CACHE_ARGS}
)
set(_FINDPACKAGE_ed25519_CONFIG_DIR "${CMAKE_CURRENT_BINARY_DIR}/ed25519/lib/cmake/ed25519")

# RapidJSON
ExternalProject_Add(rapidjson
    PREFIX rapidjson
    SOURCE_DIR "${THIRDPARTY_DIR}/rapidjson"
   CMAKE_CACHE_ARGS
    -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>
    -DRAPIDJSON_BUILD_TESTS:BOOL=OFF
    -DRAPIDJSON_BUILD_EXAMPLES:BOOL=OFF
    -DHUNTER_ENABLED:BOOL=OFF
    -DBUILD_SHARED_LIBS:BOOL=ON
    ${_CMAKE_COMMON_CACHE_ARGS}
)

# libsecp256k1
ExternalProject_Add(libsecp256k1
    PREFIX libsecp256k1
    SOURCE_DIR "${THIRDPARTY_DIR}/libsecp256k1"
   CMAKE_CACHE_ARGS
    -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>
    -DSECP256K1_ASM:BOOL=OFF
    -DSECP256K1_BUILD_BENCHMARK:BOOL=OFF
    -DSECP256K1_BUILD_CTIME_TESTS:BOOL=OFF
    -DSECP256K1_BUILD_EXHAUSTIVE_TESTS:BOOL=OFF
    -DSECP256K1_BUILD_TESTS:BOOL=OFF
    -DSECP256K1_DISABLE_SHARED:BOOL=ON
    -DSECP256K1_ENABLE_MODULE_ECDH:BOOL=OFF
    -DSECP256K1_ENABLE_MODULE_ELLSWIFT:BOOL=OFF
    -DSECP256K1_ENABLE_MODULE_MUSIG:BOOL=OFF
    -DSECP256K1_ENABLE_MODULE_RECOVERY:BOOL=ON
    -DSECP256K1_INSTALL:BOOL=ON
    -DSECP256K1_VALGRIND:BOOL=OFF
    ${_CMAKE_COMMON_CACHE_ARGS}
)

# xxhash
ExternalProject_Add(xxhash
    PREFIX xxhash
    SOURCE_DIR "${THIRDPARTY_DIR}/xxhash/cmake_unofficial"
   CMAKE_CACHE_ARGS
    -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>
    -DXXHASH_BUILD_XXHSUM:BOOL=OFF
    ${_CMAKE_COMMON_CACHE_ARGS}
)

# protobuf-plugin
ExternalProject_Add(protobuf-plugin
    PREFIX protobuf-plugin
    SOURCE_DIR "${THIRDPARTY_DIR}/wallet-core/protobuf-plugin"
   INSTALL_DIR protobuf-plugin
    CMAKE_CACHE_ARGS
    -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>
    -DCMAKE_BUILD_TYPE:STRING=Release
    -Dabsl_DIR:PATH=${absl_HOST_DIR}
    -DProtobuf_DIR:PATH=${Protobuf_HOST_DIR}
    -Dprotobuf_MODULE_COMPATIBLE:BOOL=ON
    -DTW_USE_EXTERNAL_PROTOC:BOOL=ON
    -Dutf8_range_DIR:PATH=${utf8_range_HOST_DIR}
    ${_MSVC_RUNTIME_LIBRARY}
    ${_PROTOBUF_PLUGIN_ZLIB_PACKAGE_ARGS}
    ${_PROTOBUF_PLUGIN_EXTRA_CACHE_ARGS}
    DEPENDS ${PROTOBUF_TARGET}
)
ExternalProject_Get_Property(protobuf-plugin INSTALL_DIR)
set(ProtobufPlugin_DIR ${INSTALL_DIR})

# wallet-core
if(NOT DEFINED _WALLET_CORE_GENERATE_SCRIPT)
    set(_WALLET_CORE_GENERATE_SCRIPT "${THIRDPARTY_DIR}/wallet-core/tools/generate-files")
endif()

STRING(TOLOWER ${CMAKE_SYSTEM_NAME} _WALLET_CORE_ARCH)

ExternalProject_Add(wallet-core
    PREFIX wallet-core
    SOURCE_DIR "${THIRDPARTY_DIR}/wallet-core"
    CMAKE_CACHE_ARGS
    -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>
    # Use the in-tree json submodule checkout (v3.12.0) instead of wallet-core's own
    # pinned copy, which predates the std::char_traits<unsigned char> fix (issue #114).
    -DWALLET_CORE_JSON_INCLUDE_DIR:PATH=${THIRDPARTY_DIR}/json/include
    -Dabsl_DIR:PATH=${absl_DIR}
    -DProtobuf_DIR:PATH=${Protobuf_DIR}
    -Dprotobuf_MODULE_COMPATIBLE:BOOL=ON
    -DTESTING:BOOL=${TESTING}
    -DTW_BUILD_EXAMPLES:BOOL=OFF
    -DTW_STATIC_LIBRARY:BOOL=ON
    -DTW_UNIT_TESTS:BOOL=OFF
    -DTW_USE_EXTERNAL_PROTOC:BOOL=ON
    ${_WALLET_CORE_EXTRA_CACHE_ARGS}
    -Dutf8_range_DIR:PATH=${utf8_range_DIR}
    ${_CMAKE_COMMON_CACHE_ARGS}
    ${_BOOST_CACHE_ARGS}
    ${_OPENSSL_CACHE_ARGS}
    ${_ZLIB_PACKAGE_ARGS}
    # Remove the rust fat lib before generate-files so rust-bindgen's stamp check
    # doesn't short-circuit a second config (e.g. Release after Debug) and skip
    # building the correct config's artifact.
    PATCH_COMMAND ${CMAKE_COMMAND} -E rm -f "${THIRDPARTY_DIR}/wallet-core/rust/target/libwallet_core_rs.a"
    COMMAND ${_WALLET_CORE_GENERATE_SCRIPT} --target-os=${_WALLET_CORE_ARCH} --arch-abi=${WALLET_CORE_ARCH_ABI} --protobuf-dir=${PROTOBUF_HOST_PREFIX} --out-dir=<INSTALL_DIR> --plugin-dir=${ProtobufPlugin_DIR}/bin --build-type=$<CONFIG>
    DEPENDS Boost protobuf openssl protobuf-plugin
    BUILD_BYPRODUCTS
    "${CMAKE_CURRENT_BINARY_DIR}/wallet-core/lib/libTrustWalletCore.a"
)

# libssh2
ExternalProject_Add(libssh2
    PREFIX libssh2
    SOURCE_DIR "${THIRDPARTY_DIR}/libssh2"
   CMAKE_CACHE_ARGS
    -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>
    ${_CMAKE_COMMON_CACHE_ARGS}
    -DCRYPTO_BACKEND:STRING=OpenSSL
    ${_ZLIB_PACKAGE_ARGS}
    ${_OPENSSL_CACHE_ARGS}
    DEPENDS openssl zlib
)

set(_FINDPACKAGE_LIBSSH2_CONFIG_DIR "${CMAKE_CURRENT_BINARY_DIR}/libssh2/lib/cmake/libssh2")
set(_FINDPACKAGE_LIBSSH2_LIBRARY_DIR "${CMAKE_CURRENT_BINARY_DIR}/libssh2/lib")
set(_FINDPACKAGE_LIBSSH2_INCLUDE_DIR "${CMAKE_CURRENT_BINARY_DIR}/libssh2/include")

# AsyncIOManager
ExternalProject_Add(AsyncIOManager
    PREFIX AsyncIOManager
    SOURCE_DIR "${THIRDPARTY_DIR}/AsyncIOManager"
   CMAKE_CACHE_ARGS
    -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>
    -Dabsl_DIR:PATH=${absl_DIR}
    -DBoost.DI_DIR:PATH=${_FINDPACKAGE_BOOST_DI_CONFIG_DIR}
    -Dc-ares_DIR:PATH=${_FINDPACKAGE_CARES_CONFIG_DIR}
    -DCBOR_INCLUDE_DIR:PATH=${_FINDPACKAGE_CBOR_INCLUDE_DIR}
    -Dfmt_DIR:PATH=${_FINDPACKAGE_FMT_CONFIG_DIR}
    -DGSL_INCLUDE_DIR:PATH=${_FINDPACKAGE_GSL_INCLUDE_DIR}
    -Dipfs-bitswap-cpp_DIR:PATH=${_FINDPACKAGE_IPFS_BITSWAP_CONFIG_DIR}
    -Dipfs-lite-cpp_DIR:PATH=${_FINDPACKAGE_IPFS_LITE_CONFIG_DIR}
    -Dipfs-lite-cpp_INCLUDE_DIR:PATH=${_FINDPACKAGE_IPFS_LITE_INCLUDE_DIR}
    -Dlibp2p_DIR:PATH=${_FINDPACKAGE_libp2p_CONFIG_DIR}
    -DLibssh2_DIR:PATH=${_FINDPACKAGE_LIBSSH2_CONFIG_DIR}
    -DMNN_DIR:PATH=${_FINDPACKAGE_MNN_CONFIG_DIR}
    -DMNN_INCLUDE_DIR:PATH=${_FINDPACKAGE_MNN_INCLUDE_DIR}
    -DProtobuf_DIR:PATH=${Protobuf_DIR}
    -DProtobuf_PROTOC_EXECUTABLE:FILEPATH=${PROTOC_EXECUTABLE}
    -DRocksDB_DIR:PATH=${_FINDPACKAGE_ROCKSDB_DIR}
    -DSnappy_DIR:PATH=${_FINDPACKAGE_SNAPPY_DIR}
    -Dsoralog_DIR:PATH=${_FINDPACKAGE_SORALOG_CONFIG_DIR}
    -Dspdlog_DIR:PATH=${_FINDPACKAGE_SPDLOG_CONFIG_DIR}
    -Dsqlite3_DIR:PATH=${_FINDPACKAGE_SQLITE3_CONFIG_DIR}
    -DSQLiteModernCpp_DIR:PATH=${_FINDPACKAGE_SQLITECPP_CONFIG_DIR}
    -Dtsl_hat_trie_DIR:PATH=${_FINDPACKAGE_TSL_HAT_TRIE_CONFIG_DIR}
    -Dutf8_range_DIR:PATH=${utf8_range_DIR}
    -Dyaml-cpp_DIR:PATH=${_FINDPACKAGE_YAMLCPP_CONFIG_DIR}
    ${_ZLIB_PACKAGE_ARGS}
    ${_BOOST_CACHE_ARGS}
    ${_OPENSSL_CACHE_ARGS}
    ${_CMAKE_COMMON_CACHE_ARGS}
    DEPENDS libssh2 openssl ipfs-lite-cpp ipfs-bitswap-cpp protobuf ${PROTOBUF_TARGET} Boost MNN
)

# Nlohmann JSON
# (lives here — above the minio-cpp entry — because minio-cpp's DEPENDS json
# requires the target to already exist at ExternalProject_Add time, and
# miniocpp-deps.cmake consumes the config-dir export directly below.)
ExternalProject_Add(json
    PREFIX json
    SOURCE_DIR "${THIRDPARTY_DIR}/json"
   CMAKE_CACHE_ARGS
    -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>
    -DJSON_BuildTests:BOOL=OFF
    ${_CMAKE_COMMON_CACHE_ARGS}
    ${_BOOST_CACHE_ARGS}
    ${_OPENSSL_CACHE_ARGS}
    DEPENDS Boost
)

# nlohmann_json config-dir export — consumed by minio-cpp's cmake/miniocpp-deps.cmake
# (find_package(nlohmann_json CONFIG REQUIRED), line 21). Declared here, before the
# minio-cpp entry below, because the minio-cpp ExternalProject must precede the
# sgns-blockstore entry (which consumes _FINDPACKAGE_MINIOCPP_CONFIG_DIR) while the
# json ExternalProject_Add itself sits later in this file. OBSERVED install layout
# (2026-10-21 spike): nlohmann_json's own CMake installs its config package to
# <prefix>/share/cmake/nlohmann_json (GNUInstallDirs datadir), NOT lib/cmake.
set(_FINDPACKAGE_JSON_CONFIG_DIR "${CMAKE_CURRENT_BINARY_DIR}/json/share/cmake/nlohmann_json")

# pugixml — provisioned per the BUILD-02/SC1 letter amendment (Q1, user-selected
# 2026-10-21): upstream's cmake/miniocpp-deps.cmake has NO source fallback for
# pugixml (hard FATAL_ERROR without a pre-provisioned package), so pugixml ships
# as its own upstream submodule (tag v1.16) with its own ExternalProject entry.
# The operative BUILD-02 red lines hold: upstream absolute URL (no fork),
# statically linked, non-exported; minio-cpp's own nested deps (cpp-httplib
# v0.53.1, inih r58) stay governed by upstream's pins (D-12). Separate entry
# coupled to minio-cpp only via DEPENDS + -Dpugixml_DIR — never merged targets.
ExternalProject_Add(pugixml
    PREFIX pugixml
    SOURCE_DIR "${THIRDPARTY_DIR}/pugixml"
   CMAKE_CACHE_ARGS
    -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>
    ${_CMAKE_COMMON_CACHE_ARGS}
    BUILD_BYPRODUCTS
    "${CMAKE_CURRENT_BINARY_DIR}/pugixml/lib/${CMAKE_STATIC_LIBRARY_PREFIX}pugixml${CMAKE_STATIC_LIBRARY_SUFFIX}"
)
set(_FINDPACKAGE_PUGIXML_CONFIG_DIR "${CMAKE_CURRENT_BINARY_DIR}/pugixml/lib/cmake/pugixml")

# minio-cpp — S3 client SDK behind sgns-blockstore's internal S3Client adapter
# seam (rocksdb-backup Phase 3, BUILD-02/BUILD-03). D-12: upstream's own
# dependency mechanism (cmake/miniocpp-deps.cmake) runs AS-IS at configure
# time — it git-clones cpp-httplib (pinned v0.53.1) and inih (pinned r58) into
# <binary>/_deps using upstream's own pins. NO PATCH_COMMAND, no GNUS pin file
# or fetch script; a clone failure fails the configure loudly (surfaced, never
# pre-solved). The Q1 pugixml provision + this D-12 posture amend BUILD-02's
# letter where the shaderc entry below documents its git-sync-deps patch.
# Short binary dir (shaderc trick): miniocpp-deps.cmake clones into
# ${CMAKE_CURRENT_BINARY_DIR}/_deps — the default (<prefix>/src/minio-cpp-build)
# pushes those MSBuild .tlog paths past the Windows MAX_PATH (260) limit on
# runners without OS long-path support. Must stay directly under a */src
# directory: build.yml's tarball step excludes build trees via
# --exclude='./*/src' — any other location leaks the whole _deps object tree
# into the release tarballs and blows the 2 GiB asset limit (HTTP 422).
ExternalProject_Add(minio-cpp
    PREFIX minio-cpp
    SOURCE_DIR "${THIRDPARTY_DIR}/minio-cpp"
    BINARY_DIR "${CMAKE_CURRENT_BINARY_DIR}/mcb/src"
   CMAKE_CACHE_ARGS
    -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>
    -DMINIO_CPP_TEST:BOOL=OFF
    -DMINIO_CPP_MAKE_DOC:BOOL=OFF
    -DMINIO_CPP_ENABLE_RDMA:BOOL=OFF
    # Deterministic httplib feature set across runner environments. cpp-httplib
    # v0.53.1's *_IF_AVAILABLE auto-detections (zstd/brotli default ON) bake
    # runner-dependent branches into the INSTALLED httplibConfig.cmake. With
    # zstd ON (Mac runners see Homebrew zstd >= 1.5.6), that config creates a
    # `zstd::libzstd` ALIAS on EVERY execution — and consumers execute it
    # TWICE (sgns-blockstore's explicit find_package(httplib) followed by
    # miniocpp-deps.cmake's QUIET re-find, which re-runs the config under
    # CMake >= 3.26 hash-guarded re-entry) -> "add_library cannot create ALIAS
    # zstd::libzstd ... already exists" (iOS leg, run 40608346530). OFF makes
    # the branch compile to if(0) everywhere, identical to the Windows install
    # tree; S3 traffic needs neither zstd nor brotli content-encoding.
    # HTTPLIB_USE_NON_BLOCKING_GETADDRINFO (default ON) compiles cpp-httplib's
    # glibc async-DNS path (getaddrinfo_a/gai_suspend/gai_cancel/gai_error)
    # into libminio.a; those symbols live in libanl, which nothing on the
    # link line pulls in, so every glibc-Linux executable linking miniocpp
    # fails with undefined references (Linux legs, run 40620972829). OFF
    # emits plain blocking getaddrinfo from libc and links everywhere;
    # DNS-resolution cost against fixed S3 endpoints is negligible.
    -DHTTPLIB_USE_NON_BLOCKING_GETADDRINFO:BOOL=OFF
    -DHTTPLIB_USE_ZSTD_IF_AVAILABLE:BOOL=OFF
    -DHTTPLIB_USE_BROTLI_IF_AVAILABLE:BOOL=OFF
    -Dpugixml_DIR:PATH=${_FINDPACKAGE_PUGIXML_CONFIG_DIR}
    -Dnlohmann_json_DIR:PATH=${_FINDPACKAGE_JSON_CONFIG_DIR}
    ${_ZLIB_PACKAGE_ARGS}
    ${_OPENSSL_CACHE_ARGS}
    # The CMAKE_TOOLCHAIN_FILE arg inside _CMAKE_COMMON_CACHE_ARGS (defined but
    # empty on desktop builds) also neutralizes minio-cpp's VCPKG_ROOT
    # auto-toolchain hijack — do not remove it (03-RESEARCH.md Pitfall 5).
    ${_CMAKE_COMMON_CACHE_ARGS}
    # Same FindZLIB-shim posture as the sgns-blockstore entry below: with
    # PREFER_CONFIG=ON (forced by _CMAKE_COMMON_CACHE_ARGS), miniocpp-deps.cmake's
    # find_package(ZLIB) loads ZLIBConfig.cmake, whose @PACKAGE_INIT@ corrupts
    # httplibConfig.cmake's set_and_check header-path validation with the zlib
    # prefix. Harmless on fresh CI trees (no install tree yet -> httplib is
    # built from source and the installed config never loads), but ANY
    # incremental reconfigure of this entry finds the previously installed
    # httplibConfig via CMAKE_INSTALL_PREFIX (a standard search prefix) and
    # dies on "HTTPLIB_HEADER_PATH ... zlib/include/httplib.h does not exist".
    # The shim imports the zlib targets file directly and PREFER_CONFIG=OFF
    # (must follow _CMAKE_COMMON_CACHE_ARGS to win) keeps ZLIB in module mode.
    -DCMAKE_MODULE_PATH:PATH=${CMAKE_CURRENT_SOURCE_DIR}/../cmake
    -DZLIB_SUPERBUILD_TARGETS_FILE:FILEPATH=${CMAKE_CURRENT_BINARY_DIR}/zlib/lib/cmake/zlib/ZLIB-static.cmake
    -DCMAKE_FIND_PACKAGE_PREFER_CONFIG:BOOL=OFF
    # miniocpp-deps.cmake does REQUIRED find_package calls for OpenSSL (line
    # 19) and ZLIB (line 20) at configure time, so the sub-configure MUST NOT
    # run before those superbuild installs exist. Without the explicit deps,
    # clean CI builds race them (run 40608346530): Windows failed "Could NOT
    # find OpenSSL" while openssl was still compiling; Android's configure
    # fell back to the HOST x86_64 libcrypto (/usr/lib/x86_64-linux-gnu) and
    # the cross-build of signer.cc then died on a missing openssl/evp.h
    # include path for the NDK target.
    DEPENDS pugixml json zlib openssl
    # NOTE the artifact name: target miniocpp, OUTPUT_NAME minio
    # -> libminio.a / minio.lib (never libminiocpp).
    BUILD_BYPRODUCTS
    "${CMAKE_CURRENT_BINARY_DIR}/minio-cpp/lib/${CMAKE_STATIC_LIBRARY_PREFIX}minio${CMAKE_STATIC_LIBRARY_SUFFIX}"
)
set(_FINDPACKAGE_MINIOCPP_CONFIG_DIR "${CMAKE_CURRENT_BINARY_DIR}/minio-cpp/lib/cmake/miniocpp")

# sgns-blockstore
ExternalProject_Add(sgns-blockstore
    PREFIX sgns-blockstore
    SOURCE_DIR "${THIRDPARTY_DIR}/sgns-blockstore"
   CMAKE_CACHE_ARGS
    -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>
    -Dabsl_DIR:PATH=${absl_DIR}
    -DBoost.DI_DIR:PATH=${_FINDPACKAGE_BOOST_DI_CONFIG_DIR}
    -Dc-ares_DIR:PATH=${_FINDPACKAGE_CARES_CONFIG_DIR}
    -Dfmt_DIR:PATH=${_FINDPACKAGE_FMT_CONFIG_DIR}
    -DGSL_INCLUDE_DIR:PATH=${_FINDPACKAGE_GSL_INCLUDE_DIR}
    -DGTest_DIR:PATH=${_FINDPACKAGE_GTEST_CONFIG_DIR}
    -Dhttplib_DIR:PATH=${CMAKE_CURRENT_BINARY_DIR}/minio-cpp/lib/cmake/httplib
    -Dipfs-lite-cpp_DIR:PATH=${_FINDPACKAGE_IPFS_LITE_CONFIG_DIR}
    -Dlibp2p_DIR:PATH=${_FINDPACKAGE_libp2p_CONFIG_DIR}
    -Dminiocpp_DIR:PATH=${_FINDPACKAGE_MINIOCPP_CONFIG_DIR}
    # The consumer-side miniocpp-config.cmake re-runs miniocpp-deps.cmake in
    # THIS project's context (nlohmann_json/httplib/pugixml must resolve here
    # too; inih is reused via the exported miniocpp::miniocpp_inih target).
    -Dnlohmann_json_DIR:PATH=${_FINDPACKAGE_JSON_CONFIG_DIR}
    -Dpugixml_DIR:PATH=${_FINDPACKAGE_PUGIXML_CONFIG_DIR}
    -DProtobuf_DIR:PATH=${Protobuf_DIR}
    -DRocksDB_DIR:PATH=${_FINDPACKAGE_ROCKSDB_DIR}
    -DSnappy_DIR:PATH=${_FINDPACKAGE_SNAPPY_DIR}
    -Dsoralog_DIR:PATH=${_FINDPACKAGE_SORALOG_CONFIG_DIR}
    -Dspdlog_DIR:PATH=${_FINDPACKAGE_SPDLOG_CONFIG_DIR}
    -Dsqlite3_dir:PATH=${_FINDPACKAGE_SQLITE3_CONFIG_DIR}
    -DSQLiteModernCpp_DIR:PATH=${_FINDPACKAGE_SQLITECPP_CONFIG_DIR}
    -Dtsl_hat_trie_DIR:PATH=${_FINDPACKAGE_TSL_HAT_TRIE_CONFIG_DIR}
    -Dutf8_range_DIR:PATH=${utf8_range_DIR}
    -Dyaml-cpp_DIR:PATH=${_FINDPACKAGE_YAMLCPP_CONFIG_DIR}
    # ZLIB resolves through the superbuild-local FindZLIB module override
    # (NEVER config mode in this entry): cpp-httplib v0.53.1's installed
    # config re-runs find_package(ZLIB) via CMake >= 3.26's hash-guarded
    # find_dependency, and ZLIBConfig.cmake's @PACKAGE_INIT@ macros then
    # corrupt httplibConfig.cmake's header-path check with the zlib prefix
    # (rocksdb-backup Phase-3 spike finding, 2026-10-21). The shim imports
    # the zlib targets file directly - see thirdparty/build/cmake/FindZLIB.cmake.
    -DCMAKE_MODULE_PATH:PATH=${CMAKE_CURRENT_SOURCE_DIR}/../cmake
    -DZLIB_SUPERBUILD_TARGETS_FILE:FILEPATH=${CMAKE_CURRENT_BINARY_DIR}/zlib/lib/cmake/zlib/ZLIB-static.cmake
    ${_BOOST_CACHE_ARGS}
    ${_OPENSSL_CACHE_ARGS}
    ${_CMAKE_COMMON_CACHE_ARGS}
    # MUST stay the LAST cache arg: _CMAKE_COMMON_CACHE_ARGS forces
    # -DBUILD_TESTING:BOOL=OFF above, and later cache args win under
    # ExternalProject's initial-cache FORCE semantics. The repo's test gate
    # is named TESTING (never BUILD_TESTING), so this is what re-enables
    # tests through the superbuild.
    # PREFER_CONFIG must come after _CMAKE_COMMON_CACHE_ARGS too (it forces
    # =ON at CommonCompilerOptions.cmake:122): config-first re-routes the
    # httplib chain's ZLIB find into ZLIBConfig.cmake and defeats the
    # FindZLIB shim above.
    -DCMAKE_FIND_PACKAGE_PREFER_CONFIG:BOOL=OFF
    -DTESTING:BOOL=ON
    DEPENDS libp2p rocksdb minio-cpp ipfs-lite-cpp
    BUILD_BYPRODUCTS
    "${CMAKE_CURRENT_BINARY_DIR}/sgns-blockstore/lib/${CMAKE_STATIC_LIBRARY_PREFIX}sgns-blockstore${CMAKE_STATIC_LIBRARY_SUFFIX}"
)
set(_FINDPACKAGE_SGNS_BLOCKSTORE_CONFIG_DIR "${CMAKE_CURRENT_BINARY_DIR}/sgns-blockstore/lib/cmake/sgns-blockstore")

# gnus_upnp
ExternalProject_Add(gnus_upnp
    PREFIX gnus_upnp
    SOURCE_DIR "${THIRDPARTY_DIR}/gnus_upnp"
   CMAKE_CACHE_ARGS
    -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>
    ${_CMAKE_COMMON_CACHE_ARGS}
    -DBoost.DI_DIR:PATH=${_FINDPACKAGE_BOOST_DI_CONFIG_DIR}
    -Dfmt_DIR:PATH=${_FINDPACKAGE_FMT_CONFIG_DIR}
    -DGSL_INCLUDE_DIR:PATH=${_FINDPACKAGE_GSL_INCLUDE_DIR}
    -Dtsl_hat_trie_DIR:PATH=${_FINDPACKAGE_TSL_HAT_TRIE_CONFIG_DIR}
    -Dyaml-cpp_DIR:PATH=${_FINDPACKAGE_YAMLCPP_CONFIG_DIR}
    -Dspdlog_DIR:PATH=${_FINDPACKAGE_SPDLOG_CONFIG_DIR}
    ${_BOOST_CACHE_ARGS}
    ${_OPENSSL_CACHE_ARGS}
    DEPENDS Boost fmt spdlog tsl_hat_trie yaml-cpp
)

