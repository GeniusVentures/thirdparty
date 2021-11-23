cmake_minimum_required(VERSION 3.12)

PROJECT(sqlite3)
set(LIBRARY_NAME sqlite3)

include_directories(${CMAKE_SOURCE_DIR})
add_library(sqlite3 STATIC sqlite3.c sqlite3.h sqlite3ext.h)

add_definitions(-DSQLITE_ENABLE_RTREE)
add_definitions(-DSQLITE_ENABLE_FTS4)
add_definitions(-DSQLITE_ENABLE_FTS5)
add_definitions(-DSQLITE_ENABLE_JSON1)
add_definitions(-DSQLITE_ENABLE_RBU)
add_definitions(-DSQLITE_ENABLE_STAT4)

# Uncomment this for single-threaded variant (faster)
#add_definitions(-DSQLITE_THREADSAFE=0)

message("Compiling SQLite for system: ${CMAKE_SYSTEM_NAME}")


install(FILES sqlite3.h sqlite3ext.h DESTINATION include)

if(NOT ("${CMAKE_SYSTEM_NAME}" STREQUAL "Darwin" AND DEFINED IOS_PLATFORM))
  add_executable(sqlite sqlite3.c sqlite3.h sqlite3ext.h shell.c)
  #set_target_properties(sqlite PROPERTIES OUTPUT_NAME sqlite3)

  if(WIN32)
    add_custom_command(TARGET sqlite POST_BUILD
      COMMAND ${CMAKE_COMMAND} -E copy $<TARGET_FILE:sqlite> ${CMAKE_BINARY_DIR}/sqlite3.exe
      DEPENDS sqlite
    )
    install(FILES ${CMAKE_BINARY_DIR}/sqlite3.exe DESTINATION bin)
  else()
    include(FindThreads)
    target_link_libraries(sqlite m ${CMAKE_THREAD_LIBS_INIT} ${CMAKE_DL_LIBS})
    install(TARGETS sqlite RUNTIME DESTINATION bin)
  endif()

  install(TARGETS sqlite3 LIBRARY DESTINATION lib ARCHIVE DESTINATION lib)
endif()

include(GNUInstallDirs)

function(install_target targets config)
    install(TARGETS ${targets} EXPORT ${config}
        LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
        ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
        RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
        INCLUDES DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
        PUBLIC_HEADER DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
        FRAMEWORK DESTINATION ${CMAKE_INSTALL_PREFIX}
    )
endfunction()

set(CONFIG_NAME "${PROJECT_NAME}Config")
#message("CONFIG_NAME " ${CONFIG_NAME})
#message("LIBRARY_NAME " ${LIBRARY_NAME})

install_target(${LIBRARY_NAME} ${CONFIG_NAME})

#install(
#    DIRECTORY ${CMAKE_SOURCE_DIR}/include/
#    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
#    FILES_MATCHING  PATTERN "*.h"
#)

set(CONFIG_DESTINATION_DIR "${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME}")
install(
    EXPORT ${CONFIG_NAME}
    NAMESPACE sqlite3::
    DESTINATION ${CONFIG_DESTINATION_DIR}
)
