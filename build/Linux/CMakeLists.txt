cmake_minimum_required(VERSION 3.22)

project(LINUX_SHARED_THIRD_PARTY LANGUAGES C CXX)

include(../CommonCompilerOptions.cmake)

# Check for Arm64
string(TOLOWER "${CMAKE_SYSTEM_PROCESSOR}" CMAKE_SYSTEM_PROCESSOR_LOWER)

if(CMAKE_SYSTEM_PROCESSOR_LOWER STREQUAL "aarch64" OR CMAKE_SYSTEM_PROCESSOR_LOWER STREQUAL "arm64")
    set(BOOST_ARCH_FLAGS "architecture=arm")
    set(OPENSSL_TARGET "linux-${CMAKE_SYSTEM_PROCESSOR}")
elseif(CMAKE_SYSTEM_PROCESSOR_LOWER STREQUAL "x86_64" OR CMAKE_SYSTEM_PROCESSOR_LOWER STREQUAL "amd64")
    set(BOOST_ARCH_FLAGS "architecture=x86")
    set(OPENSSL_TARGET "linux-${CMAKE_SYSTEM_PROCESSOR}-clang")
endif()

# Boost
set(BOOST_ROOT "${CMAKE_CURRENT_BINARY_DIR}/boost/build")
ExternalProject_Add(Boost
    PREFIX boost
    SOURCE_DIR "${THIRDPARTY_DIR}/boost"
    INSTALL_DIR ${BOOST_ROOT}

    CONFIGURE_COMMAND <SOURCE_DIR>/bootstrap.sh --with-toolset=clang --with-libraries=${BOOST_INCLUDE_LIBRARIES_COMMA_SEPARATED} --prefix=${BOOST_ROOT}

    BUILD_COMMAND <SOURCE_DIR>/b2${CMAKE_EXECUTABLE_SUFFIX} ${BOOST_B2_FLAGS} ${BOOST_B2_EXTRA_FLAGS} cxxstd=${CMAKE_CXX_STANDARD} visibility=global runtime-link=static link=static threading=multi --build-type=minimal address-model=64 ${BOOST_ARCH_FLAGS} variant=${BOOST_VARIANT} --prefix=<INSTALL_DIR> -d0 install
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
    "${BOOST_ROOT}/lib/libboost_context.a"
    "${BOOST_ROOT}/lib/libboost_coroutine.a"

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
set(OPENSSL_ROOT_DIR "${CMAKE_CURRENT_BINARY_DIR}/openssl/build")

ExternalProject_Add(openssl
    PREFIX openssl
    SOURCE_DIR "${THIRDPARTY_DIR}/openssl"
    CONFIGURE_COMMAND <SOURCE_DIR>/Configure ${OPENSSL_VARIANT} enable-threads no-shared -fPIC --prefix=${OPENSSL_ROOT_DIR} --openssldir=${OPENSSL_ROOT_DIR} --libdir=lib ${OPENSSL_TARGET}
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

include(../CommonTargets.cmake)
