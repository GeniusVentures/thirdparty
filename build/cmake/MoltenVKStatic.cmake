# Applied by the Apple platform builds (thirdparty/build/OSX/CMakeLists.txt,
# thirdparty/build/iOS/CMakeLists.txt) as the ExternalProject_Add(MoltenVK)
# PATCH_COMMAND, before configuring MoltenVK's upstream CMake build.
# Idempotent — safe to re-run on every patch step.
#
# 1. Upstream declares libMoltenVK as SHARED; drop the hardcoded type so
#    BUILD_SHARED_LIBS=OFF (from _CMAKE_COMMON_CACHE_ARGS) yields a static
#    archive.
# 2. Upstream's Common/CMakeLists.txt looks up AppKit with find_library(…
#    REQUIRED) unconditionally. AppKit does not exist on iOS/tvOS/visionOS
#    (UIKit instead) and every AppKit include in the sources is guarded by
#    MVK_MACOS, so gate the lookup; an undefined APPKIT_LIBRARY simply drops
#    out of the target_link_libraries list.
# 3. Append GNUS install rules that merge the MoltenVK archive with its
#    static dependencies (ShaderConverter, Common, SPIRV-Cross, SPIRV-Tools)
#    into a single self-contained libMoltenVK.a — the same prelinked-archive
#    layout the old Xcode "MoltenVK Package" schemes produced — and install
#    the Vulkan/MoltenVK headers from the CPM-fetched Vulkan-Headers source
#    dir.

if(NOT DEFINED MVK_SOURCE_DIR)
    message(FATAL_ERROR "MVK_SOURCE_DIR must be passed with -D")
endif()

# Legacy hygiene: MoltenVK/include/vulkan and vk_video are symlinks into
# External/Vulkan-Headers, populated only by the old fetchDependencies (Xcode)
# flow. When a stale External/ tree from a previous MoltenVK checkout lingers,
# those symlinks resolve and shadow the CPM-fetched headers MoltenVK's CMake
# build pins (breaking the compile with outdated Vulkan headers). Drop External/
# unless its Vulkan-Headers revision matches the current ExternalRevisions pin;
# the Xcode flow re-fetches it as needed.
file(READ "${MVK_SOURCE_DIR}/ExternalRevisions/Vulkan-Headers_repo_revision" _vh_pinned)
string(STRIP "${_vh_pinned}" _vh_pinned)
set(_vh_external "${MVK_SOURCE_DIR}/External/Vulkan-Headers")
if(EXISTS "${_vh_external}/.git")
    execute_process(
        COMMAND git -C "${_vh_external}" rev-parse HEAD
        OUTPUT_VARIABLE _vh_present
        OUTPUT_STRIP_TRAILING_WHITESPACE
        ERROR_QUIET
        RESULT_VARIABLE _vh_result
    )
    if(NOT _vh_result EQUAL 0 OR NOT _vh_present STREQUAL "${_vh_pinned}")
        message(STATUS "MoltenVKStatic: removing stale legacy External/ tree")
        file(REMOVE_RECURSE "${MVK_SOURCE_DIR}/External")
    endif()
endif()

set(_mvk_lib_cml "${MVK_SOURCE_DIR}/MoltenVK/CMakeLists.txt")
file(READ "${_mvk_lib_cml}" _mvk_lib_contents)
string(FIND "${_mvk_lib_contents}" "add_library(MoltenVK SHARED \${SOURCES})" _mvk_pos)
if(NOT _mvk_pos EQUAL -1)
    string(REPLACE
        "add_library(MoltenVK SHARED \${SOURCES})"
        "add_library(MoltenVK \${SOURCES})"
        _mvk_lib_contents "${_mvk_lib_contents}")
    file(WRITE "${_mvk_lib_cml}" "${_mvk_lib_contents}")
    message(STATUS "MoltenVKStatic: static library type enabled")
endif()

# AppKit is macOS-only; upstream resolves it unconditionally, which fails the
# configure step on iOS/tvOS/visionOS SDKs. When the lookup is skipped the
# variable stays undefined and ${APPKIT_LIBRARY} expands to no link item.
set(_mvk_common_cml "${MVK_SOURCE_DIR}/Common/CMakeLists.txt")
file(READ "${_mvk_common_cml}" _mvk_common_contents)
string(FIND "${_mvk_common_contents}" "GNUS_APPKIT_GATE" _mvk_pos)
if(_mvk_pos EQUAL -1)
    string(FIND "${_mvk_common_contents}" "find_library(APPKIT_LIBRARY AppKit REQUIRED)" _mvk_pos)
    if(_mvk_pos EQUAL -1)
        message(FATAL_ERROR "MoltenVKStatic: AppKit find_library not found in Common/CMakeLists.txt — upstream layout changed, update the patch")
    endif()
    string(REPLACE
        "find_library(APPKIT_LIBRARY AppKit REQUIRED)"
        "# GNUS_APPKIT_GATE: AppKit exists on macOS only; iOS/tvOS/visionOS use UIKit\n# and all AppKit includes in the sources are guarded by MVK_MACOS. An\n# undefined APPKIT_LIBRARY drops out of the link list below.\nif(NOT CMAKE_SYSTEM_NAME MATCHES \"iOS|tvOS|visionOS\")\n\tfind_library(APPKIT_LIBRARY AppKit REQUIRED)\nendif()"
        _mvk_common_contents "${_mvk_common_contents}")
    file(WRITE "${_mvk_common_cml}" "${_mvk_common_contents}")
    message(STATUS "MoltenVKStatic: AppKit lookup gated to macOS")
