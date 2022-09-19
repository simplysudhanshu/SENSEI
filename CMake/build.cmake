set(CMAKE_POSITION_INDEPENDENT_CODE ON)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_CXX_VISIBILITY_PRESET hidden)
set(CMAKE_C_VISIBILITY_PRESET hidden)
set(CMAKE_VISIBILITY_INLINES_HIDDEN ON)

option(BUILD_SHARED_LIBS OFF "Build shared libraries by default")
option(BUILD_STATIC_EXECS  OFF "Link executables statically")
if (BUILD_STATIC_EXECS)
  set(BUILD_SHARED_LIBS OFF FORCE)
  set(CMAKE_FIND_LIBRARY_SUFFIXES ${CMAKE_STATIC_LIBRARY_SUFFIX})
  set(LINK_SEARCH_START_STATIC TRUE)
  set(LINK_SEARCH_END_STATIC TRUE)
endif()

if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE "Release"
  CACHE STRING "Choose the type of build, options are: Debug Release RelWithDebInfo MinSizeRel." FORCE)
  set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS "Debug" "Release" "MinSizeRel" "RelWithDebInfo")
endif()

# Add the requisite flags. CMake enthusiasts will tell you this is "not the
# CMake way".  Unfortunately the officially cmake sanctioned methods are
# inconsistent, and don't work in some cases.  Nontheless, we allow one
# to override CMAKE_CXX_FLAGS on the command line for those that need or want
# to do so.
if (NOT CMAKE_CXX_FLAGS)
    set(tmp "-fPIC -std=c++17 -Wall -Wextra -fvisibility=hidden")
    if ((APPLE) AND ("${CMAKE_CXX_COMPILER_ID}" MATCHES "Clang"))
        set(tmp "${tmp} -stdlib=libc++")
    endif()
    if ("${CMAKE_BUILD_TYPE}" MATCHES "Release")
        set(tmp "${tmp} -O3 -march=native -mtune=native -fno-trapping-math -fno-math-errno")
        if (NOT "${CMAKE_CXX_COMPILER_ID}" MATCHES "Clang")
            set(tmp "${tmp} -fno-signaling-nans")
        endif()
    endif()
    set(CMAKE_CXX_FLAGS "${tmp}"
        CACHE STRING "SENSEI build defaults"
        FORCE)
    string(REGEX REPLACE "-O[0-9]" "-O3" tmp "${CMAKE_CXX_FLAGS_RELEASE}")
    set(CMAKE_CXX_FLAGS_RELEASE "${tmp}"
        CACHE STRING "SENSEI build defaults"
        FORCE)
endif()

if (NOT CMAKE_CUDA_FLAGS)
    set(tmp "--default-stream per-thread --expt-relaxed-constexpr")
    if ("${CMAKE_BUILD_TYPE}" MATCHES "Release")
        set(tmp "${tmp} -Xcompiler -Wall,-Wextra,-O3,-march=native,-mtune=native,-fno-trapping-math,-fno-math-errno,-fvisibility=hidden")
        if (NOT "${CMAKE_CXX_COMPILER_ID}" MATCHES "Clang")
            set(tmp "${tmp},-fno-signaling-nans")
        endif()
    elseif ("${CMAKE_BUILD_TYPE}" MATCHES "Debug")
        set(tmp "${tmp} -g -G -Xcompiler -Wall,-Wextra,-O0,-g,-fvisibility=hidden")
    endif()
    set(CMAKE_CUDA_FLAGS "${tmp}"
        CACHE STRING "SENSEI build defaults"
        FORCE)
    string(REGEX REPLACE "-O[0-9]" "-O3" tmp "${CMAKE_CUDA_FLAGS_RELEASE}")
    set(CMAKE_CUDA_FLAGS_RELEASE "${tmp}"
        CACHE STRING "SENSEI build defaults"
        FORCE)
endif()

include_directories(${CMAKE_SOURCE_DIR})
include_directories(${CMAKE_BINARY_DIR})

include(GNUInstallDirs)

set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/${CMAKE_INSTALL_LIBDIR}")
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/${CMAKE_INSTALL_LIBDIR}")
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/${CMAKE_INSTALL_BINDIR}")
set(sensei_CMAKE_INSTALL_CMAKEDIR ${CMAKE_INSTALL_LIBDIR}/cmake/sensei)

message(STATUS "CMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}")
message(STATUS "CMAKE_CXX_FLAGS=${CMAKE_CXX_FLAGS}")
message(STATUS "BUILD_SHARED_LIBS=${BUILD_SHARED_LIBS}")
message(STATUS "BUILD_STATIC_EXECS=${BUILD_STATIC_EXECS}")
message(STATUS "CMAKE_ARCHIVE_OUTPUT_DIRECTORY=${CMAKE_ARCHIVE_OUTPUT_DIRECTORY}")
message(STATUS "CMAKE_LIBRARY_OUTPUT_DIRECTORY=${CMAKE_LIBRARY_OUTPUT_DIRECTORY}")
message(STATUS "CMAKE_RUNTIME_OUTPUT_DIRECTORY=${CMAKE_RUNTIME_OUTPUT_DIRECTORY}")
