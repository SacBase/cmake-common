
IF (SAC_DEV)
    SET (_SAC2C_NAME "sac2c_d")
    SET (_SAC4C_NAME "sac4c_d")
    SET (_SAC2TEX_NAME "sac2tex_d")
ELSE ()
    SET (_SAC2C_NAME "sac2c_p")
    SET (_SAC4C_NAME "sac4c_p")
    SET (_SAC2TEX_NAME "sac2tex_p")
ENDIF ()

SET (_SAC_HINTS)
IF (SAC2C_PATH AND IS_DIRECTORY "${SAC2C_PATH}")
    LIST (APPEND _SAC_HINT "${SAC2C_PATH}")
ELSEIF (SAC2C_PATH)
    CMAKE_PATH (REMOVE_FILENAME SAC2C_PATH)
    LIST (APPEND _SAC_HINT "${SAC2C_PATH}")
ENDIF ()

# hard-coded paths used for PATHS hint; can be override by user
SET (_SAC_PATHS /usr/local/bin)

FIND_PROGRAM (SAC_COMPILER
    NAMES ${_SAC2C_NAME}
    HINTS ${_SAC_HINTS}
    PATHS ${_SAC_PATHS}
    )

# XXX this should be included instead...
FUNCTION (PARSE_SAC2C_VERSION version major minor patch tweak)
    SET (_version "")
    SET (_major "")
    SET (_minor "")
    SET (_patch "")
    SET (_tweak "")

    STRING (REGEX REPLACE "^v" "" _version "${version}")
    STRING (REGEX REPLACE "\n" " " _version "${_version}")
    STRING (REGEX REPLACE "^sac2c ([0-9]+)\\.([0-9]+)\\.([0-9]+).*" "\\1" _major "${_version}")
    STRING (REGEX REPLACE "^sac2c ([0-9]+)\\.([0-9]+)\\.([0-9]+).*" "\\2" _minor "${_version}")
    STRING (REGEX REPLACE "^sac2c ([0-9]+)\\.([0-9]+)\\.([0-9]+).*" "\\3" _patch "${_version}")
    IF ("${_version}" MATCHES "-([0-9]+)(-g[a-f0-9]+)?(-dirty)? ")
        SET (_tweak "${CMAKE_MATCH_1}")
    ENDIF ()

    SET (${major} ${_major} PARENT_SCOPE)
    SET (${minor} ${_minor} PARENT_SCOPE)
    SET (${patch} ${_patch} PARENT_SCOPE)
    SET (${tweak} ${_tweak} PARENT_SCOPE)
ENDFUNCTION ()

IF (SAC_COMPILER)
    EXECUTE_PROCESS (COMMAND ${SAC_COMPILER} -V
        RESULT_VARIABLE _sac_ver
        OUTPUT_VARIABLE _sac_var
        ERROR_VARIABLE _sac_var # unify output
        OUTPUT_STRIP_TRAILING_WHITESPACE
        ERROR_STRIP_TRAILING_WHITESPACE)
    IF (_sac_ver)
        IF (_sac_var NOT MATCHES "^sac2c")
            SET (SAC_COMPILER SAC_COMPILER-NOTFOUND)
        ELSEIF (${SAC_FIND_REQUIRED})
            MESSAGE (FATAL_ERROR "Error executing sac2c -V!")
        ELSE ()
            MESSAGE (STATUS "Warning, could not run sac2c -V!")
        ENDIF ()
    ELSE ()
        PARSE_SAC2C_VERSION ("${_sac_var}" SAC_VERSION_MAJOR SAC_VERSION_MINOR SAC_VERSION_PATCH SAC_VERSION_TWEAK)
        SET (SAC_VERSION "${SAC_VERSION_MAJOR}.${SAC_VERSION_MINOR}.${SAC_VERSION_PATCH}.${SAC_VERSION_TWEAK}")
    ENDIF ()
ENDIF ()

# We need to preset some variables for later use; like in UseSAC.cmake
# These do not (?) directly depend on the given target; XXX does this also work for cross-compilation?
EXECUTE_PROCESS (COMMAND ${SAC_COMPILER} -COBJEXT
    OUTPUT_VARIABLE _SAC_OBJ_EXT OUTPUT_STRIP_TRAILING_WHITESPACE)
SET (SAC_OBJ_EXT "${_SAC_OBJ_EXT}" CACHE INTERNAL "")
EXECUTE_PROCESS (COMMAND ${SAC_COMPILER} -CMODEXT
    OUTPUT_VARIABLE _SAC_MOD_EXT OUTPUT_STRIP_TRAILING_WHITESPACE)
SET (SAC_MOD_EXT "${_SAC_MOD_EXT}" CACHE INTERNAL "")
EXECUTE_PROCESS (COMMAND ${SAC_COMPILER} -CTREE_DLLEXT
    OUTPUT_VARIABLE _SAC_TREE_DLL_EXT OUTPUT_STRIP_TRAILING_WHITESPACE)
SET (SAC_TREE_DLL_EXT "${_SAC_TREE_DLL_EXT}" CACHE INTERNAL "")

FIND_PROGRAM (SAC_C_COMPILER
    NAMES saccc
    HINTS ${_SAC_HINTS}
    PATHS ${_SAC_PATHS}
    )

FIND_PROGRAM (SAC_4C_COMPILER
    NAMES ${_SAC4C_NAME}
    HINTS ${_SAC_HINTS}
    PATHS ${_SAC_PATHS}
    )

FIND_PROGRAM (SAC_TEX_COMPILER
    NAMES ${_SAC2TEX_NAME}
    HINTS ${_SAC_HINTS}
    PATHS ${_SAC_PATHS}
    )

