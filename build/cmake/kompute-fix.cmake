

get_filename_component(THIRD_PARTY_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/../../" DIRECTORY ABSOLUTE)

set(_VULKAN_HEADERS_INCLUDE "${THIRD_PARTY_DIRECTORY}/Vulkan-Headers/include")
if(ANDROID)
  # Use Android NDK builtin vulkan header
  set(_VULKAN_HEADERS_INCLUDE "${CMAKE_SYSROOT}/usr/include/vulkan")
endif
include_directories("${_VULKAN_HEADERS_INCLUDE}")

# Make find_package() a no-op if argument is in the list of subprojects.
macro(find_package)
   if(NOT "${ARGV0}" STREQUAL "Vulkan")
        _find_package(${ARGV})
    endif()
endmacro()

macro(target_link_libraries)
    if(NOT "${ARGV1}" STREQUAL "Vulkan::Vulkan")
        _target_link_libraries(${ARGV})
    else()
        _target_link_libraries(kompute)
    endif()
endmacro()
