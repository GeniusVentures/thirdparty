# special settings for Windows build on windows machine
# this is the common stuff for building
cmake_minimum_required(VERSION 3.15)

# if on Windows system, build the windows executables
if (${CMAKE_HOST_SYSTEM_NAME} MATCHES "Windows")

project(WINDOWS_SHARED_THIRD_PARTY)
	set (CPACK_PACKAGE_VERSION_MAJOR "0")
	set (CPACK_PACKAGE_VERSION_MINOR "2")
	set (CPACK_PACKAGE_VERSION_PATCH "1")
	set (CPACK_PACKAGE_VERSION_PRE_RELEASE "1")
	set (CPACK_PACKAGE_VENDOR "Genius Ventures")

	set(CMAKE_CXX_STANDARD 17)
	set(CMAKE_CXX_STANDARD_REQUIRED ON)
	set(CMAKE_CXX_EXTENSIONS OFF)
	set(CMAKE_POSITION_INDEPENDENT_CODE TRUE)

	set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} /MT")
	set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} /MTd")

	include(../cmake.in/functions.cmake)
	include(ExternalProject)
	set(CXX_FLAGS_FOR_P2P "${CMAKE_CXX_FLAGS} /std:c++14 ")
	set(Boost_USE_STATIC_LIBS OFF)
	include(../CommonTargets.CMake)
	# Build curl 7.60
	ExternalProject_Add(curl
	PREFIX curl
	SOURCE_DIR "${THIRDPARTY_DIR}/curl-android-ios/curl"
	CMAKE_CACHE_ARGS
		-DBUILD_TESTING:BOOL=OFF
		-DCMAKE_USE_OPENSSL:BOOL=ON
		-DCURL_STATICLIB:BOOL=ON
		-DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_CURRENT_BINARY_DIR}/curl
	)
endif (${CMAKE_HOST_SYSTEM_NAME} MATCHES "Windows")

