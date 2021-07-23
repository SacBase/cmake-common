CMake Common for SaC-based Projects
===================================

About
-----

This repository contains a collection of CMake files that are useful
for building SaC-based projects, such as modules and SaC programs.

A typical initial stage of making use of these CMake files is to
add the repository as a git submodule, this way you can maintain a specific
version of the files in your SaC project.

Detailed Description
--------------------

### Use SAC in your CMake-based project

To make it as easy as possible to use SAC within a CMake-based project,
we provide a _package_ which searches for the SAC compiler and other tools
and sets certain needed variables for building. Additionally, we provide
the `UseSAC` module which provides some conveniences functions for building
SAC programs and modules.

To make use of this, you can use the following example `CMakeLists.txt` file
as a base to start with:

```cmake
CMAKE_MINIMUM_REQUIRED (VERSION 3.19)

# Project language can be anything really, we use C here as an example
PROJECT (<project-name> C)

# we need to append this repo to CMake module path
LIST (APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake-common")

# Now we can "find" sac2c and other tools; this provides paths to
# the compiler with some variables set which might be needed to
# compile some SAC code, e.g. provides the ${SAC_COMPILER} variable
# for sac2c, and ${SAC_C_COMPILER} for saccc.
FIND_PACKAGE (SAC REQUIRED)

# Functions provided here make it easy to compile SAC programs
# and modules!
INCLUDE ("${CMAKE_SOURCE_DIR}/cmake-common/UseSAC.cmake")

# When building modules, it is advisable to correct create a sac2crc
# file so that the SAC compiler can find the modules
INCLUDE ("${CMAKE_SOURCE_DIR}/cmake-common/misc-macros.cmake")
CREATE_SAC2CRC_TARGET ("<project-name>" "${CMAKE_BINARY_DIR}/lib" "${CMAKE_BINARY_DIR}/lib" "")

# Other CMake stuff...

# Now we can call function to build SAC program
ADD_SAC_EXECUTABLE (proga proga.sac)
```

Briefly, from `UseSAC` you can use the following functions:

* `ADD_SAC_EXECUTABLE (name source [TARGET seq] [CSOURCE c-file;...] [EXCLUDE_FROM_ALL])`
  Causes the SAC sources (together with any C-sources) to be compiled into a program called
  `name`.

* `ADD_SAC_LIBRARY (name source [TARGET seq] [CSOURCE c-file;...] [EXCLUDE_FROM_ALL])`
  Causes a SAC module to be built from file `source`

As with the CMake `ADD_EXECUTABLE` and `ADD_LIBRARY`, you can create cross dependencies
using `ADD_DEPENDENCIES`.

For further details, read the documentation in `UseSAC.cmake` and `FindSAC.cmake`.

### Additional CMake files; functions and macros

These files provide macros and functions which can be directly called within
your SaC project. A description of the features provided by each file is given
below:

  * `check-sac2c.cmake` checks whether we have an operational sac2c
     compiler.  The `SAC2C_EXEC` variable overrides search for
     `sac2c` on the PATH. This produces the `SAC2C_VERSION` variable.

  * `sac2c-variables.cmake` defines a number of useful sac2c variables
     that are mainly coming from parsing sac2crc for a given TARGET.
     Also it performs some sanity checks like: chosen target is set
     in sac2crc, sac2c executable is set, etc. Feature flag support is
     also checked here using the `CHECK_SAC2C_SUPPORT_FLAG` macro from
     `misc-macros.cmake`, as this is used locally the `CMAKE_COMMON_DIR`
     variable is configurable to set the path to the `misc-macros.cmake`
     file from the root of the project directory, this defaults to the
     path `cmake-common`.

  * `generate-version-vars.cmake` defined a function where generates the
     MAJOR, MINOR, and PATCH numbers using the `git-describe` tool.

  * `resolve-sac2c-dependencies.cmake` defines a function that for
     a given file runs `sac2c -M`, checks whether external dependencies
     to the Tree and Mod shared libraries can be found; and generates
     a list of local dependencies that can be used while defining
     a custom target in CMake.

  * `generate-sac2c-dependency-targets.cmake` provides a very similar
     function as is in `resolve-sac2c-dependencies.cmake`, with the main
     distinction being that instead of outputting module library file
     paths, it returns target names.

  * `generate-sac2crc-file.cmake` is a script which is used to generate a
    sac2crc file for a *package*, called `sac2crc.package.<package>`. It places
    it into the user's home directory under `.sac2crc` directory. It is intended
    that the script is used as a target within the package build.

  * `check-sac2c-feature-support.cmake` contains a collection of macros/functions
    which check for supported features in `sac2c`. The results are intended to
    be exposed via the generated `config.h` file, but may also affect whether or
    not certain build options can be used.

  * `build-sac2c-module.cmake` provides macros to create targets to build SaC
    modules (with dependency resolution provided by `resolve-sac2c-dependencies.cmake`)

  * `build-sac2c-progam.cmake` provides macros to create targets to build SaC
    programs (with dependency resolution provided by `resolve-sac2c-dependencies.cmake`)

  * `sac2c-prog-with-versions.cmake` provides macros to create targets to build SaC
    programs that make use of an external *version* config. Precise details of what this is
    is explained within the cmake file.

  * `misc-macros.cmake` contains a miscellaneous collection of functions and
    macros. Further details on what these functions do is given as comments
    within.

Setup
-----

To add this repository as a submodule, do the following in your SaC project repository:
```sh
$ git submodule add https://github.com/SacBase/cmake-common.git
$ git submodule update --init
```

If you later wish to pull a more recent version the `cmake-common` repo, you can do the
following:
```sh
$ git submodule update --recursive --remote
```

Usage
-----

To use the functions and macros, you need to `INCLUDE` these into your CMake project.

License
-------

See `LICENSE.txt` for details.
