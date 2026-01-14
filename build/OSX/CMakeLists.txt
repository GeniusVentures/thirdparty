cmake_minimum_required(VERSION 3.22)

if(NOT DEFINED CMAKE_TOOLCHAIN_FILE)
    set(_PLATFORM "MAC_UNIVERSAL" CACHE STRING "Setting the build for both x86_64 and arm64")

    set(NAMED_LANGUAGE_SUPPORT ON CACHE BOOL "Toolchain named language support parameter")
    set(ENABLE_BITCODE OFF CACHE BOOL "Toolchain bitcode enable parameter")
    set(ENABLE_ARC OFF CACHE BOOL "Toolchain enable arc parameter")
    set(ENABLE_VISIBILITY ON CACHE BOOL "Toolchain visibility parameter")
    set(ENABLE_STRICT_TRY_COMPILE OFF CACHE BOOL "Toolchain try_compile enable parameter")
    set(PLATFORM ${_PLATFORM} CACHE STRING "Toolchain platform parameter")
    set(DEPLOYMENT_TARGET "13.0" CACHE STRING "Minimum OSX version")
    set(CMAKE_TOOLCHAIN_FILE "${CMAKE_CURRENT_SOURCE_DIR}/../apple.toolchain.cmake" CACHE STRING "Toolchain file")
endif()

project(OSX_SHARED_THIRD_PARTY LANGUAGES C CXX)

include(../CommonCompilerOptions.CMake)

# OSX specific runtime options
set(_CMAKE_COMMON_CACHE_ARGS ${_CMAKE_COMMON_CACHE_ARGS}
    -DPLATFORM:STRING=${PLATFORM}
    -DDEPLOYMENT_TARGET:STRING=${DEPLOYMENT_TARGET}
    -DNAMED_LANGUAGE_SUPPORT:BOOL=${NAMED_LANGUAGE_SUPPORT}
    -DENABLE_BITCODE:BOOL=${ENABLE_BITCODE}
    -DENABLE_ARC:BOOL=${ENABLE_ARC}
    -DENABLE_VISIBILITY:BOOL=${ENABLE_VISIBILITY}
    -DENABLE_STRICT_TRY_COMPILE:BOOL=${ENABLE_STRICT_TRY_COMPILE}
)

# Boost
set(BOOST_ARCH "arm+x86")

set(BOOST_ROOT "${CMAKE_CURRENT_BINARY_DIR}/boost/build")
ExternalProject_Add(Boost
    PREFIX boost
    SOURCE_DIR "${THIRDPARTY_DIR}/boost"
    INSTALL_DIR ${BOOST_ROOT}

    CONFIGURE_COMMAND ${CMAKE_COMMAND} -E env MACOSX_DEPLOYMENT_TARGET=${DEPLOYMENT_TARGET} <SOURCE_DIR>/bootstrap.sh --with-toolset=clang --with-libraries=${BOOST_INCLUDE_LIBRARIES_COMMA_SEPARATED} --prefix=${BOOST_ROOT}

    BUILD_COMMAND ${CMAKE_COMMAND} -E env MACOSX_DEPLOYMENT_TARGET=${DEPLOYMENT_TARGET} <SOURCE_DIR>/b2${CMAKE_EXECUTABLE_SUFFIX} ${BOOST_B2_FLAGS} toolset=clang cxxstd=${CMAKE_CXX_STANDARD} visibility=global runtime-link=static link=static threading=multi --build-type=minimal address-model=64 architecture=${BOOST_ARCH} variant=${BOOST_VARIANT} --prefix=${BOOST_ROOT} -j4 install
    BUILD_IN_SOURCE TRUE

    INSTALL_COMMAND ""
    BUILD_BYPRODUCTS
    "${BOOST_ROOT}/lib/libboost_container.a"
    "${BOOST_ROOT}/lib/libboost_program_options.a"
    "${BOOST_ROOT}/lib/libboost_random.a"
    "${BOOST_ROOT}/lib/libboost_regex.a"
    "${BOOST_ROOT}/lib/libboost_system.a"
    "${BOOST_ROOT}/lib/libboost_prg_exec_monitor.a"
    "${BOOST_ROOT}/lib/libboost_test_exec_monitor.a"
    "${BOOST_ROOT}/lib/libboost_unit_test_framework.a"
    "${BOOST_ROOT}/lib/libboost_timer.a"
    "${BOOST_ROOT}/lib/libboost_date_time.a"
    "${BOOST_ROOT}/lib/libboost_atomic.a"
    "${BOOST_ROOT}/lib/libboost_filesystem.a"
    "${BOOST_ROOT}/lib/libboost_json.a"
    "${BOOST_ROOT}/lib/libboost_thread.a"
    "${BOOST_ROOT}/lib/libboost_chrono.a"
    "${BOOST_ROOT}/lib/libboost_log.a"
    "${BOOST_ROOT}/lib/libboost_log_setup.a"

)

