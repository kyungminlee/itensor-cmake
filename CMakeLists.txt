cmake_minimum_required (VERSION 3.10)

if (POLICY CMP0048)
    cmake_policy(SET CMP0048 NEW)
endif(POLICY CMP0048)

project(ITensor
    LANGUAGES CXX
    HOMEPAGE_URL "https://itensor.org"
    VERSION "3.1.5"
    )

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

set(CMAKE_DISABLE_SOURCE_CHANGES ON)
set(CMAKE_DISABLE_IN_SOURCE_BUILD ON)

if(MSVC)
    add_compile_options(/bigobj /permissive-)
    if(NOT ${CMAKE_VERBOSE_MAKEFILE})  # Replace with a better option
        message(STATUS "Suppressing warnings (quiet mode)")
        add_compile_options(/wd4267 /wd4996 /wd4244 /wd4101 /wd4834)
        add_definitions(-D_CRT_SECURE_NO_WARNINGS -D_SILENCE_ALL_CXX17_DEPRECATION_WARN)
    endif()
else()
    # add_compile_options(-std=c++17)
endif()

include("LAPACK-config.cmake")

# === Configuration ===
include_directories("${CMAKE_BINARY_DIR}" "${CMAKE_INSTALL_PREFIX}/include")

set(ITENSOR_CONFIG_H "${CMAKE_BINARY_DIR}/itensor/config.h")
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
    set(ITENSOR_UNISTD_H "${CMAKE_BINARY_DIR}/unistd.h")
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

add_library(itensor STATIC ${SOURCES})

# === Install library file ===
install(
    TARGETS
    itensor
    ARCHIVE DESTINATION lib
)

# === Install header files ===
set(SUBDIRS "." "detail" "itdata" "mps" "mps/lattice" "mps/sites" "tensor" "util" "util/h5" "util/h5/std_addons" "util/h5/stl")
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
