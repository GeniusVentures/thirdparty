cmake_minimum_required(VERSION 3.2)

include(GNUInstallDirs)

#---------------------------------------------------------------------------------------
# Compiler config
#---------------------------------------------------------------------------------------
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Since delta-enabled-crdts is a template library we only need to copy headers to install derectory
project(delta-enabled-crdts VERSION 0.1.0)

# Define the library target
add_library(delta-enabled-crdts INTERFACE)
target_include_directories(delta-enabled-crdts INTERFACE
        "$<BUILD_INTERFACE:${CMAKE_CURRENT_LIST_DIR}/.>"
        "$<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>")

target_sources(delta-enabled-crdts INTERFACE ${CMAKE_CURRENT_SOURCE_DIR}/delta-crdts.cc)

if (NOT DEFINED DELTACRDTS_BUILD_TESTS)
    # Enable tests by default
    set(DELTACRDTS_BUILD_TESTS ON)
endif()

if (DELTACRDTS_BUILD_TESTS)
    add_executable(delta-enabled-crdts-test
        delta-crdts.cc
        delta-tests.cc
    )
endif()

if (NOT DEFINED DELTACRDTS_INSTALL)
    # Enable installation
    set(DELTACRDTS_INSTALL ON)
endif()

# Installation section
if (DELTACRDTS_INSTALL)
    # The original header file has .cc extension, therefore it is renamed during installation
    install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/delta-crdts.cc DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}" RENAME delta-crdts.h)

    if (DELTACRDTS_BUILD_TESTS)
        install(TARGETS delta-enabled-crdts-test DESTINATION "${CMAKE_INSTALL_BINDIR}")
    endif()
endif()



