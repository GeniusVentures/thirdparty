# C++ standard version
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# ProcessorCount
include(ProcessorCount)
ProcessorCount(PROCESSOR_COUNT)

# Convenience settings
if(NOT DEFINED CMAKE_COLOR_DIAGNOSTICS)
    set(CMAKE_COLOR_DIAGNOSTICS ON)
endif()

if (DEFINED SANITIZE_CODE)
    message(STATUS "Building with sanitizer: ${SANITIZE_CODE}")
    if ("${CMAKE_CXX_COMPILER_ID}" MATCHES "Clang" OR "${CMAKE_CXX_COMPILER_ID}" MATCHES "GNU")
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fsanitize=${SANITIZE_CODE}")
        set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fsanitize=${SANITIZE_CODE}")
        set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -fsanitize=${SANITIZE_CODE}")
        set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -fsanitize=${SANITIZE_CODE}")
        add_compile_options("-fsanitize=${SANITIZE_CODE}")
        add_link_options("-fsanitize=${SANITIZE_CODE}")
    elseif (MSVC)
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /fsanitize=${SANITIZE_CODE}")
        set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} /fsanitize=${SANITIZE_CODE}")
        add_compile_options("/fsanitize=${SANITIZE_CODE}")
    endif()
endif()

# Remove this once we update gRPC, its dependencies, fix libp2p and change some of our internal projects
if ("${CMAKE_CXX_COMPILER_ID}" MATCHES "Clang")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wno-unknown-warning-option -Wno-missing-template-arg-list-after-template-kw")
endif()

# Set PROJECT_BUILD folder
get_filename_component(PROJECT_BUILD_FOLDER "${CMAKE_CURRENT_SOURCE_DIR}" DIRECTORY ABSOLUTE)
get_filename_component(PROJECT_SRC_FOLDER "${PROJECT_BUILD_FOLDER}" DIRECTORY ABSOLUTE)

include(${PROJECT_BUILD_FOLDER}/cmake.in/functions.cmake)
include(ExternalProject)

# Boost
set(BOOST_VARIANT $<IF:$<CONFIG:Debug>,debug,release>)

# Workaround for on GitHub actions, probably permission error - get_BOOST_version(BOOST_VERSION "${THIRDPARTY_DIR}/boost/boost/version.hpp")
set(BOOST_MAJOR_VERSION "1" CACHE STRING "Boost Major Version")
set(BOOST_MINOR_VERSION "85" CACHE STRING "Boost Minor Version")
set(BOOST_PATCH_VERSION "0" CACHE STRING "Boost Patch Version")

set(BOOST_VERSION "${BOOST_MAJOR_VERSION}.${BOOST_MINOR_VERSION}.${BOOST_PATCH_VERSION}")
set(BOOST_VERSION_3U "${BOOST_MAJOR_VERSION}_${BOOST_MINOR_VERSION}_${BOOST_PATCH_VERSION}")
set(BOOST_VERSION_2U "${BOOST_MAJOR_VERSION}_${BOOST_MINOR_VERSION}")

set(BOOST_ROOT "${CMAKE_CURRENT_BINARY_DIR}/boost/build/${CMAKE_SYSTEM_NAME}")

