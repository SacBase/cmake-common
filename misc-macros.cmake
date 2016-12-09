# This file contains miscellaneous macros and functions for all things
# CMake.

# This function provides a mechanism to remove modules
# related files from a list of source files - the intention
# being to prevent the module from being compiled.
# NOTE: this does not resolve dependencies!
#
# Parameters:
#  - source_list (required) => variable (not ${<XXX>}, but <XXX>)
#                              that contains the list of sources
#  - modules_list (required) => a list of modules you wish exclude
FUNCTION (REMOVE_MODULE_IN_SRC source_list modules_list)
    FOREACH (module ${modules_list})
        FOREACH (dep ${${source_list}})
            IF ("${dep}" MATCHES "^.*${module}[\\./].*$")
                LIST (REMOVE_ITEM ${source_list} "${dep}")
            ENDIF ()
        ENDFOREACH ()
    ENDFOREACH ()
    SET (${source_list} ${${source_list}} PARENT_SCOPE)
ENDFUNCTION ()
