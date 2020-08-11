

#
# Set Protobug library path
set(PROTOBUF_ROOT_DIR "${THIRDPARTY_DIR}/grpc/third_party/protobuf")
set(PROTOBUF_SRC_DIR "${PROTOBUF_ROOT_DIR}/cmake")


# Build grpc

find_program(MAKE_EXE NAMES gmake nmake make)


# Set Protobuf library path
set(PROTOBUF_ROOT_DIR "${THIRDPARTY_DIR}/grpc/third_party/protobuf")
set(PROTOBUF_SRC_DIR "${PROTOBUF_ROOT_DIR}/cmake")

# Build protobuf project from the git submodule.
ExternalProject_Add(protobuf
  PREFIX protobuf
  SOURCE_DIR "${PROTOBUF_SRC_DIR}"
  CMAKE_CACHE_ARGS
        -Dprotobuf_BUILD_TESTS:BOOL=OFF
        -Dprotobuf_WITH_ZLIB:BOOL=OFF
        -Dprotobuf_MSVC_STATIC_RUNTIME:BOOL=OFF
        -DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_CURRENT_BINARY_DIR}/protobuf
		-Dprotobuf_BUILD_PROTOC_BINARIES:BOOL=OFF
        ${CMAKE_CHCHE_ARGS_CFLAGES_ADD}
		${_CMAKE_COMMON_BUILD_PARAMS}
)

# The location where protobuf-config.cmake will be installed varies by platform
set(Protobuf_DIR "${_FINDPACKAGE_PROTOBUF_CONFIG_DIR}")
set(_FINDPACKAGE_PROTOBUF_INCLUDE_DIR "${CMAKE_CURRENT_BINARY_DIR}/protobuf/include")
set(_FINDPACKAGE_PROTOBUF_LIB_DIR "${CMAKE_CURRENT_BINARY_DIR}/protobuf/lib")
set(_PROTOBUF_PROTOC_EXEC "${CMAKE_CURRENT_BINARY_DIR}/protobuf/bin/protoc")



ExternalProject_Add(grpc
  PREFIX grpc
  SOURCE_DIR "${THIRDPARTY_DIR}/grpc"
  CMAKE_CACHE_ARGS
	  -DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_CURRENT_BINARY_DIR}/grpc	   
	  -DgRPC_INSTALL:BOOL=OFF        
      -DgRPC_BUILD_TESTS:BOOL=OFF
	  -DgRPC_BUILD_GRPC_PYTHON_PLUGIN:BOOL=OFF
	  -DgRPC_BUILD_GRPC_RUBY_PLUGIN:BOOL=OFF
	  -DgRPC_BUILD_GRPC_PHP_PLUGIN:BOOL=OFF
	  -DgRPC_BUILD_GRPC_OBJECTIVE_C_PLUGIN:BOOL=OFF
	  -DgRPC_BUILD_GRPC_NODE_PLUGIN:BOOL=OFF	
	  -DgRPC_BUILD_GRPC_CSHARP_PLUGIN:BOOL=OFF
	  -DgRPC_BUILD_GRPC_CPP_PLUGIN:BOOL=OFF
	  -DgRPC_BUILD_CSHARP_EXT:BOOL=OFF
      -DgRPC_BUILD_CODEGEN:BOOL=OFF
  #  ${CMAKE_CHCHE_ARGS_CFLAGES_ADD}
  	${_CMAKE_COMMON_BUILD_PARAMS}
	#  ${_grpc_BUILD_PARAMS}
  BUILD_COMMAND  cmake --build . --target grpc++
  INSTALL_COMMAND ""
  )

# Builds GTest project from the git submodule.
ExternalProject_Add(GTest
PREFIX GTest
SOURCE_DIR "${THIRDPARTY_DIR}/GTest"  
CMAKE_CACHE_ARGS                
	  -DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_CURRENT_BINARY_DIR}/GTest
	  -DCMAKE_CXX_STANDARD:STRING=17
	  ${_CMAKE_COMMON_BUILD_PARAMS}
)

set(_FINDPACKAGE_GTEST_CONFIG_DIR "${CMAKE_CURRENT_BINARY_DIR}/GTest/lib/cmake/GTest")

# Builds leveldb
ExternalProject_Add(leveldb
  PREFIX leveldb
  #SOURCE_DIR "${THIRDPARTY_DIR}/leveldb"
  URL https://github.com/google/leveldb/archive/1.22.tar.gz
  CMAKE_CACHE_ARGS
		-DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_CURRENT_BINARY_DIR}/leveldb
		-DLEVELDB_BUILD_BENCHMARKS:BOOL=OFF
		-DLEVELDB_BUILD_TESTS:BOOL=OFF		
        ${CMAKE_CHCHE_ARGS_CFLAGES_ADD}
        ${_CMAKE_COMMON_BUILD_PARAMS}
  PATCH_COMMAND ${CMAKE_COMMAND} -E copy
        "${CMAKE_CURRENT_SOURCE_DIR}/../cmake.in/leveldb-patch/CMakeLists.foriOS.txt" <SOURCE_DIR>/CMakeLists.txt
)
set(_FINDPACKAGE_LEVELDB_DIR "${CMAKE_CURRENT_BINARY_DIR}/leveldb/lib/cmake/leveldb")
set(_FINDPACKAGE_LEVELDB_INCLUDE_DIR "${CMAKE_CURRENT_BINARY_DIR}/leveldb/include")




