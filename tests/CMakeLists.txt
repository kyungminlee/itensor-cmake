message(STATUS "LAPACK: ${LAPACK_LIBRARIES}")
add_executable(test-static test1.cc)
target_link_libraries(test-static itensor-static ${LAPACK_LIBRARIES})
add_dependencies(test-static itensor-static)

if(WIN32)
    add_test(NAME itensor-test COMMAND test-static)
    set_tests_properties(
        itensor-test
        PROPERTIES ENVIRONMENT "PATH=${OpenBLAS_ROOT}/bin;$ENV{PATH}" )
else()
    add_executable(test-shared test1.cc)
    target_link_libraries(test-shared itensor-shared ${LAPACK_LIBRARIES})
    add_dependencies(test-shared itensor-shared)

    add_test(NAME itensor-test COMMAND test-static && test-shared)
endif()

