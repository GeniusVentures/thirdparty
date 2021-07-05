
cmake_minimum_required(VERSION 3.15)

# if on Linux system, build the Linux executables
if (NOT ${CMAKE_HOST_SYSTEM_NAME} MATCHES "Linux")
    message(FATAL_ERROR "${CMAKE_HOST_SYSTEM_NAME} host system name does not match Linux - Please select the correct folder for configuring project")
endif()

project(LINUX_SHARED_THIRD_PARTY)

# --------------------------------------------------------
# build common libraries by platforms
include(../CommonCompilerOptions.CMake)

# ------------------------------------------
# Set Linux specific runtime options
if("${LINUX_TARGET_ARCHITECTURES}" STREQUAL "")
    set(LINUX_TARGET_ARCHITECTURES "${CMAKE_HOST_SYSTEM_PROCESSOR}")
endif("${LINUX_TARGET_ARCHITECTURES}" STREQUAL "")

# --------------------------------------------------------
# build boost
set(_BOOST_BUILD_ROOT "${THIRDPARTY_DIR}/boost/build/${CMAKE_SYSTEM_NAME}")

ExternalProject_Add(Boost
    PREFIX boost
    GIT_REPOSITORY    "https://github.com/boostorg/boost.git"
    GIT_TAG           "boost-1.72.0"
    #GIT_SUBMODULES_RECURSE  TRUE
    GIT_SHALLOW TRUE
    SOURCE_DIR    "${THIRDPARTY_DIR}/boost/src"
    CONFIGURE_COMMAND  ""
    PATCH_COMMAND <SOURCE_DIR>/bootstrap.sh
    BUILD_COMMAND <SOURCE_DIR>/b2 headers
    BUILD_IN_SOURCE  TRUE
    INSTALL_COMMAND <SOURCE_DIR>/b2 runtime-link=static link=static threading=multi  --build-type=minimal --with-thread --with-program_options --with-system --with-date_time --with-regex --with-chrono --with-atomic --with-random --with-filesystem --with-log  address-model=64 architecture=x86  variant=release   --stagedir=stage/x64  --build-dir=${_BOOST_BUILD_ROOT}  --prefix=${_BOOST_BUILD_ROOT}   --libdir=${_BOOST_BUILD_ROOT}/lib install
    UPDATE_COMMAND ""
)

set(boost_DIR "${_BOOST_BUILD_ROOT}/lib/cmake/Boost-1.72.0")
set(_Boost_INCLUDE_DIR "${_BOOST_BUILD_ROOT}/include")
set(_BOOST_CACHE_ARGS
    -DBoost_DIR:PATH=${boost_DIR}
    -DBoost_USE_MULTITHREADED:BOOL=ON
    -DBoost_USE_STATIC_RUNTIME:BOOL=ON
    -DBoost_USE_STATIC_LIBS:BOOL=ON
    -DBoost_NO_SYSTEM_PATHS:BOOL=ON
    -DBoost_INCLUDE_DIR:PATH=${_Boost_INCLUDE_DIR}
)

# --------------------------------------------------------
# build openssl
set(_openssl_BUILD_ROOT "${THIRDPARTY_DIR}/openssl/build/${CMAKE_SYSTEM_NAME}")

ExternalProject_Add(openssl
    PREFIX openssl
    GIT_REPOSITORY "https://github.com/openssl/openssl.git"
    GIT_TAG "OpenSSL_1_1_1g"
    #GIT_SUBMODULES_RECURSE  TRUE
    SOURCE_DIR  "${THIRDPARTY_DIR}/openssl/src"
    CONFIGURE_COMMAND  <SOURCE_DIR>/config --prefix=${_openssl_BUILD_ROOT} --openssldir=${_openssl_BUILD_ROOT}
    PATCH_COMMAND ""
    BUILD_COMMAND make
    BUILD_IN_SOURCE  TRUE
    INSTALL_COMMAND make install
    UPDATE_COMMAND ""
)
set(_OPENSSL_CACHE_ARGS
        -DOPENSSL_USE_STATIC_LIBS:BOOL=ON
        -DOPENSSL_ROOT_DIR:STRING=${_openssl_BUILD_ROOT}
        -DOPENSSL_INCLUDE_DIR:PATH=${_openssl_BUILD_ROOT}/include
        -DOPENSSL_LIBRARIES:PATH=${_openssl_BUILD_ROOT}/lib
    )
set(_OPENSSL_INCLUDE_DIR ${_openssl_BUILD_ROOT}/include)

# --------------------------------------------------------
# Set ed25519 OS specific configurations
set(_ED25519_EDIIMPL ref10)
set(_ED25519_HASH sha3_brainhub)
set(_ED25519_RANDOM dev_urandom)

# --------------------------------------------------------
# Allow multiple definitions
set(FORCE_MULTILE ON)
set(MULTIPLE_OPTION "-zmuldefs")

# --------------------------------------------------------
# build common targets
include(../CommonTargets.CMake)
