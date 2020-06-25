# special settings for Android build on windows machine
# this is the common stuff for building

cmake_minimum_required(VERSION 3.15)

project(ANDROID_SHARED_THIRD_PARTY)

if("${LINUX_TARGET_ARCHITECTURES}" STREQUAL "")
    set(LINUX_TARGET_ARCHITECTURES "${CMAKE_HOST_SYSTEM_PROCESSOR}")
endif("${LINUX_TARGET_ARCHITECTURES}" STREQUAL "")

    set (CPACK_PACKAGE_VERSION_MAJOR "0")
    set (CPACK_PACKAGE_VERSION_MINOR "2")
    set (CPACK_PACKAGE_VERSION_PATCH "1")
    set (CPACK_PACKAGE_VERSION_PRE_RELEASE "1")
    set (CPACK_PACKAGE_VENDOR "Genius Ventures")

    set(CMAKE_CXX_STANDARD 17)
    set(CMAKE_CXX_STANDARD_REQUIRED ON)
    set(CMAKE_CXX_EXTENSIONS OFF)
    set(CMAKE_POSITION_INDEPENDENT_CODE TRUE)

    set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} /MT")
    set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} /MTd")

    include(../cmake.in/functions.cmake)
    include(ExternalProject)

# Config Paths by Platforms
    set(CXX_FLAGS_FOR_P2P "")
    set(Boost_USE_STATIC_LIBS ON)
    set(_FINDPACKAGE_PROTOBUF_CONFIG_DIR "${CMAKE_CURRENT_BINARY_DIR}/protobuf/lib/cmake/protobuf")
# Common build by platforms
    include(../CommonTargets.CMake)

