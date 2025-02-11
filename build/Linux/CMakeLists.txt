cmake_minimum_required(VERSION 3.22)

project(LINUX_SHARED_THIRD_PARTY LANGUAGES C CXX)

include(../CommonCompilerOptions.CMake)

# Boost
set(BOOST_ROOT "${CMAKE_CURRENT_BINARY_DIR}/boost/build/${CMAKE_SYSTEM_NAME}")
ExternalProject_Add(Boost
    PREFIX boost
    SOURCE_DIR "${THIRDPARTY_DIR}/boost"
    INSTALL_DIR ${BOOST_ROOT}

    CONFIGURE_COMMAND <SOURCE_DIR>/bootstrap.sh --with-toolset=clang --with-libraries=${BOOST_INCLUDE_LIBRARIES_COMMA_SEPARATED} --prefix=${BOOST_ROOT}

    BUILD_COMMAND <SOURCE_DIR>/b2${CMAKE_EXECUTABLE_SUFFIX} ${BOOST_B2_FLAGS} cxxstd=${CMAKE_CXX_STANDARD} visibility=global runtime-link=static link=static threading=multi --build-type=minimal address-model=64 architecture=x86 variant=${BOOST_VARIANT} --prefix=<INSTALL_DIR> -d0 install
    BUILD_IN_SOURCE TRUE

    INSTALL_COMMAND ""
)

set(Boost_DIR "${BOOST_ROOT}/lib/cmake/Boost-${BOOST_VERSION}")
set(Boost_INCLUDE_DIR "${BOOST_ROOT}/include")

set(_BOOST_CACHE_ARGS
    -DBOOST_ROOT:PATH=${BOOST_ROOT}
    -DBoost_DIR:PATH=${Boost_DIR}
    -DBoost_INCLUDE_DIR:PATH=${Boost_INCLUDE_DIR}
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
    CONFIGURE_COMMAND <SOURCE_DIR>/Configure ${OPENSSL_VARIANT} enable-threads no-shared -fPIC --prefix=${OPENSSL_ROOT_DIR} --openssldir=${OPENSSL_ROOT_DIR} --libdir=lib linux-${CMAKE_SYSTEM_PROCESSOR}-clang
    BUILD_COMMAND make build_libs -j${PROCESSOR_COUNT}
    BUILD_IN_SOURCE FALSE
    INSTALL_COMMAND make install_dev
)

set(OPENSSL_INCLUDE_DIR ${OPENSSL_ROOT_DIR}/include)
set(_OPENSSL_CACHE_ARGS
    -DOPENSSL_USE_STATIC_LIBS:BOOL=ON
    -DOPENSSL_ROOT_DIR:PATH=${OPENSSL_ROOT_DIR}
    -DOpenSSL_DIR:PATH=${OPENSSL_ROOT_DIR}/lib/cmake/OpenSSL
)

# ed25519 crypto
set(_ED25519_RANDOM dev_urandom)

set(_MNN_EXTRA_PARAM
    -DMNN_USE_SYSTEM_LIB:BOOL=ON 
    -DMNN_SEP_BUILD:BOOL=OFF
    -DVulkan_INCLUDE_DIR:PATH=${CMAKE_CURRENT_BINARY_DIR}/Vulkan-Loader/include
    -DVulkan_LIBRARY:PATH=${CMAKE_CURRENT_BINARY_DIR}/Vulkan-Loader/lib/libvulkan.so
)

set(_ZKLLVM_EXTRA_PARAM
    -DZKLLVM_BUILD_TRANSPILER_LIB:BOOL=OFF
    -DZKLLVM_BUILD_EXAMPLES:BOOL=OFF
    -DZKLLVM_BUILD_STD_LIB:BOOL=ON
    -DZKLLVM_BUILD_EXECUTABLES:BOOL=OFF
)

include(../CommonTargets.CMake)
