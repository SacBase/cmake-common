# Find the SaC compiler; note that we use saccc here instead of sac2c
# as the former supports standard C/C++ flags.
find_program(
    CMAKE_SAC_COMPILER "saccc"
    HINTS "/usr/local/bin" "${CMAKE_SOURCE_DIR}"
    DOC "SaC compiler"
)
mark_as_advanced(CMAKE_SAC_COMPILER)

set(CMAKE_SAC_SOURCE_FILE_EXTENSIONS sac;SAC)
set(CMAKE_SAC_OUTPUT_EXTENSION .out)
set(CMAKE_SAC_COMPILER_ENV_VAR "SAC")

# Configure variables set in this file for fast reload later on
configure_file(${CMAKE_CURRENT_LIST_DIR}/CMakeSACCompiler.cmake.in
               ${CMAKE_PLATFORM_INFO_DIR}/CMakeSACCompiler.cmake)
