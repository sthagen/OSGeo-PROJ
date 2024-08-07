################################################################################
# ProjVersion.cmake - part of CMake configuration of PROJ library
################################################################################
# Copyright (C) 2010 Mateusz Loskot <mateusz@loskot.net>
#
# Distributed under the Boost Software License, Version 1.0
################################################################################
# Macros in this module:
#
#   proj_version - defines version information for PROJ library
################################################################################

# Defines version information for PROJ library
#
# proj_version(MAJOR major_version MINOR minor_version PATCH patch_level)
#
#    MAJOR.MINOR version is used to set SOVERSION
#

include(CMakeParseArguments)

macro(proj_version)
  cmake_parse_arguments(THIS_VERSION
    ""
    "MAJOR;MINOR;PATCH"
    ""
    ${ARGN})

  # Set version components
  set(${PROJECT_NAME}_VERSION_MAJOR ${THIS_VERSION_MAJOR})
  set(${PROJECT_NAME}_VERSION_MINOR ${THIS_VERSION_MINOR})
  set(${PROJECT_NAME}_VERSION_PATCH ${THIS_VERSION_PATCH})

  # Set VERSION string
  set(${PROJECT_NAME}_VERSION
    "${${PROJECT_NAME}_VERSION_MAJOR}.\
${${PROJECT_NAME}_VERSION_MINOR}.\
${${PROJECT_NAME}_VERSION_PATCH}")

  print_variable(${PROJECT_NAME}_VERSION)
endmacro()
