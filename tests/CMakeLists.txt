add_executable(test1 test1.cc)
target_link_libraries(test1 itensor ${LAPACK_LIBRARIES})

add_test(
    NAME
        itensor-test
    COMMAND
        test1)
if(WIN32)
    set_tests_properties(
        itensor-test
        PROPERTIES ENVIRONMENT "PATH=${OpenBLAS_ROOT}/bin;$ENV{PATH}" )
endif()

