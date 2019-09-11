# This file contains CMake macros and functions used to test
# for supported SAC2C features. Supported features are exposed
# through set CMake variables.

# List of feature variables:
#  * `HAVE_HEADER_PRAGMA`
#  * `HAVE_GENERIC_FLAG`

# For consistency all macros/functions should start with
# `CHECK_SAC2C_SUPPORT_*` where `*` is the feature being
# checked for.

# This macro checks if the SAC2C supports the `header`
# pragma. No compilation is needed for this check, so
# we break at the parsing phase of the compiler.
SET (HAVE_HEADER_PRAGMA NO)
MACRO (CHECK_SAC2C_SUPPORT_HEADER_PRAGMA)
    SET (_cshp_source "external int ilogb( double a);
  #pragma header \"<math.h>\"
int main() { return ilogb( 12d); }")

    EXECUTE_PROCESS (
        COMMAND ${CMAKE_COMMAND} -E echo "${_cshp_source}"
        COMMAND ${SAC2C_EXEC} -noPAB -bscp
        RESULT_VARIABLE _cshp_result
        OUTPUT_QUIET
        ERROR_QUIET)
    IF (${_cshp_result} STREQUAL "0")
        SET (HAVE_HEADER_PRAGMA YES)
    ENDIF ()
ENDMACRO ()

# This macro checks if SAC2C can use the `-generic`
# flag, which is needed to create modules that are compiled
# without architecture specific optimisations.
SET (HAVE_GENERIC_FLAG NO)
MACRO (CHECK_SAC2C_SUPPORT_GENERIC_FLAG)
    SET (_sgen_source "int main { return 0; }")

    EXECUTE_PROCESS (
        COMMAND ${CMAKE_COMMAND} -E echo "${_sgen_source}"
        COMMAND ${SAC2C_EXEC} -generic
        RESULT_VARIABLE _sgen_result
        OUTPUT_QUIET
        ERROR_QUIET)
    IF (${_sgen_result} STREQUAL "0")
        SET (HAVE_GENERIC_FLAG YES)
    ENDIF ()
ENDMACRO ()
