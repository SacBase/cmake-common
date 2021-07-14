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

### CMake files; functions and macros

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

### CMake Project Language

We also provide a CMake language specification for making CMake use the SaC compiler
directly (_Note_ this is not fully tested yet!).

To use the language specification, setup your `CMakeLists.txt` file as follows:
```cmake
project(SomeSACProject NONE)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake-common")
enable_language(SAC)
```
Note that we set the project language to `NONE`, and then use `enable_language` to
activate the SaC language specification.

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