if(${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
    set(TP_BUILD_SUBDIR "OSX")
else()
    set(TP_BUILD_SUBDIR ${CMAKE_SYSTEM_NAME})
endif()

if(WIN32)
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -D_WIN32_WINNT=0x0A00 -DNOMINMAX")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -D_WIN32_WINNT=0x0A00 -DNOMINMAX")
endif()

if(MSVC)
    set(_MSVC_RUNTIME_LIBRARY
        -DCMAKE_POLICY_DEFAULT_CMP0091:STRING=NEW
        -DCMAKE_MSVC_RUNTIME_LIBRARY:STRING=MultiThreaded$<$<CONFIG:Debug>:Debug>
    )
endif()

option(SGNS_ENABLE_RELEASE_SYMBOLS "Build Release with debug symbols for symbolication" ON)

if(SGNS_ENABLE_RELEASE_SYMBOLS)
    if(CMAKE_CXX_COMPILER_ID MATCHES "^(AppleClang|Clang|GNU)$")
        set(_RELEASE_SYMBOLS_C_FLAGS   "${CMAKE_C_FLAGS_RELEASE} -gline-tables-only")
        set(_RELEASE_SYMBOLS_CXX_FLAGS "${CMAKE_CXX_FLAGS_RELEASE} -gline-tables-only")
    elseif(MSVC)
        # /Z7 embeds debug info in .obj/.lib — no standalone PDB needed
        set(_RELEASE_SYMBOLS_C_FLAGS   "${CMAKE_C_FLAGS_RELEASE} /Z7")
        set(_RELEASE_SYMBOLS_CXX_FLAGS "${CMAKE_CXX_FLAGS_RELEASE} /Z7")
    else()
        set(_RELEASE_SYMBOLS_C_FLAGS   "${CMAKE_C_FLAGS_RELEASE}")
        set(_RELEASE_SYMBOLS_CXX_FLAGS "${CMAKE_CXX_FLAGS_RELEASE}")
    endif()
    set(_CMAKE_COMMON_CACHE_ARGS_SYMBOLS
        -DCMAKE_C_FLAGS_RELEASE:STRING=${_RELEASE_SYMBOLS_C_FLAGS}
        -DCMAKE_CXX_FLAGS_RELEASE:STRING=${_RELEASE_SYMBOLS_CXX_FLAGS}
    )
else()
    set(_CMAKE_COMMON_CACHE_ARGS_SYMBOLS "")
endif()

string(STRIP "${CMAKE_C_FLAGS}" CMAKE_C_FLAGS)
string(STRIP "${CMAKE_CXX_FLAGS}" CMAKE_CXX_FLAGS)

set(_CMAKE_COMMON_CACHE_ARGS
    -DBUILD_EXAMPLES:BOOL=OFF
    -DBUILD_SHARED_LIBS:BOOL=OFF
    -DBUILD_STATIC_LIBS:BOOL=ON
    -DBUILD_TESTING:BOOL=OFF
    -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
    -DCMAKE_C_FLAGS_DEBUG:STRING=${CMAKE_C_FLAGS_DEBUG}
    -DCMAKE_C_FLAGS_RELEASE:STRING=${CMAKE_C_FLAGS_RELEASE}
    -DCMAKE_C_FLAGS:STRING=${CMAKE_C_FLAGS}
    -DCMAKE_CXX_FLAGS_DEBUG:STRING=${CMAKE_CXX_FLAGS_DEBUG}
    -DCMAKE_CXX_FLAGS_RELEASE:STRING=${CMAKE_CXX_FLAGS_RELEASE}
    -DCMAKE_CXX_FLAGS:STRING=${CMAKE_CXX_FLAGS}
    -DCMAKE_CXX_STANDARD:STRING=${CMAKE_CXX_STANDARD}
    -DCMAKE_FIND_PACKAGE_PREFER_CONFIG:BOOL=ON
    -DCMAKE_POLICY_DEFAULT_CMP0057:STRING=NEW
    -DCMAKE_POLICY_DEFAULT_CMP0074:STRING=NEW
    -DCMAKE_POLICY_DEFAULT_CMP0144:STRING=NEW
    -DCMAKE_POSITION_INDEPENDENT_CODE:BOOL=ON
    -DCMAKE_TOOLCHAIN_FILE:FILEPATH=${CMAKE_TOOLCHAIN_FILE}
    -DCMAKE_VS_GLOBALS:STRING=${CMAKE_VS_GLOBALS}
    ${_MSVC_RUNTIME_LIBRARY}
)

set(THIRDPARTY_DIR "${PROJECT_SRC_FOLDER}")

if(NOT EXISTS "${THIRDPARTY_DIR}/build")
    message(FATAL_ERROR "Unable to find thirdparty source folder ${THIRDPARTY_DIR}")
endif()

# Boost settings
set(BOOST_INCLUDE_LIBRARIES container date_time filesystem json log program_options random regex system test timer context coroutine)

list(JOIN BOOST_INCLUDE_LIBRARIES "," BOOST_INCLUDE_LIBRARIES_COMMA_SEPARATED)
separate_arguments(BOOST_B2_FLAGS NATIVE_COMMAND "${CMAKE_CXX_FLAGS}")
list(APPEND BOOST_B2_FLAGS "-fPIC")
set(BOOST_B2_EXTRA_FLAGS "context-impl=fcontext")
list(TRANSFORM BOOST_B2_FLAGS PREPEND "cxxflags=")

# OpenSSL
set(OPENSSL_VARIANT $<IF:$<CONFIG:Debug>,--debug,--release>)

option(MNN_BUILD_TESTS "Build MNN tests" OFF)
option(MNN_SUPPORT_TRANSFORMER_FUSE "Enable MNN transformer fuse ops for OSX external build" ON)
if (MNN_BUILD_TESTS)
    set(MNN_TEST_BYPRODUCT "${CMAKE_CURRENT_BINARY_DIR}/MNN/lib/run_test.out")
endif()