set(Boost_DIR "${BOOST_ROOT}/lib/cmake/Boost-${BOOST_VERSION}")
set(Boost_INCLUDE_DIR "${BOOST_ROOT}/include")
set(boost_headers_DIR "${BOOST_ROOT}/lib/cmake/boost_headers-${BOOST_VERSION}")
set(boost_date_time_DIR "${BOOST_ROOT}/lib/cmake/boost_date_time-${BOOST_VERSION}")
set(boost_filesystem_DIR "${BOOST_ROOT}/lib/cmake/boost_filesystem-${BOOST_VERSION}")
set(boost_program_options_DIR "${BOOST_ROOT}/lib/cmake/boost_program_options-${BOOST_VERSION}")
set(boost_random_DIR "${BOOST_ROOT}/lib/cmake/boost_random-${BOOST_VERSION}")
set(boost_regex_DIR "${BOOST_ROOT}/lib/cmake/boost_regex-${BOOST_VERSION}")
set(boost_system_DIR "${BOOST_ROOT}/lib/cmake/boost_system-${BOOST_VERSION}")

set(_BOOST_CACHE_ARGS
    -DBOOST_ROOT:PATH=${BOOST_ROOT}
    -DBoost_DIR:PATH=${Boost_DIR}
    -DBoost_INCLUDE_DIR:PATH=${Boost_INCLUDE_DIR}
    -Dboost_date_time_DIR:PATH=${boost_date-time_DIR}
    -Dboost_filesystem_DIR:PATH=${boost_filesystem_DIR}
    -Dboost_headers_DIR:PATH=${boost_headers_DIR}
    -Dboost_program_options_DIR:PATH=${boost_program_options_DIR}
    -Dboost_random_DIR:PATH=${boost_random_DIR}
    -Dboost_regex_DIR:PATH=${boost_regex_DIR}
    -Dboost_system_DIR:PATH=${boost_system_DIR}
    -DBoost_NO_SYSTEM_PATHS:BOOL=ON
    -DBoost_USE_MULTITHREADED:BOOL=ON
    -DBoost_USE_STATIC_LIBS:BOOL=ON
    -DBoost_USE_STATIC_RUNTIME:BOOL=ON
)

# OpenSSL
set(OPENSSL_ROOT_DIR "${CMAKE_CURRENT_BINARY_DIR}/openssl/build")
set(OPENSSL_VARIANT "$<IF:$<CONFIG:Debug>,--debug,--release>")

ExternalProject_Add(openssl
    PREFIX openssl
    SOURCE_DIR "${THIRDPARTY_DIR}/openssl"
    CONFIGURE_COMMAND ""
    PATCH_COMMAND ""
    BUILD_COMMAND ${CMAKE_CURRENT_LIST_DIR}/Openssl-build/build.sh ${OPENSSL_VARIANT} --deployment-target="${DEPLOYMENT_TARGET}" --src-dir=<SOURCE_DIR> --build-dir=${OPENSSL_ROOT_DIR} --arch=${OSX_ARCHITECTURES_PIPE_SEPARATED}
    BUILD_IN_SOURCE FALSE
    INSTALL_COMMAND touch ${OPENSSL_ROOT_DIR}/openssl.stamp
    UPDATE_COMMAND ""
    BUILD_BYPRODUCTS
    ${OPENSSL_ROOT_DIR}/openssl.stamp
    ${OPENSSL_ROOT_DIR}/lib/libssl.a
    ${OPENSSL_ROOT_DIR}/lib/libcrypto.a
    ${OPENSSL_ROOT_DIR}/include/openssl/ssl.h
    ${OPENSSL_ROOT_DIR}/include/openssl/crypto.h
)

set(OPENSSL_INCLUDE_DIR ${OPENSSL_ROOT_DIR}/include)
set(_OPENSSL_CACHE_ARGS
    -DOPENSSL_USE_STATIC_LIBS:BOOL=ON
    -DOPENSSL_ROOT_DIR:PATH=${OPENSSL_ROOT_DIR}
    -DOpenSSL_DIR:PATH=${OPENSSL_ROOT_DIR}/lib/cmake/OpenSSL
)

