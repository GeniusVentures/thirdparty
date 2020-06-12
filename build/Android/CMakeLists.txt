# special settings for Darwin host build
cmake_minimum_required(VERSION 3.15)

# if on OSX, we can build OSX targets and Android, iOS, Linux, etc with clang++
if (${CMAKE_SYSTEM_NAME} MATCHES "Android")

set(BUILD_DIR Android)
set(LIBRARY_OUTPUT_PATH ../../lib/Android)

include(../CommonTargets.CMake)

project(ANDROID_SHARED)

file(MAKE_DIRECTORY ../../lib/Android/Debug)
file(MAKE_DIRECTORY ../../lib/Android/Release)

include_directories(
        ../../include/Android
)

file(GLOB ALL_SRCS_ANDORID
        "../include/Andorid/*.h"
        "../include/Android/*.hpp"
        "../src/Android/*.cpp"
        "../src/Android/*.c"
        )

add_library(ANDROID_SHARED_DEBUG STATIC ${ALL_SRCS} ${ALL_SRCS_ANDROID})

set_target_properties(ANDROID_SHARED_DEBUG
        PROPERTIES
        OUTPUT_NAME "block-lattice-node"
        LIBRARY_OUTPUT_DIRECTORY "${LIBRARY_OUTPUT_PATH}/Debug"
        ARCHIVE_OUTPUT_DIRECTORY "${LIBRARY_OUTPUT_PATH}/Debug"
        COMPILE_DEFINITIONS DEBUG
        COMPILE_FLAGS -g3
        )

add_library(ANDROID_SHARED_RELEASE STATIC ${ALL_SRCS} ${ALL_SRCS_IOS})
set_target_properties(ANDROID_SHARED_RELEASE
        PROPERTIES
        OUTPUT_NAME "block-lattice-node"
        LIBRARY_OUTPUT_DIRECTORY "${LIBRARY_OUTPUT_PATH}/Release"
        ARCHIVE_OUTPUT_DIRECTORY "${LIBRARY_OUTPUT_PATH}/Release"
        )


endif (${CMAKE_SYSTEM_NAME} MATCHES "Android")
