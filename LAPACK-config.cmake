if(WIN32)
    if(NOT DEFINED OpenBLAS_ROOT)
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
    endif()
    set(PLATFORM openblas)
else()
    if(NOT DEFINED LAPACK_LIBRARIES)
        find_package(LAPACK REQUIRED)
    endif()
endif()

include_directories("${LAPACK_INCLUDE_DIRS}")
