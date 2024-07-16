cmake_minimum_required(VERSION 3.22)

cmake_policy(SET CMP0091 NEW)

project(WINDOWS_SHARED_THIRD_PARTY LANGUAGES C CXX)

# This speeds up build time when using `--parallel`
if(NOT CMAKE_VS_GLOBALS MATCHES "(^|;)UseMultiToolTask=")
    list(APPEND CMAKE_VS_GLOBALS UseMultiToolTask=true)
endif()

if(NOT CMAKE_VS_GLOBALS MATCHES "(^|;)EnforceProcessCountAcrossBuilds=")
    list(APPEND CMAKE_VS_GLOBALS EnforceProcessCountAcrossBuilds=true)
endif()

include(../CommonCompilerOptions.CMake)

set(_WALLET_CORE_GENERATE_SCRIPT "${THIRDPARTY_DIR}/wallet-core/tools/win-generate-files.bat")

# Set Windows specific protobuf options
set(_PROTOBUF_CONFIG_DIR "${CMAKE_CURRENT_BINARY_DIR}/grpc/cmake")

# Set Boost Windows specific configurations
set(VC_PLATFORMTOOLSET "vc193")
set(BOOST_TOOLSET "msvc-14.1")

if(MSVC_VERSION AND MSVC_VERSION GREATER_EQUAL 1920) # v142 toolset
    set(VC_PLATFORMTOOLSET "vc142")
endif()

if(MSVC_VERSION AND MSVC_VERSION GREATER_EQUAL 1930) # v143 toolset
    set(VC_PLATFORMTOOLSET "vc143")
endif()

# Boost
set(BOOST_ROOT "${CMAKE_CURRENT_BINARY_DIR}/boost/build/${CMAKE_SYSTEM_NAME}")

list(TRANSFORM BOOST_INCLUDE_LIBRARIES PREPEND --with- OUTPUT_VARIABLE BOOST_INCLUDE_LIBRARIES_EXPANDED)
ExternalProject_Add(Boost
    PREFIX boost
    SOURCE_DIR "${THIRDPARTY_DIR}/boost"
    INSTALL_DIR "${BOOST_ROOT}"

    CONFIGURE_COMMAND ./bootstrap.bat ${VC_PLATFORMTOOLSET}

    BUILD_COMMAND <SOURCE_DIR>/b2${CMAKE_EXECUTABLE_SUFFIX} cxxstd=${CMAKE_CXX_STANDARD} visibility=global runtime-link=static link=static threading=multi --build-type=minimal ${BOOST_INCLUDE_LIBRARIES_EXPANDED} address-model=64 architecture=x86 variant=${BOOST_VARIANT} --prefix=${BOOST_ROOT} -d0 install
    BUILD_IN_SOURCE TRUE

    INSTALL_COMMAND ""
)

set(Boost_DIR "${BOOST_ROOT}/lib/cmake")

# not sure why this can't match the exaxt ${BOOST_VERSION} string of everything else.
set(Boost_INCLUDE_DIR "${BOOST_ROOT}/include/boost-${BOOST_VERSION_2U}")

set(_BOOST_CACHE_ARGS
    -DBOOST_ROOT:PATH=${BOOST_ROOT}
    -DBoost_DIR:PATH=${Boost_DIR}/Boost-${BOOST_VERSION}
    -DBoost_INCLUDE_DIR:PATH=${Boost_INCLUDE_DIR}
    -Dboost_headers_DIR:PATH=${Boost_DIR}/boost_headers-${BOOST_VERSION}
    -Dboost_date_time_DIR:PATH=${Boost_DIR}/boost_date_time-${BOOST_VERSION}
    -Dboost_filesystem_DIR:PATH=${Boost_DIR}/boost_filesystem-${BOOST_VERSION}
    -Dboost_program_options_DIR:PATH=${Boost_DIR}/boost_program_options-${BOOST_VERSION}
    -Dboost_random_DIR:PATH=${Boost_DIR}/boost_random-${BOOST_VERSION}
    -Dboost_regex_DIR:PATH=${Boost_DIR}/boost_regex-${BOOST_VERSION}
    -Dboost_system_DIR:PATH=${Boost_DIR}/boost_system-${BOOST_VERSION}
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
    CONFIGURE_COMMAND perl ${THIRDPARTY_DIR}/openssl/Configure ${OPENSSL_VARIANT} enable-capieng no-shared no-asm --prefix=${OPENSSL_ROOT_DIR} --openssldir=${OPENSSL_ROOT_DIR} --libdir=lib -static VC-WIN64A
    BUILD_COMMAND nmake build_libs
    BUILD_IN_SOURCE false
    INSTALL_COMMAND nmake install_dev
)

if(${CMAKE_SYSTEM_NAME} STREQUAL "Windows" AND $<CONFIG:Debug>)
    ExternalProject_Add_Step(openssl AddDebugSuffix
        DEPENDEES install
        COMMAND ${CMAKE_COMMAND} -E rename ${OPENSSL_ROOT_DIR}/lib/libcrypto.lib ${OPENSSL_ROOT_DIR}/lib/libcryptod.lib
        COMMAND ${CMAKE_COMMAND} -E rename ${OPENSSL_ROOT_DIR}/lib/libssl.lib ${OPENSSL_ROOT_DIR}/lib/libssld.lib
    )
endif()

set(OPENSSL_INCLUDE_DIR ${OPENSSL_ROOT_DIR}/include)
set(_OPENSSL_CACHE_ARGS
    -DOPENSSL_USE_STATIC_LIBS:BOOL=ON
    -DOPENSSL_MSVC_STATIC_RT:BOOL=ON
    -DOPENSSL_ROOT_DIR:PATH=${OPENSSL_ROOT_DIR}
    -DOpenSSL_DIR:PATH=${OPENSSL_ROOT_DIR}/lib/cmake/OpenSSL
)

# ed25519 crypto
set(_ED25519_RANDOM bcryptgen)

# eliminates some warnings on windows
set(libp2_EXTRA_PARAM
    -D_WIN32_WINNT:STRING=_WIN32_WINNT_WIN7
)

set(ipfs-lite-cpp_EXTRA_PARAM
    -D_WIN32_WINNT:STRING=_WIN32_WINNT_WIN7
)

set(ipfs-pubsub_EXTRA_PARAM
    -D_WIN32_WINNT:STRING=_WIN32_WINNT_WIN7
)

set(ipfs-bitswap-cpp_EXTRA_PARAM
    -D_WIN32_WINNT:STRING=_WIN32_WINNT_WIN7
)

# Allow multiple definitions
set(MULTIPLE_OPTION /FORCE:MULTIPLE)

# for rocksdb windows needs > windows 8
set(rocksdb_EXTRA_PARAM
    -D_WIN32_WINNT:STRING=_WIN32_WINNT_WIN8
)

# build common targets
include(../CommonTargets.CMake)
