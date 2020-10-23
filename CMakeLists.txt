cmake_minimum_required (VERSION 3.14)
if (POLICY CMP0048)
    cmake_policy(SET CMP0048 NEW)
endif(POLICY CMP0048)

set(ITENSOR_VERSION_MAJOR 3)
set(ITENSOR_VERSION_MINOR 1)
set(ITENSOR_VERSION_PATCH 5)
set(ITENSOR_VERSION_STRING ${ITENSOR_VERSION_MAJOR}.${ITENSOR_VERSION_MINOR}.${ITENSOR_VERSION_PATCH})

project(ITensor
    LANGUAGES CXX
    HOMEPAGE_URL "https://itensor.org"
    VERSION ${ITENSOR_VERSION_STRING}
    )

# === Options ===
if(MSVC)
    option(BUILD_STATIC "Build static library" ON)
    option(BUILD_SHARED "Build shared library" OFF)
else()
    option(BUILD_STATIC "Build static library" ON)
    option(BUILD_SHARED "Build shared library" ON)
endif()

if((NOT BUILD_STATIC) AND (NOT BUILD_SHARED))
    message(FATAL_ERROR "At least one of BUILD_STATIC and BUILD_SHARED should be ON")
endif()

if(BUILD_SHARED AND MSVC)
    message(WARNING "BUILD_SHARED not supported for MSVC")
endif()

# === Properties ===
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_DISABLE_SOURCE_CHANGES ON)
set(CMAKE_DISABLE_IN_SOURCE_BUILD ON)

# === Compile Options ===
if(MSVC)
    add_compile_options(/bigobj /permissive-)
    if(NOT ${CMAKE_VERBOSE_MAKEFILE})  # Replace with a better option
        message(STATUS "Suppressing warnings (quiet mode)")
        add_compile_options(/wd4267 /wd4996 /wd4244 /wd4101 /wd4834)
        add_definitions(-D_CRT_SECURE_NO_WARNINGS -D_SILENCE_ALL_CXX17_DEPRECATION_WARN)
    endif()
endif()

# === LAPACK ===
include("LAPACK-config.cmake")

# === Configuration ===
include_directories("${CMAKE_CURRENT_BINARY_DIR}" "${CMAKE_INSTALL_PREFIX}/include")

set(ITENSOR_CONFIG_H "${CMAKE_CURRENT_BINARY_DIR}/itensor/config.h")
file(WRITE  ${ITENSOR_CONFIG_H} "\
#ifndef __ITENSOR_CONFIG_H
#define __ITENSOR_CONFIG_H

#ifndef PLATFORM_${PLATFORM}
#define PLATFORM_${PLATFORM}
#endif

${LAPACK_HEADER}

#endif
")

if(WIN32)
    # Workaround for unistd.h on Windows
    set(ITENSOR_UNISTD_H "${CMAKE_CURRENT_BINARY_DIR}/unistd.h")
    file(WRITE ${ITENSOR_UNISTD_H} "\
#ifndef __ITENSOR_UNISTD_H
#define __ITENSOR_UNISTD_H

#ifndef _CRT_NONSTDC_NO_WARNINGS
#define _CRT_NONSTDC_NO_WARNINGS
#endif

#include <process.h>

#endif
")
endif()

# === Sources ===
set(SOURCES
    qn.cc tagset.cc index.cc indexset.cc itensor.cc spectrum.cc
    decomp.cc hermitian.cc svd.cc global.cc
    util/args.cc util/input.cc util/cputime.cc
    tensor/lapack_wrap.cc tensor/vec.cc tensor/mat.cc tensor/gemm.cc tensor/algs.cc tensor/contract.cc
    itdata/dense.cc itdata/combiner.cc itdata/diag.cc itdata/qdense.cc
    itdata/qcombiner.cc itdata/qdiag.cc itdata/scalar.cc
    mps/mps.cc mps/mpsalgs.cc mps/mpo.cc mps/mpoalgs.cc mps/autompo.cc)
list(TRANSFORM SOURCES PREPEND "${PROJECT_SOURCE_DIR}/ITensor/itensor/")

include_directories("${PROJECT_SOURCE_DIR}/ITensor")

# === Add Targets ===
add_library(itensor-obj OBJECT ${SOURCES})
set_property(TARGET itensor-obj PROPERTY POSITION_INDEPENDENT_CODE ON)

if(BUILD_STATIC)
    add_library(itensor-static STATIC $<TARGET_OBJECTS:itensor-obj>)
    set_target_properties(itensor-static PROPERTIES OUTPUT_NAME itensor)
    list(APPEND INSTALL_TARGETS itensor-static)
    set_target_properties(
        itensor-static
        PROPERTIES
            VERSION ${ITENSOR_VERSION_STRING}
            SOVERSION ${ITENSOR_VERSION_MAJOR}
    )
endif()

if(BUILD_SHARED)
    add_library(itensor-shared SHARED $<TARGET_OBJECTS:itensor-obj>)
    target_link_libraries(itensor-shared ${LAPACK_LIBRARIES})
    set_target_properties(itensor-shared PROPERTIES OUTPUT_NAME itensor)
    list(APPEND INSTALL_TARGETS itensor-shared)
    set_target_properties(
        itensor-shared
        PROPERTIES
            VERSION ${ITENSOR_VERSION_STRING}
            SOVERSION ${ITENSOR_VERSION_MAJOR}
    )
endif()

# === Install library file ===
install(
    TARGETS
        ${INSTALL_TARGETS}
    ARCHIVE DESTINATION
        lib
)

# === Install header files ===
set(SUBDIRS
    "." "detail" "itdata" "mps" "mps/lattice" "mps/sites"
    "tensor" "util" "util/h5" "util/h5/std_addons" "util/h5/stl")
foreach(subdir ${SUBDIRS})
    file(GLOB headerFiles
        RELATIVE "${PROJECT_SOURCE_DIR}/ITensor/itensor"
        "${PROJECT_SOURCE_DIR}/ITensor/itensor/${subdir}/*.h"
        "${PROJECT_SOURCE_DIR}/ITensor/itensor/${subdir}/*.ih"
        "${PROJECT_SOURCE_DIR}/ITensor/itensor/${subdir}/*.hpp"
    )
    list(APPEND HEADER_FILES ${headerFiles})
endforeach()

foreach(file ${HEADER_FILES})
    get_filename_component(dir ${file} DIRECTORY)
    install(FILES "${PROJECT_SOURCE_DIR}/ITensor/itensor/${file}" DESTINATION include/itensor/${dir})
endforeach()

install(
    FILES ${ITENSOR_CONFIG_H}
    DESTINATION "include/itensor"
)

if(WIN32)
    install(
        FILES ${ITENSOR_UNISTD_H}
        DESTINATION "include"
    )
endif()

enable_testing()
add_subdirectory(tests)
