cmake_minimum_required(VERSION 3.20)

# if on Linux system, build the Linux executables
if(NOT ${CMAKE_HOST_SYSTEM_NAME} MATCHES "Linux")
    message(FATAL_ERROR "${CMAKE_HOST_SYSTEM_NAME} host system name does not match Linux - Please select the correct folder for configuring project")
endif()

project(LINUX_SHARED_THIRD_PARTY)

# Build common libraries by platforms
include(../CommonCompilerOptions.CMake)

# Build boost
set(_BOOST_BUILD_ROOT "${CMAKE_CURRENT_BINARY_DIR}/boost/build/${CMAKE_SYSTEM_NAME}")
set(Boost_NO_SYSTEM_PATHS ON)
set(Boost_USE_STATIC_LIBS ON)
set(Boost_USE_STATIC_RUNTIME ON)

ExternalProject_Add(Boost
    PREFIX boost
    SOURCE_DIR "${THIRDPARTY_DIR}/boost"
    LOG_OUTPUT_ON_FAILURE TRUE
    LOG_CONFIGURE ON
    LOG_BUILD OFF
    LOG_INSTALL ON
    CONFIGURE_COMMAND ""
    PATCH_COMMAND <SOURCE_DIR>/bootstrap.sh
    BUILD_COMMAND <SOURCE_DIR>/b2 headers
    BUILD_IN_SOURCE TRUE
    INSTALL_COMMAND <SOURCE_DIR>/b2 "cxxflags=-fPIC" visibility=global runtime-link=static link=static toolset=clang threading=multi --build-type=minimal --with-thread --with-program_options --with-system --with-date_time --with-regex --with-chrono --with-atomic --with-random --with-filesystem --with-log --with-container --with-test address-model=64 architecture=x86 variant=${BOOST_VARIANT} --stagedir=stage/x64 --build-dir=${_BOOST_BUILD_ROOT} --prefix=${_BOOST_BUILD_ROOT} --libdir=${_BOOST_BUILD_ROOT}/lib install
    UPDATE_COMMAND ""
)

set(boost_DIR "${_BOOST_BUILD_ROOT}/lib/cmake/Boost-${BOOST_VERSION}")
set(_Boost_INCLUDE_DIR "${_BOOST_BUILD_ROOT}/include")
set(_BOOST_CACHE_ARGS
    -DBoost_DIR:PATH=${boost_DIR}
    -DBoost_USE_MULTITHREADED:BOOL=ON
    -DBoost_USE_STATIC_LIBS:BOOL=ON
    -DBoost_USE_STATIC_RUNTIME:BOOL=ON
    -DBoost_NO_SYSTEM_PATHS:BOOL=ON
    -DBOOST_ROOT:PATH=${_BOOST_ROOT}
    -DBoost_INCLUDE_DIR:PATH=${_Boost_INCLUDE_DIR}
    -Dboost_headers_DIR:PATH=${BOOST_LIB_CMAKE_DIR}/boost_headers-${BOOST_VERSION}
    -Dboost_random_DIR:PATH=${BOOST_LIB_CMAKE_DIR}/boost_random-${BOOST_VERSION}
    -Dboost_system_DIR:PATH=${BOOST_LIB_CMAKE_DIR}/boost_system-${BOOST_VERSION}
    -Dboost_filesystem_DIR:PATH=${BOOST_LIB_CMAKE_DIR}/boost_filesystem-${BOOST_VERSION}
    -Dboost_program_options_DIR:PATH=${BOOST_LIB_CMAKE_DIR}/boost_program_options-${BOOST_VERSION}
    -Dboost_regex_DIR:PATH=${BOOST_LIB_CMAKE_DIR}/boost_regex-${BOOST_VERSION}
    -Dboost_date_time_DIR:PATH=${BOOST_LIB_CMAKE_DIR}/boost_date_time-${BOOST_VERSION}
    -Dboost_container_DIR:PATH=${BOOST_LIB_CMAKE_DIR}/boost_container-${BOOST_VERSION}
    -Dboost_unit_test_framework_DIR:PATH=${BOOST_LIB_CMAKE_DIR}/boost_unit_test_framework-${BOOST_VERSION}
)

# build openssl
set(_openssl_BUILD_ROOT "${CMAKE_CURRENT_BINARY_DIR}/openssl/build/${CMAKE_SYSTEM_NAME}")

set(OPENSSL_VARIANT $<$<CONFIG:Debug>:-d>)

ExternalProject_Add(openssl
    PREFIX openssl
    SOURCE_DIR "${THIRDPARTY_DIR}/openssl"
    CONFIGURE_COMMAND <SOURCE_DIR>/config ${OPENSSL_VARIANT} -fPIC --prefix=${_openssl_BUILD_ROOT} --openssldir=${_openssl_BUILD_ROOT}
    BUILD_COMMAND make build_libs
    BUILD_IN_SOURCE FALSE
    INSTALL_COMMAND make install_dev
)
set(_OPENSSL_CACHE_ARGS
    -DOPENSSL_USE_STATIC_LIBS:BOOL=ON
    -DOPENSSL_ROOT_DIR:STRING=${_openssl_BUILD_ROOT}
    -DOPENSSL_INCLUDE_DIR:PATH=${_openssl_BUILD_ROOT}/include
    -DOPENSSL_LIBRARIES:PATH=${_openssl_BUILD_ROOT}/lib
)
set(_OPENSSL_INCLUDE_DIR ${_openssl_BUILD_ROOT}/include)

# set config for grpc
set(_grpc_EXTRA_PARAM
    -D_gRPC_PROTOBUF_PROTOC_EXECUTABLE:STRING=${CMAKE_CURRENT_BINARY_DIR}/grpc/bin/protoc
    -D_gRPC_CPP_PLUGIN:STRING=${CMAKE_CURRENT_BINARY_DIR}/grpc/bin/grpc_cpp_plugin
    -DgRPC_SSL_PROVIDER:STRING=package
    -DgRPC_BUILD_GRPC_PYTHON_PLUGIN:BOOL=OFF
    -DgRPC_BUILD_GRPC_RUBY_PLUGIN:BOOL=OFF
    -DgRPC_BUILD_GRPC_PHP_PLUGIN:BOOL=OFF
    -DgRPC_BUILD_GRPC_OBJECTIVE_C_PLUGIN:BOOL=OFF
    -DgRPC_BUILD_GRPC_CPP_PLUGIN:BOOL=ON
    -DgRPC_BUILD_GRPC_NODE_PLUGIN:BOOL=OFF
    -DgRPC_BUILD_GRPC_CSHARP_PLUGIN:BOOL=OFF
)

# Set ed25519 OS specific configurations
set(_ED25519_EDIIMPL ref10)
set(_ED25519_HASH sha3_brainhub)
set(_ED25519_RANDOM dev_urandom)

# Set config for libp2p
set(_libp2p_BUILD_EXAMPLES ON)

# Set config for MNN modules
set(_MNN_WIN_RUNTIME_MT OFF)

# Allow multiple definitions
set(FORCE_MULTILE ON)
set(MULTIPLE_OPTION "-z muldefs")

set(CPPRESTSDK_NOWARN "-Wno-format-truncation" CACHE INTERNAL "")

# build common targets
include(../CommonTargets.CMake)
