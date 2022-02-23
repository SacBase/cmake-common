
# This macro adds a recipe to compile a sac program taking a variants file
# into account. A variants file has the same name as the sac program, but 
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
#           each variant.
#
MACRO (COMPILE_SAC2C_WITH_VARIANTS name local_sac_modules sac1c_flags) 
    #MESSAGE ("===== ${name}, ${local_sac_modules}, ${sac2c_flags}")
    # Full path to the sac source code.
    SET (src "${CMAKE_CURRENT_SOURCE_DIR}/${name}")
    # sac2c requires objectfile specification relative to the working directory
    # of the call to sac2c.
    GET_FILENAME_COMPONENT (dir "${CMAKE_CURRENT_BINARY_DIR}/${name}" DIRECTORY)
    GET_FILENAME_COMPONENT (namewe ${name} NAME_WE)

    SET (variants_file "${CMAKE_CURRENT_SOURCE_DIR}/${namewe}.variants")
    MESSAGE (STATUS "variants_file is " ${variants_file})
    IF (EXISTS "${variants_file}")
        FILE (READ ${variants_file} content)
        STRING (REPLACE "\n" ";" variantlines ${content})
        ##SET( variantlines ${content})
        ##MESSAGE (STATUS "variantlines are: " ${variantlines})

        FOREACH (l ${variantlines})
            STRING (REGEX MATCH "([a-zA-Z_0-9]+)[ \t]*:[ \t]*(.*)" match ${l})
            IF (NOT match)
                MESSAGE (FATAL_ERROR 
                         "error while parsing variants file ${variants_file}:\n${l}")
            ENDIF ()
            SET (suffix "${CMAKE_MATCH_1}")
            STRING (REGEX REPLACE "[ \t]+" ";" flags "${CMAKE_MATCH_2}")
            SET (binary "${namewe}${suffix}")
            #MESSAGE ("-- ${l}: (${suffix}, ${flags})")
            #SAC2C_COMPILE (${dir} ${src} ${binary} ${flags})
            SET (new_flags ${sac2c_flags} ${flags})
            SAC2C_COMPILE_PROG_DEPS (${name} ${binary} "${variants_file}" "${local_sac_modules}" "${new_flags}")
        ENDFOREACH ()
    ELSE ()
            SET (binary "${namewe}-${TARGET}")
            #SAC2C_COMPILE (${dir} ${src} ${binary} "")
            SAC2C_COMPILE_PROG (${name} ${binary} "${local_sac_modules}" "${sac2c_flags}")
    ENDIF ()
ENDMACRO ()
