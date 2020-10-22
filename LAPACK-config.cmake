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
        set(PLATFORM "mkl")
        if (NOT DEFINED ENV{MKLROOT})
            message(FATAL_ERROR "Please define MKLROOT environment variable")
        endif()
        set(MKL_ROOT $ENV{MKLROOT})

        include_directories("${MKL_ROOT}/include")
        find_package(LAPACK REQUIRED)
    else()
        message(FATAL_ERROR "unsupported BLAS/LAPACK: ${BLA_VENDOR}")
    endif()
else()
    if(NOT DEFINED LAPACK_LIBRARIES)
        find_package(LAPACK REQUIRED)
    endif()
endif()

