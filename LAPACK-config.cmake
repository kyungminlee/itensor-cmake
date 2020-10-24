if(WIN32)
    if(NOT DEFINED BLA_VENDOR)
        set(BLA_VENDOR "OpenBLAS")
    endif()

    if("${BLA_VENDOR}" STREQUAL "OpenBLAS")
        set(PLATFORM "openblas")
        if(NOT DEFINED OpenBLAS_ROOT)
            message(STATUS "\
Using downloaded OpenBLAS for BLAS/LAPACK.
libopenblas.dll will be copied to ${CMAKE_INSTALL_PREFIX}/bin.
Make sure to copy libopenblas.dll to the same directory as the executable, or to a directory in the PATH")
            include(ExternalProject)
            ExternalProject_Add(
                OpenBLAS
                PREFIX "OpenBLAS-x64"
                URL "https://github.com/xianyi/OpenBLAS/releases/download/v0.3.10/OpenBLAS-0.3.10-x64.zip"
                URL_HASH SHA512=9357a9af0de45dea38afed36f73d03f8b2c6acdbabbf2420eb5ec03c7e069be92d524261666b738aa6941d4d19a78eeb528614f5ee4d72949dec1cf2874dfe06
                CONFIGURE_COMMAND ""
                BUILD_COMMAND ""
                INSTALL_COMMAND ""
            )
            ExternalProject_Get_Property(OpenBLAS SOURCE_DIR)
            set(OpenBLAS_ROOT "${SOURCE_DIR}")
            set(LAPACK_INCLUDE_DIRS "${OpenBLAS_ROOT}/include")
            set(LAPACK_LIBRARIES "${OpenBLAS_ROOT}/lib/libopenblas.lib")
            install(
                DIRECTORY "${OpenBLAS_ROOT}/include"
                DESTINATION "${CMAKE_INSTALL_PREFIX}"
            )
            install(
                DIRECTORY "${OpenBLAS_ROOT}/bin"
                DESTINATION "${CMAKE_INSTALL_PREFIX}"
            )
        else()
            message(STATUS "Using system OpenBLAS for BLAS/LAPACK")
            set(OpenBLAS_ROOT "${SOURCE_DIR}")
            set(LAPACK_INCLUDE_DIRS "${OpenBLAS_ROOT}/include")
            set(LAPACK_LIBRARIES "${OpenBLAS_ROOT}/lib/libopenblas.lib")
        endif()

        set(LAPACK_HEADER "\
#ifndef __ASSERT_MACROS_DEFINE_VERSIONS_WITHOUT_UNDERSCORES
#define __ASSERT_MACROS_DEFINE_VERSIONS_WITHOUT_UNDERSCORES 0
#endif

#ifndef HAVE_LAPACK_CONFIG_H
#define HAVE_LAPACK_CONFIG_H
#endif

#ifndef LAPACK_COMPLEX_STRUCTURE
#define LAPACK_COMPLEX_STRUCTURE
#endif
")
        include_directories("${LAPACK_INCLUDE_DIRS}")
    elseif("${BLA_VENDOR}" MATCHES "Intel.*")
        message(STATUS "Using MKL for BLAS/LAPACK")
        message(STATUS "Set environment variable LAPACK_INCLUDE_DIR if build fails")
        set(PLATFORM "mkl")
        find_package(LAPACK REQUIRED)
    else()
        message(FATAL_ERROR "Unsupported BLAS/LAPACK: ${BLA_VENDOR}")
    endif()
else()
    if(NOT DEFINED BLA_VENDOR)
        message(FATAL_ERROR "Please set BLA_VENDOR: Check https://cmake.org/cmake/help/v3.14/module/FindLAPACK.html")
    endif()

    if("${BLA_VENDOR}" MATCHES "Intel.*")
        message(STATUS "Using MKL for BLAS/LAPACK")
        set(PLATFORM "mkl")
    elseif("${BLA_VENDOR}" STREQUAL "OpenBLAS")
        message(STATUS "Using OpenBLAS for BLAS/LAPACK")
        set(PLATFORM "openblas")
    elseif("${BLA_VENDOR}" STREQUAL "Apple")
        message(STATUS "Using Accelerate Framework for BLAS/LAPACK")
        set(PLATFORM "macos")
    elseif("${BLA_VENDOR}" STREQUAL "Generic")
        message(STATUS "Using Generic BLAS/LAPACK")
        set(PLATFORM "lapack")
    else()
        message(FATAL_ERROR "Unsupported BLAS/LAPACK: ${BLA_VENDOR}")
    endif()
        message(STATUS "Set environment variable LAPACK_INCLUDE_DIR if build fails")

    if(DEFINED ENV{LAPACK_INCLUDE_DIR})
        message(STATUS "Adding include directory $ENV{LAPACK_INCLUDE_DIR} for BLAS/LAPACK")
        include_directories($ENV{LAPACK_INCLUDE_DIR})
    endif()

    if(NOT DEFINED LAPACK_LIBRARIES)
        find_package(LAPACK REQUIRED)
        if("${BLA_VENDOR}" STREQUAL "OpenBLAS" OR "${BLA_VENDOR}" STREQUAL "Generic")
            find_library(PTHREAD_LIB "pthread")
            list(APPEND LAPACK_LIBRARIES ${PTHREAD_LIB})
        endif()
    endif()
endif()

