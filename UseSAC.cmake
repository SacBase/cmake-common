# This file includes several functions to help with creating SAC applications and modules.

# This is a helper function and *should not* be called directly unless you know what
# you're doing.
#
# Functions adds commands to generate object files from C sources, which are dependencies
# to modules.
#
# Options:
#
#  TARGET      target     build using specified target (default is 'seq')
#  SRCS        file [...] C-source files dependencies (compiled to *.o files for linking)
#  DSTS                   return value; contains list of object files
#
FUNCTION (_ADD_C_SOURCE _TARGET _SRCS _DSTS)
    SET (_ret)
    FOREACH (name ${_SRCS})
        SET (src "${CMAKE_CURRENT_SOURCE_DIR}/${name}")

        GET_FILENAME_COMPONENT (dir ${name} DIRECTORY)
        GET_FILENAME_COMPONENT (nwe ${name} NAME_WE)

        FILE (REAL_PATH "${CMAKE_CURRENT_BINARY_DIR}/${dir}/${nwe}${SAC_OBJ_EXT}" dst)
        LIST (APPEND _ret "${dst}")

        # Make sure that we put the object file in the same location where
        # the source file was.
        FILE (MAKE_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/${dir}")

        ADD_CUSTOM_COMMAND (
            OUTPUT "${dst}"
            MAIN_DEPENDENCY "${src}"
            IMPLICIT_DEPENDS C "${src}"
            COMMAND
                ${SAC_C_COMPILER} ${SAC_COMPILER} "mod" "${_TARGET}"
                -I${CMAKE_CURRENT_SOURCE_DIR}/${dir} -I${CMAKE_CURRENT_BINARY_DIR}/${dir}
                -c -o "${dst}" "${src}"
            WORKING_DIRECTORY
                "${CMAKE_CURRENT_BINARY_DIR}/${dir}"
            COMMENT "Generating ${nwe}${SAC_OBJ_EXT} for target `${_TARGET}'"
            )
    ENDFOREACH (name)
    SET (${_DSTS} "${_ret}" PARENT_SCOPE)
ENDFUNCTION ()

# This functions is similar to the `add_executable` builtin, it takes a executable name
# and a source files, and compile this into the executable. It differs in one critical way
# from the builtin function, the executable name *is not* the target name --- there is a
# limitation with CMake in regards to `add_custom_command` and `add_custom_target` having
# overlapping names (output name of command and target name respectively), see
# https://gitlab.kitware.com/cmake/cmake/-/issues/18627 for more details.
#
# Options:
#
#  TARGET      target     build using specified target (default is 'seq')
#  OUTPUT_NAME name       specify other name for executable (default is first argument)
#  OUTPUT_DIR  dir        specify other output path for exectuable (default is build directory)
#  EXCLUDE_FROM_ALL       flag, mark that executable should not be built by default
#  CSOURCES    file [...] C-source files dependencies (compiled to *.o files for linking)
#
FUNCTION (ADD_SAC_EXECUTABLE _TARGET_NAME _SOURCE_FILE)
    CMAKE_PARSE_ARGUMENTS (_add_sac_exec "EXCLUDE_FROM_ALL" "OUTPUT_NAME;OUTPUT_DIR;TARGET" "CSOURCE" ${ARGN})

    IF (NOT DEFINED _add_sac_exec_OUTPUT_DIR)
        SET (_add_sac_exec_OUTPUT_DIR "${CMAKE_CURRENT_BINARY_DIR}")
    ELSE ()
        GET_FILENAME_COMPONENT (_add_sac_exec_OUTPUT_DIR "${_add_sac_exec_OUTPUT_DIR}" ABSOLUTE)
    ENDIF ()

    IF (NOT DEFINED _add_sac_exec_OUTPUT_NAME)
        SET (_add_sac_exec_OUTPUT_NAME "${_TARGET_NAME}")
    ENDIF ()

    IF (DEFINED _add_sac_exec_CSOURCE)
        _ADD_C_SOURCE (${_add_sac_exec_TARGET} "${_add_sac_exec_CSOURCE}" _csource_dsts)
    ENDIF ()

    IF (NOT DEFINED _add_sac_exec_TARGET)
        SET (_add_sac_exec_TARGET "seq") # default is seq
    ENDIF ()

    SET (_SAC_SOURCE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/${_SOURCE_FILE}")
    SET (_SAC_OUTPUT_PATH "${_add_sac_exec_OUTPUT_DIR}/${_add_sac_exec_OUTPUT_NAME}")
    ADD_CUSTOM_COMMAND (OUTPUT "${_SAC_OUTPUT_PATH}"
        COMMAND ${SAC_COMPILER} -v0 -t ${_add_sac_exec_TARGET} -o "${_SAC_OUTPUT_PATH}" "${_SAC_SOURCE_PATH}"
        DEPENDS "${_SAC_SOURCE_PATH}" ${_csource_dsts}
        BYPRODUCTS "${_SAC_OUTPUT_PATH}.c"
                   "${_SAC_OUTPUT_PATH}.i"
        WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}"
        COMMENT "Building SAC executable ${_add_sac_exec_OUTPUT_NAME}")

    IF (NOT ${_add_sac_exec_EXCLUDE_FROM_ALL})
        ADD_CUSTOM_TARGET ("${_TARGET_NAME}-prog" ALL DEPENDS "${_SAC_OUTPUT_PATH}")
    ELSE ()
        ADD_CUSTOM_TARGET ("${_TARGET_NAME}-prog" DEPENDS "${_SAC_OUTPUT_PATH}")
    ENDIF ()
ENDFUNCTION ()

# This function is similar to the `add_library` builtin, which takes some SAC source
# file and zero or more C-source files, and builds the module and tree libraries.
#
# Automatic resolving of use/import module dependencies is not resolved here! No checks
# are done to make sure depedencies are built before this target, except where the use
# does this themselves using `add_dependencies`.
#
# Options:
#
#  TARGET      target     build using specified target (default is 'seq')
#  EXCLUDE_FROM_ALL       flag, mark that executable should not be built by default
#  CSOURCES    file [...] C-source files dependencies (compiled to *.o files for linking)
#
FUNCTION (ADD_SAC_LIBRARY _TARGET_NAME _SOURCE_FILE)
    CMAKE_PARSE_ARGUMENTS (_add_sac_lib "EXCLUDE_FROM_ALL" "TARGET" "CSOURCE" ${ARGN})

    IF (NOT DEFINED _add_sac_lib_TARGET)
        SET (_add_sac_lib_TARGET "seq") # default is seq
    ENDIF ()

    IF (DEFINED _add_sac_lib_CSOURCE)
        _ADD_C_SOURCE (${_add_sac_lib_TARGET} "${_add_sac_lib_CSOURCE}" _csource_dsts)
    ENDIF ()

    EXECUTE_PROCESS (COMMAND ${SAC_COMPILER} -t ${_add_sac_lib_TARGET} -CTARGET_ENV
        OUTPUT_VARIABLE _SAC_TARGET_ENV  OUTPUT_STRIP_TRAILING_WHITESPACE)

    EXECUTE_PROCESS (COMMAND ${SAC_COMPILER} -t ${_add_sac_lib_TARGET} -CSBI
        OUTPUT_VARIABLE _SAC_SBI  OUTPUT_STRIP_TRAILING_WHITESPACE)

    GET_FILENAME_COMPONENT (_SAC_OUTPUT_NAME ${_SOURCE_FILE} NAME_WE)
    SET (_SAC_LIB_PATH "${CMAKE_BINARY_DIR}/lib")
    FILE (MAKE_DIRECTORY "${_SAC_LIB_PATH}") # we need to make sure this exists
    SET (_SAC_OUTPUT_MOD_PATH "${_SAC_LIB_PATH}/${_SAC_TARGET_ENV}/${_SAC_SBI}/lib${_SAC_OUTPUT_NAME}Mod${SAC_MOD_EXT}")
    SET (_SAC_OUTPUT_TREE_PATH "${_SAC_LIB_PATH}/tree/${_SAC_TARGET_ENV}/lib${_SAC_OUTPUT_NAME}Tree${SAC_TREE_DLL_EXT}")
    SET (_SAC_SOURCE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/${_SOURCE_FILE}")

    ADD_CUSTOM_COMMAND (OUTPUT "${_SAC_OUTPUT_MOD_PATH}" "${_SAC_OUTPUT_TREE_PATH}"
        COMMAND ${SAC_COMPILER} -v0 -t ${_add_sac_lib_TARGET} -o "${_SAC_LIB_PATH}" "${_SAC_SOURCE_PATH}"
        DEPENDS "${_SAC_SOURCE_PATH}" ${_csource_dsts}
        WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}"
        COMMENT "Compiling module ${_SAC_OUTPUT_NAME}")

    IF (NOT ${_add_sac_lib_EXCLUDE_FROM_ALL})
        ADD_CUSTOM_TARGET ("${_TARGET_NAME}-lib" ALL DEPENDS "${_SAC_OUTPUT_MOD_PATH}" "${_SAC_OUTPUT_TREE_PATH}")
    ELSE ()
        ADD_CUSTOM_TARGET ("${_TARGET_NAME}-lib" DEPENDS "${_SAC_OUTPUT_MOD_PATH}" "${_SAC_OUTPUT_TREE_PATH}")
    ENDIF ()
ENDFUNCTION ()
