
function(add_circuit_no_stdlib name)
    set(prefix ARG)
    set(noValues "")
    set(singleValues)
    set(multiValues SOURCES INCLUDE_DIRECTORIES LINK_LIBRARIES COMPILER_OPTIONS)
    cmake_parse_arguments(${prefix}
                          "${noValues}"
                          "${singleValues}"
                          "${multiValues}"
                          ${ARGN})

    if(NOT ARG_SOURCES)
        message(FATAL_ERROR "SOURCES for ${name} circuit was not defined")
    endif()

    foreach(source ${ARG_SOURCES})
        if(NOT IS_ABSOLUTE ${source})
            list(APPEND CIRCUIT_SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/${source}")
        else()
            list(APPEND CIRCUIT_SOURCES "${source}")
        endif()
    endforeach()
    list(REMOVE_DUPLICATES CIRCUIT_SOURCES)

    foreach(ITR ${CIRCUIT_SOURCES})
        if(NOT EXISTS ${ITR})
            message(SEND_ERROR "Cannot find circuit source file: ${source}")
        endif()
    endforeach()

    set(INCLUDE_DIRS_LIST "")
    # Collect include directories from dependencies first
    foreach(lib ${ARG_LINK_LIBRARIES})
        get_target_property(lib_include_dirs ${lib} INTERFACE_INCLUDE_DIRECTORIES)
        foreach(dir ${lib_include_dirs})
            list(APPEND INCLUDE_DIRS_LIST "-I${dir}")
        endforeach()
    endforeach()
    # Add passed include directories
    foreach(include_dir ${ARG_INCLUDE_DIRECTORIES})
        if(NOT IS_ABSOLUTE ${include_dir})
            set(include_dir "${CMAKE_CURRENT_SOURCE_DIR}/${include_dir}")
        endif()
        list(APPEND INCLUDE_DIRS_LIST "-I${include_dir}")
    endforeach()

        list(APPEND INCLUDE_DIRS_LIST -I${ZKLLVM_SRC_DIR}/libs/stdlib/libcpp -I${ZKLLVM_SRC_DIR}/libs/circifier/clang/lib/Headers -I${ZKLLVM_SRC_DIR}/libs/stdlib/libc/include)
    list(REMOVE_DUPLICATES INCLUDE_DIRS_LIST)

    if (NOT ${CIRCUIT_BINARY_OUTPUT})
        set(link_options "-S")
    endif()

    set(CLANG "${_THIRDPARTY_BUILD_DIR}/circifier/bin/clang")
    set(LINKER "${_THIRDPARTY_BUILD_DIR}/circifier/bin/llvm-link")


    # Compile sources
    set(compiler_outputs "")
    add_custom_target(${name}_compile_sources)
    foreach(source ${CIRCUIT_SOURCES})
        get_filename_component(source_base_name ${source} NAME)
        add_custom_target(${name}_${source_base_name}_ll
                        COMMAND ${CLANG} -target assigner -Xclang -fpreserve-vec3-type -Werror=unknown-attributes -D_LIBCPP_ENABLE_CXX17_REMOVED_UNARY_BINARY_FUNCTION
                        -D__ZKLLVM__ ${INCLUDE_DIRS_LIST} -emit-llvm -O1 -S ${ARG_COMPILER_OPTIONS}  -o ${name}_${source_base_name}.ll ${source}

                        VERBATIM COMMAND_EXPAND_LISTS

                        SOURCES ${source})
        add_dependencies(${name}_compile_sources ${name}_${source_base_name}_ll)
        list(APPEND compiler_outputs "${name}_${source_base_name}.ll")
    endforeach()

    # Link sources
    add_custom_target(${name}
                      COMMAND ${LINKER} ${link_options} -o ${name}.ll ${compiler_outputs}
                      DEPENDS ${name}_compile_sources
                      VERBATIM COMMAND_EXPAND_LISTS)
    set_target_properties(${name} PROPERTIES OUTPUT_NAME ${name}.ll)
endfunction(add_circuit_no_stdlib)