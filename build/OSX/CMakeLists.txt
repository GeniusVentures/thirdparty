cmake_minimum_required(VERSION 3.22)

if(POLICY CMP0025)
    cmake_policy(SET CMP0025 NEW)
endif()

if(POLICY CMP0042)
    cmake_policy(SET CMP0042 NEW)
endif()

if(NOT DEFINED CMAKE_TOOLCHAIN_FILE)
    cmake_host_system_information(RESULT HOST_SYSTEM_PROCESSOR QUERY OS_PLATFORM)

    if(HOST_SYSTEM_PROCESSOR MATCHES "arm")
        set(_PLATFORM "MAC_ARM64")
    else()
        set(_PLATFORM "MAC")
    endif()
    set(NAMED_LANGUAGE_SUPPORT OFF CACHE BOOL "Toolchain named language support parameter")
    set(ENABLE_BITCODE OFF CACHE BOOL "Toolchain bitcode enable parameter")
    set(ENABLE_ARC OFF CACHE BOOL "Toolchain enable arc parameter")
    set(ENABLE_VISIBILITY ON CACHE BOOL "Toolchain visibility parameter")
    set(ENABLE_STRICT_TRY_COMPILE OFF CACHE BOOL "Toolchain try_compile enable parameter")
    set(PLATFORM ${_PLATFORM} CACHE STRING "Toolchain platform parameter")
    set(DEPLOYMENT_TARGET "12.1" CACHE STRING "Minimum OSX version")
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
set(BOOST_ROOT "${CMAKE_CURRENT_BINARY_DIR}/boost/build/${CMAKE_SYSTEM_NAME}")
ExternalProject_Add(Boost
    PREFIX boost
    SOURCE_DIR "${THIRDPARTY_DIR}/boost"
    INSTALL_DIR ${BOOST_ROOT}

    CONFIGURE_COMMAND <SOURCE_DIR>/bootstrap.sh --with-toolset=clang --with-libraries=${BOOST_INCLUDE_LIBRARIES_COMMA_SEPARATED} --prefix=${BOOST_ROOT}

    BUILD_COMMAND <SOURCE_DIR>/b2${CMAKE_EXECUTABLE_SUFFIX} ${BOOST_B2_FLAGS} toolset=darwin cxxstd=${CMAKE_CXX_STANDARD} visibility=global runtime-link=static link=static threading=multi --build-type=minimal address-model=64 architecture=x86 variant=${BOOST_VARIANT} --prefix=${BOOST_ROOT} install
    BUILD_IN_SOURCE TRUE

    INSTALL_COMMAND ""
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
set(OPENSSL_ROOT_DIR "${CMAKE_CURRENT_BINARY_DIR}/openssl/build/${CMAKE_SYSTEM_NAME}")

ExternalProject_Add(openssl
    PREFIX openssl
    SOURCE_DIR "${THIRDPARTY_DIR}/openssl"
    CONFIGURE_COMMAND <SOURCE_DIR>/Configure ${OPENSSL_VARIANT} --prefix=${OPENSSL_ROOT_DIR} --openssldir=${OPENSSL_ROOT_DIR} -mmacosx-version-min=12.1 --libdir=lib -static darwin64-${CMAKE_SYSTEM_PROCESSOR}-cc
    BUILD_COMMAND make build_libs
    BUILD_IN_SOURCE FALSE
    INSTALL_COMMAND make install_dev
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
)

# ed25519 crypto
set(_ED25519_RANDOM dev_urandom)

include(../CommonTargets.CMake)
