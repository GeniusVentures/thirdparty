
cmake_minimum_required(VERSION 3.15)

# if on Linux system, build the Linux executables
if (NOT ${CMAKE_HOST_SYSTEM_NAME} MATCHES "Linux")
    message(FATAL_ERROR "${CMAKE_HOST_SYSTEM_NAME} host system name does not match Linux - Please select the correct folder for configuring project")
endif()

project(LINUX_SHARED_THIRD_PARTY)

# --------------------------------------------------------
# Set OS threading settings
set(CMAKE_THREAD_LIBS_INIT "-lpthread")
set(CMAKE_HAVE_THREADS_LIBRARY ON)
set(CMAKE_USE_WIN32_THREADS_INIT OFF)
set(CMAKE_USE_PTHREADS_INIT ON)
set(THREADS_PREFER_PTHREAD_FLAG ON)

# --------------------------------------------------------
# Set extra compiler flags
set(EXTRA_CXX_FLAGS "-pthread")

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
set(_BOOST_BUILD_ROOT "${CMAKE_CURRENT_BINARY_DIR}/boost/build/${CMAKE_SYSTEM_NAME}")

ExternalProject_Add(Boost
    PREFIX boost
    SOURCE_DIR    "${THIRDPARTY_DIR}/boost"
    CONFIGURE_COMMAND  ""
    PATCH_COMMAND <SOURCE_DIR>/bootstrap.sh
    BUILD_COMMAND <SOURCE_DIR>/b2 headers
    BUILD_IN_SOURCE  TRUE
    INSTALL_COMMAND <SOURCE_DIR>/b2 cxxflags="-fPIC" runtime-link=static link=static threading=multi  --build-type=minimal --with-thread --with-program_options --with-system --with-date_time --with-regex --with-chrono --with-atomic --with-random --with-filesystem --with-log  address-model=64 architecture=x86  variant=release   --stagedir=stage/x64  --build-dir=${_BOOST_BUILD_ROOT}  --prefix=${_BOOST_BUILD_ROOT}   --libdir=${_BOOST_BUILD_ROOT}/lib install
    UPDATE_COMMAND ""
)

set(boost_DIR "${_BOOST_BUILD_ROOT}/lib/cmake/Boost-${BOOST_VERSION}")
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
set(_openssl_BUILD_ROOT "${CMAKE_CURRENT_BINARY_DIR}/openssl/build/${CMAKE_SYSTEM_NAME}")

ExternalProject_Add(openssl
    PREFIX openssl
    SOURCE_DIR  "${THIRDPARTY_DIR}/openssl"
    CONFIGURE_COMMAND  <SOURCE_DIR>/config -fPIC --prefix=${_openssl_BUILD_ROOT} --openssldir=${_openssl_BUILD_ROOT}
    BUILD_COMMAND make build_libs
    BUILD_IN_SOURCE  FALSE
    INSTALL_COMMAND make install_dev
)
set(_OPENSSL_CACHE_ARGS
        -DOPENSSL_USE_STATIC_LIBS:BOOL=ON
        -DOPENSSL_ROOT_DIR:STRING=${_openssl_BUILD_ROOT}
        -DOPENSSL_INCLUDE_DIR:PATH=${_openssl_BUILD_ROOT}/include
        -DOPENSSL_LIBRARIES:PATH=${_openssl_BUILD_ROOT}/lib
    )
set(_OPENSSL_INCLUDE_DIR ${_openssl_BUILD_ROOT}/include)

# --------------------------------------------------------
# set config for grpc
set(_grpc_EXTRA_PARAM
    -D_gRPC_PROTOBUF_PROTOC_EXECUTABLE:STRING=${CMAKE_CURRENT_BINARY_DIR}/grpc/build/third_party/protobuf/protoc
    -D_gRPC_CPP_PLUGIN:STRING=${CMAKE_CURRENT_BINARY_DIR}/grpc/build/grpc_cpp_plugin
	-DgRPC_SSL_PROVIDER:STRING=package
    -DgRPC_BUILD_GRPC_PYTHON_PLUGIN:BOOL=OFF
    -DgRPC_BUILD_GRPC_RUBY_PLUGIN:BOOL=OFF
    -DgRPC_BUILD_GRPC_PHP_PLUGIN:BOOL=OFF
    -DgRPC_BUILD_GRPC_OBJECTIVE_C_PLUGIN:BOOL=OFF
    -DgRPC_BUILD_GRPC_CPP_PLUGIN:BOOL=ON
    -DgRPC_BUILD_GRPC_NODE_PLUGIN:BOOL=OFF
    -DgRPC_BUILD_GRPC_CSHARP_PLUGIN:BOOL=OFF
)

# --------------------------------------------------------
# Set ed25519 OS specific configurations
set(_ED25519_EDIIMPL ref10)
set(_ED25519_HASH sha3_brainhub)
set(_ED25519_RANDOM dev_urandom)

# --------------------------------------------------------
# Set config for libp2p
set(_libp2p_BUILD_EXAMPLES ON)

# --------------------------------------------------------
# Allow multiple definitions
set(FORCE_MULTILE ON)
set(MULTIPLE_OPTION "-z muldefs")

# --------------------------------------------------------
# build common targets
include(../CommonTargets.CMake)
