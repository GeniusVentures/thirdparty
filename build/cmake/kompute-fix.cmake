

get_filename_component(THIRD_PARTY_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/../../" DIRECTORY ABSOLUTE)
include_directories(${THIRD_PARTY_DIRECTORY}/Vulkan-Headers/include)

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
