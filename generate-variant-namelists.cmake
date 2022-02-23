# Generate VNLS, a list of variants for one sac program,
# from an optional variants file, e.g., LivermoreLoops/loop01.variants
# I.e., a variants file has the same name as the sac program, but 
# with the extension .variants. 
#
# A variants file has the following syntax:
#       <suffix1>: <flags1>
#       ...
#       <suffixN>: <flagsN>
#
# This specifies that a sac program (e.g. foo.sac) should build the following
# binaries:
#      foo<suffix1>, foo<suffix2>, ... foo<suffixN>
#
# each foo<suffixI> is built by calling:
#      sac2c <flagsI> -o foo<suffixI>
#
# Arguments:
#     name:  name of the sac file, relative to CMAKE_CURRENT_SOURCE_DIR, e g., loop08
#
# Result: 
#     VNLS: The variants file text, with NLs replaced by semicolons

MACRO (GENERATE_VARIANT_NAMELISTS name)
    GET_FILENAME_COMPONENT (namewe ${name} NAME_WE)
    SET (variants_file "${CMAKE_CURRENT_SOURCE_DIR}/${namewe}.variants")
    IF (EXISTS "${variants_file}")
        # MESSAGE (STATUS "Variant file " ${variants_file} " found for " ${name})
        FILE (READ ${variants_file} content)
        STRING (REPLACE "\n" ";" lines ${content})
        # MESSAGE( STATUS "VNLS for " ${namewe} " are " ${VNLS})
    ELSE ()
        # MESSAGE (STATUS "No variant file " ${variants_file} " found for " ${name})
    ENDIF ()
ENDMACRO ()

