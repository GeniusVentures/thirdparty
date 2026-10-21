# Superbuild-local FindZLIB override (rocksdb-backup Phase 3, 2026-10-21).
#
# Why this exists: cpp-httplib v0.53.1's installed config re-executes
# ZLIBConfig.cmake through CMake >= 3.26's hash-guarded find_dependency
# (it re-calls find_package(ZLIB) even when ZLIB_FOUND is already true),
# and ZLIBConfig.cmake's @PACKAGE_INIT@ macros (set_and_check /
# PACKAGE_PREFIX_DIR) then corrupt the enclosing httplibConfig.cmake's own
# header-path check with the zlib prefix ("File or directory
# <zlib>/include/httplib.h ... does not exist"). Any sub-build that
# consumes the minio-cpp config package (whose miniocpp-config.cmake
# re-runs miniocpp-deps.cmake, which loads httplibConfig.cmake) MUST
# therefore resolve ZLIB without ever executing a ZLIB config file.
#
# This module imports the thirdparty-built zlib via its installed TARGETS
# file directly (no config-file execution, no artifact-name guessing) and
# exposes it under the canonical FindZLIB target name. The superbuild
# injects the location via -DZLIB_SUPERBUILD_TARGETS_FILE (see the
# sgns-blockstore entry in CommonTargets.cmake).

if(TARGET ZLIB::ZLIB)
    set(ZLIB_FOUND TRUE)
    return()
endif()

if(NOT DEFINED ZLIB_SUPERBUILD_TARGETS_FILE)
    message(FATAL_ERROR
        "FindZLIB shim: ZLIB_SUPERBUILD_TARGETS_FILE is not set. This "
        "override exists only for superbuild ExternalProject sub-builds "
        "that consume the minio-cpp config package; unset CMAKE_MODULE_PATH "
        "to use CMake's builtin FindZLIB instead.")
endif()

if(NOT EXISTS "${ZLIB_SUPERBUILD_TARGETS_FILE}")
    message(FATAL_ERROR
        "FindZLIB shim: ${ZLIB_SUPERBUILD_TARGETS_FILE} does not exist - "
        "the thirdparty zlib ExternalProject must complete before this "
        "sub-build configures (check the superbuild DEPENDS chain).")
endif()

# Imports ZLIB::ZLIBSTATIC (per-config location files are included by the
# targets file itself).
include("${ZLIB_SUPERBUILD_TARGETS_FILE}")

if(NOT TARGET ZLIB::ZLIB)
    add_library(ZLIB::ZLIB ALIAS ZLIB::ZLIBSTATIC)
endif()

set(ZLIB_FOUND TRUE)
set(ZLIB_LIBRARIES ZLIB::ZLIB)
