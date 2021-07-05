
# ------------------------------------------
# Set PROJECT_BUILD folder
get_filename_component(PROJECT_BUILD_FOLDER "${CMAKE_CURRENT_SOURCE_DIR}" DIRECTORY ABSOLUTE)
get_filename_component(PROJECT_SRC_FOLDER "${PROJECT_BUILD_FOLDER}" DIRECTORY ABSOLUTE)

include(GNUInstallDirs)
include(CheckCXXCompilerFlag)
include(${PROJECT_BUILD_FOLDER}/cmake.in/functions.cmake)
include(ExternalProject)

if (${CMAKE_SYSTEM_NAME} STREQUAL "Windows")
  set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} /MT")
  set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} /MTd")
  set(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE} /MT")
  set(CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG} /MTd")

  if (CMAKE_BUILD_TYPE STREQUAL Debug)
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} /MTd")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /MTd")
  endif (CMAKE_BUILD_TYPE STREQUAL Debug)

  if (CMAKE_BUILD_TYPE STREQUAL "Release")
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} /MT")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /MT")
  endif (CMAKE_BUILD_TYPE STREQUAL "Release")

  print("CMAKE_BUILD_TYPE: ${CMAKE_BUILD_TYPE}")
  set(CompilerFlags
          CMAKE_CXX_FLAGS
          CMAKE_CXX_FLAGS_DEBUG
          CMAKE_CXX_FLAGS_RELEASE
          CMAKE_C_FLAGS
          CMAKE_C_FLAGS_DEBUG
          CMAKE_C_FLAGS_RELEASE
          )
  foreach(CompilerFlag ${CompilerFlags})
    string(REPLACE "/MD" "/MT" ${CompilerFlag} "${${CompilerFlag}}")
  endforeach()
endif()

set(CMAKE_CACHE_ARGS_CFLAGES_ADD
      -DCMAKE_CXX_FLAGS:STRING=${CMAKE_CXX_FLAGS}
      -DCMAKE_C_FLAGS:STRING=${CMAKE_C_FLAGS}
      -DCMAKE_CXX_FLAGS_RELEASE:STRING=${CMAKE_CXX_FLAGS_RELEASE}
      -DCMAKE_C_FLAGS_RELEASE:STRING=${CMAKE_C_FLAGS_RELEASE}
      -DCMAKE_CXX_FLAGS_DEBUG:STRING=${CMAKE_CXX_FLAGS_DEBUG}
      -DCMAKE_C_FLAGS_DEBUG:STRING=${CMAKE_C_FLAGS_DEBUG}
      -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
)

print("C flags: ${CMAKE_C_FLAGS}")
print("CXX flags: ${CMAKE_CXX_FLAGS}")
print("C Debug flags: ${CMAKE_C_FLAGS_DEBUG}")
print("CXX Debug flags: ${CMAKE_CXX_FLAGS_DEBUG}")
print("C Release flags: ${CMAKE_C_FLAGS_RELEASE}")
print("CXX Release flags: ${CMAKE_CXX_FLAGS_RELEASE}")

set(_CMAKE_COMMON_BUILD_PARAMS ${CMAKE_CACHE_ARGS_CFLAGES_ADD})

if(";${CMAKE_VS_PLATFORM_NAME};${MSVC_C_ARCHITECTURE_ID};${MSVC_CXX_ARCHITECTURE_ID};"
    MATCHES ";(Win64|Itanium|x64|IA64);")
   set(CMAKE_ASM${ASM_DIALECT}_COMPILER_INIT ml64)
else()
   set(CMAKE_ASM${ASM_DIALECT}_COMPILER_INIT ml)
endif()

# --------------------------------------------------------
# define third party directory
set(THIRDPARTY_DIR "${PROJECT_SRC_FOLDER}")