endif()

set(_mvk_root_cml "${MVK_SOURCE_DIR}/CMakeLists.txt")
file(READ "${_mvk_root_cml}" _mvk_root_contents)
string(FIND "${_mvk_root_contents}" "GNUS_THIRDPARTY_STATIC_BUNDLE" _mvk_pos)
if(_mvk_pos EQUAL -1)
    file(APPEND "${_mvk_root_cml}" "

################################################################################
# GNUS_THIRDPARTY_STATIC_BUNDLE — appended by the thirdparty Apple builds
# (build/OSX, build/iOS)
#
# Static consumers link only libMoltenVK.a, so bundle everything the Vulkan
# implementation needs (ShaderConverter incl. SPIRV-Cross/SPIRV-Tools, Common)
# into one archive with libtool, like the prelinked static package the Xcode
# scheme produced. cereal and Vulkan-Headers are header-only. No-op when
# building the upstream shared library.
if(NOT BUILD_SHARED_LIBS)
    set(_GNUS_MVK_MERGE_TARGETS MoltenVK MoltenVK_ShaderConverter MoltenVK_Common)
    foreach(_t IN ITEMS spirv-cross-core spirv-cross-reflect spirv-cross-glsl
                        spirv-cross-msl SPIRV-Tools-static)
        if(TARGET \${_t})
            list(APPEND _GNUS_MVK_MERGE_TARGETS \${_t})
        endif()
    endforeach()

    set(_GNUS_MVK_MERGE_INPUTS)
    foreach(_t IN LISTS _GNUS_MVK_MERGE_TARGETS)
        list(APPEND _GNUS_MVK_MERGE_INPUTS \"\$<TARGET_FILE:\${_t}>\")
    endforeach()

    find_program(LIBTOOL_EXECUTABLE NAMES libtool REQUIRED)

    add_custom_command(
        OUTPUT \"\${CMAKE_BINARY_DIR}/libMoltenVK-merged.a\"
        COMMAND \"\${CMAKE_COMMAND}\" -E rm -f \"\${CMAKE_BINARY_DIR}/libMoltenVK-merged.a\"
        COMMAND \"\${LIBTOOL_EXECUTABLE}\" -static -o \"\${CMAKE_BINARY_DIR}/libMoltenVK-merged.a\"
                \${_GNUS_MVK_MERGE_INPUTS}
        DEPENDS \${_GNUS_MVK_MERGE_TARGETS}
        VERBATIM
    )
    add_custom_target(MoltenVKMerged ALL
        DEPENDS \"\${CMAKE_BINARY_DIR}/libMoltenVK-merged.a\")

    install(FILES \"\${CMAKE_BINARY_DIR}/libMoltenVK-merged.a\"
            DESTINATION \"\${CMAKE_INSTALL_LIBDIR}\"
            RENAME \"libMoltenVK.a\")

    # MoltenVK API headers (MoltenVK/include/MoltenVK is a symlink to
    # MoltenVK/MoltenVK/API) plus the Vulkan headers the build used (from the
    # CPM-fetched Vulkan-Headers; CPM exposes its source dir as <Name>_SOURCE_DIR).
    install(DIRECTORY \"\${CMAKE_CURRENT_SOURCE_DIR}/MoltenVK/MoltenVK/API/\"
            DESTINATION \"\${CMAKE_INSTALL_INCLUDEDIR}/MoltenVK\")
    if(NOT DEFINED Vulkan-Headers_SOURCE_DIR AND DEFINED CPM_PACKAGE_Vulkan-Headers_SOURCE_DIR)
        set(Vulkan-Headers_SOURCE_DIR \"\${CPM_PACKAGE_Vulkan-Headers_SOURCE_DIR}\")
    endif()
    if(DEFINED Vulkan-Headers_SOURCE_DIR AND IS_DIRECTORY \"\${Vulkan-Headers_SOURCE_DIR}/include\")
        install(DIRECTORY \"\${Vulkan-Headers_SOURCE_DIR}/include/\"
                DESTINATION \"\${CMAKE_INSTALL_INCLUDEDIR}\")
    else()
        message(FATAL_ERROR \"Vulkan-Headers source dir not found; cannot install Vulkan headers\")
    endif()
endif()
")
    message(STATUS "MoltenVKStatic: static bundle install rules appended")
endif()