# MoltenVK
set(_MVK_ROOT "${CMAKE_CURRENT_BINARY_DIR}/MoltenVK/build/")
ExternalProject_Add(MoltenVK
    PREFIX moltenvk
    SOURCE_DIR "${THIRDPARTY_DIR}/MoltenVK"
    CONFIGURE_COMMAND ""
    PATCH_COMMAND ""
    BUILD_COMMAND ${CMAKE_CURRENT_LIST_DIR}/MoltenVK-build/build.sh ${BOOST_BUILD_VARIANT} --build-dir=${_MVK_ROOT} --src-dir=${THIRDPARTY_DIR}/MoltenVK --deployment-target=${CMAKE_OSX_DEPLOYMENT_TARGET}
    INSTALL_COMMAND ""
    UPDATE_COMMAND ""
    BUILD_BYPRODUCTS
    "${_MVK_ROOT}/lib/MoltenVK.xcframework"
)

# ed25519 crypto
set(_ED25519_RANDOM dev_urandom)

# MNN
set(_MNN_EXTRA_PARAM
    -DMNN_USE_SYSTEM_LIB:BOOL=ON
    -DVulkan_INCLUDE_DIR:PATH=${CMAKE_CURRENT_BINARY_DIR}/moltenvk/build/include
    -DVulkan_LIBRARY:PATH=${CMAKE_CURRENT_BINARY_DIR}/moltenvk/build/lib/MoltenVK.xcframework
)
set(_MNN_DEPENDS MoltenVK)

set(_ZKLLVM_EXTRA_PARAM
    -DZKLLVM_BUILD_TRANSPILER_LIB:BOOL=OFF
    -DZKLLVM_BUILD_EXAMPLES:BOOL=OFF
    -DZKLLVM_BUILD_STD_LIB:BOOL=ON
    -DZKLLVM_BUILD_EXECUTABLES:BOOL=OFF
    -DZKLLVM_BUILD_OSX_FAT_BINARY:BOOL=ON
    -DLLVM_INCLUDE_UTILS:BOOL=OFF
    -DLLVM_INCLUDE_TESTS:BOOL=OFF
)
# MNN Has separate source files for x86 and ARM, so I think we need to build twice and lipo combine
ExternalProject_Add(MNN_X86
    PREFIX MNN
    SOURCE_DIR "${THIRDPARTY_DIR}/MNN"
    CMAKE_CACHE_ARGS
    ${_CMAKE_COMMON_CACHE_ARGS}
    -DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_CURRENT_BINARY_DIR}/MNN/x86_64
    -DPLATFORM:STRING=MAC
    -DDEPLOYMENT_TARGET:STRING=${DEPLOYMENT_TARGET}
    -DNAMED_LANGUAGE_SUPPORT:BOOL=${NAMED_LANGUAGE_SUPPORT}
    -DENABLE_BITCODE:BOOL=${ENABLE_BITCODE}
    -DENABLE_ARC:BOOL=${ENABLE_ARC}
    -DENABLE_VISIBILITY:BOOL=${ENABLE_VISIBILITY}
    -DENABLE_STRICT_TRY_COMPILE:BOOL=${ENABLE_STRICT_TRY_COMPILE}
    -DMNN_BUILD_SHARED_LIBS:BOOL=OFF
    -DMNN_BUILD_TESTS:BOOL=OFF
    -DMNN_BUILD_TOOLS:BOOL=OFF
    -DMNN_BUILD_PROTOBUFFER:BOOL=OFF
    -DMNN_VULKAN:BOOL=ON
    -DMNN_WIN_RUNTIME_MT:BOOL=ON
    ${_MNN_EXTRA_PARAM}
    DEPENDS ${_MNN_DEPENDS}
    BUILD_BYPRODUCTS
    "${CMAKE_CURRENT_BINARY_DIR}/MNN/x86_64/lib/libMNN.a"
)

