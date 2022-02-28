
# This macro adds a recipe to compile a sac program using a variants file.
# Variants let someone generate several different code, via #ifdef.
#
# A variants file has the same name as the sac program, but 
# with the extension .variant, e.g. a variant file for a.sac would be a.variant.
#
# A variant file has the following syntax:
#       <suffix1>: <flags1>
#       ...
#       <suffixN>: <flagsN>
#
# This specifies that a sac program (e.g. a.sac) should build the following
# binaries:
#
#      a<suffix1>, a<suffix2>, ... a<suffixN>
#
# each a<suffixI> is built by calling:
#      sac2c <flagsI> -o a<suffixI>
#
# Arguments:
#     name:  
#           name of the sac file, relative to CMAKE_CURRENT_SOURCE_DIR
#     local_sac_modules:
#           a list of sac modules that should participate in dependency
#           resolution.  See cmake-common/resolve-sac2c-dependencies.cmake
#           for more details
#     sac2c_flags:
#           sac2c flags that are used when calling the sac2c compiler, for
#           each variant. E.g., -DAPL. 
#
MACRO (CTEST_SAC2C_WITH_VARIANTS name local_sac_modules sac2c_flags) 
    #MESSAGE ("===== ${name}, ${local_sac_modules}, ${sac2c_flags}")
    # Full path to the sac source code.
    SET (src "${CMAKE_CURRENT_SOURCE_DIR}/${name}")
    # sac2c requires objectfile specification relative to the working directory
    # of the call to sac2c.
    GET_FILENAME_COMPONENT (dir "${CMAKE_CURRENT_BINARY_DIR}/${name}" DIRECTORY)
    GET_FILENAME_COMPONENT (namewe ${name} NAME_WE)

    SET (variants_file "${CMAKE_CURRENT_SOURCE_DIR}/${namewe}.variants")
    IF (EXISTS "${variants_file}")
        FILE (READ ${variants_file} content)
        STRING (REPLACE "\n" ";" variantlines ${content})
        ##SET( variantlines ${content})
        ##MESSAGE (STATUS "variantlines are: " ${variantlines})

        FOREACH (VAR ${variantlines})
            ##MESSAGE (STATUS "VAR in foreach is " ${VAR})
            STRING (REGEX MATCH "([a-zA-Z_0-9]+)[ \t]*:[ \t]*(.*)" match ${VAR})
            IF (NOT match)
                MESSAGE (FATAL_ERROR 
                         "ctest setup error while parsing variants file ${variants_file}:\n${VAR}")
            ENDIF ()
            SET (suffix "${CMAKE_MATCH_1}")
            ##MESSAGE (STATUS "ctest suffix is " ${suffix})
            STRING (REGEX REPLACE "[ \t]+" ";" flags "${CMAKE_MATCH_2}")

            SET (binary "${namewe}${suffix}")
            ##MESSAGE (STATUS " binary is " ${binary})
            SET (new_flags ${sac2c_flags} ${flags})
            ##MESSAGE (STATUS "flags is " ${flags})
            ##MESSAGE (STATUS "sac2c_flags is " ${sac2c_flags})
            ##MESSAGE (STATUS "and new_flags is " ${new_flags})
            MESSAGE (STATUS "ADD_TEST with variants BM_DIR " ${BM_DIR})
            SET (PBF "${PROJECT_BINARY_DIR}/${BM_NAME}-${TARGET}") # Project Binary folder
            ##MESSAGE (STATUS "PBF is " ${PBF})


            # FIXME Multi-thread testing - parallel slowdown!!
            SET (THREDS 1 2 )
            SET (INF ${CMAKE_SOURCE_DIR}/${BM_NAME}/${BM_NAME}.inp)
            FILE(STRINGS ${INF} inp)
            ##MESSAGE (STATUS "input is " ${inp})
            FOREACH (THRED ${THREDS})
              ### input file broken.  SET (CMD  COMMAND "${PBF}/${binary} -mt ${THRED} < ${INF}")
              SET (CMD  COMMAND ${PBF}/${binary} -mt ${THRED}" " ${inp})
              MESSAGE (STATUS "CMD " ${CMD})
              ADD_TEST (NAME Test-${TARGET}-${binary}-mt${THRED} COMMAND ${CMD})
            ENDFOREACH ()
        ENDFOREACH ()

    ELSE ()  ## No variants
       SET (PBF "${PROJECT_BINARY_DIR}/${BM_NAME}-${TARGET}") # Project Binary folder
       SET (binary "${namewe}-${TARGET}")
       SET (THREDS 1 2)
       SET (INF ${CMAKE_SOURCE_DIR}/${BM_NAME}/${BM_NAME}.inp)
       FILE(STRINGS ${INF} inp)
       ##MESSAGE (STATUS "input is " ${inp})
       MESSAGE (STATUS "ADD_TEST with no variants BM_DIR " ${BM_DIR})
            FOREACH (THRED ${THREDS})
              # input file broken  SET (CMD  COMMAND "${PBF}/${binary} -mt ${THRED} < ${INF}")
              SET (CMD  COMMAND ${PBF}/${binary} -mt ${THRED}" " ${inp})
              MESSAGE (STATUS "CMD " ${CMD})
              ADD_TEST (NAME Test-${TARGET}-${binary}-mt${THRED} COMMAND ${CMD})
            ENDFOREACH ()
    ENDIF ()
ENDMACRO ()