ExternalProject_Add(MNN_ARM
    PREFIX MNN
    SOURCE_DIR "${THIRDPARTY_DIR}/MNN"
    CMAKE_CACHE_ARGS
    ${_CMAKE_COMMON_CACHE_ARGS}
    -DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_CURRENT_BINARY_DIR}/MNN/arm64
    -DPLATFORM:STRING=MAC_ARM64
    -DDEPLOYMENT_TARGET:STRING=${DEPLOYMENT_TARGET}
    -DNAMED_LANGUAGE_SUPPORT:BOOL=${NAMED_LANGUAGE_SUPPORT}
    -DENABLE_BITCODE:BOOL=${ENABLE_BITCODE}
    -DENABLE_ARC:BOOL=${ENABLE_ARC}
    -DENABLE_VISIBILITY:BOOL=${ENABLE_VISIBILITY}
    -DENABLE_STRICT_TRY_COMPILE:BOOL=${ENABLE_STRICT_TRY_COMPILE}
    -DMNN_BUILD_SHARED_LIBS:BOOL=OFF
    -DMNN_BUILD_TESTS:BOOL=OFF
    -DMNN_BUILD_TOOLS:BOOL=OFF
    -DMNN_BUILD_PROTOBUFFER:BOOL=OFF
    -DMNN_VULKAN:BOOL=ON
    -DMNN_WIN_RUNTIME_MT:BOOL=ON
    ${_MNN_EXTRA_PARAM}
    DEPENDS ${_MNN_DEPENDS}
    BUILD_BYPRODUCTS
    "${CMAKE_CURRENT_BINARY_DIR}/MNN/arm64/lib/libMNN.a"
)

set(MNN_X86_LIB "${CMAKE_CURRENT_BINARY_DIR}/MNN/x86_64/lib/libMNN.a")
set(MNN_ARM_LIB "${CMAKE_CURRENT_BINARY_DIR}/MNN/arm64/lib/libMNN.a")
set(MNN_FAT_LIB "${CMAKE_CURRENT_BINARY_DIR}/MNN/lib/libMNN.a")

# Ensure the destination directory exists
file(MAKE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/MNN/lib/cmake/MNN)
set(MNN_X86_CMAKE_DIR "${CMAKE_CURRENT_BINARY_DIR}/MNN/x86_64/lib/cmake/MNN")
set(MNN_ARM_CMAKE_DIR "${CMAKE_CURRENT_BINARY_DIR}/MNN/arm64/lib/cmake/MNN")
set(MNN_FAT_CMAKE_DIR "${CMAKE_CURRENT_BINARY_DIR}/MNN/lib/cmake/MNN")

# Add custom command to create fat library
add_custom_command(
    OUTPUT ${MNN_FAT_LIB}
    COMMAND lipo -create -output ${MNN_FAT_LIB} ${MNN_X86_LIB} ${MNN_ARM_LIB}
    DEPENDS MNN_ARM MNN_X86
    COMMENT "Creating fat library for MNN..."
)

# Add target for fat library
add_custom_target(MNN_Fat ALL
    DEPENDS ${MNN_FAT_LIB})

# Ensure the destination directory exists
file(MAKE_DIRECTORY ${MNN_FAT_CMAKE_DIR})
file(MAKE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/MNN/include)

# Copy CMake configuration files
add_custom_command(
    OUTPUT ${MNN_FAT_CMAKE_DIR}/MNNConfig.cmake
    COMMAND ${CMAKE_COMMAND} -E copy_directory
    ${MNN_X86_CMAKE_DIR}
    ${MNN_FAT_CMAKE_DIR}
    DEPENDS MNN_Fat
    COMMENT "Copying CMake configuration files for MNN..."
)

# Add target for copying CMake files
add_custom_target(MNN_CMakeFiles ALL
    DEPENDS ${MNN_FAT_CMAKE_DIR}/MNNConfig.cmake)

# Copy include files from arm64 directory to base include directory
add_custom_command(
    OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/MNN/include/MNN/MNNDefine.h
    COMMAND ${CMAKE_COMMAND} -E copy_directory
    ${CMAKE_CURRENT_BINARY_DIR}/MNN/arm64/include
    ${CMAKE_CURRENT_BINARY_DIR}/MNN/include
    DEPENDS MNN_Fat
    COMMENT "Copying include files for MNN..."
)

# Add a target for copying include files
add_custom_target(MNN_IncludeFiles ALL
    DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/MNN/include/MNN/MNNDefine.h)

set(_FINDPACKAGE_MNN_CONFIG_DIR "${CMAKE_CURRENT_BINARY_DIR}/MNN/lib/cmake/MNN")
set(_FINDPACKAGE_MNN_LIBRARY_DIR "${CMAKE_CURRENT_BINARY_DIR}/MNN/lib")
set(_FINDPACKAGE_MNN_INCLUDE_DIR "${CMAKE_CURRENT_BINARY_DIR}/MNN/include")


# Define the expected `MNN` target
add_custom_target(MNN ALL DEPENDS MNN_Fat MNN_CMakeFiles MNN_IncludeFiles)

unset(TOOLCHAIN_FILE_PROCESSED)

set(_EXT_ZKSTDLIB OFF)

include(../CommonTargets.CMake)
