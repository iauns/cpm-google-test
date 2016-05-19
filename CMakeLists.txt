cmake_minimum_required(VERSION 2.8 FATAL_ERROR)

#-----------------------------------------------------------------------
# CPM configuration
#-----------------------------------------------------------------------
set(CPM_MODULE_NAME google_test)
set(CPM_LIB_TARGET_NAME ${CPM_MODULE_NAME})

if ((DEFINED CPM_DIR) AND (DEFINED CPM_UNIQUE_ID) AND (DEFINED CPM_TARGET_NAME))
  set(CPM_LIB_TARGET_NAME ${CPM_TARGET_NAME})
  set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${CPM_DIR})
  include(CPM)
else()
  set(CPM_DIR "${CMAKE_CURRENT_BINARY_DIR}/cpm-packages" CACHE TYPE STRING)
  find_package(Git)
  if(NOT GIT_FOUND)
    message(FATAL_ERROR "CPM requires Git.")
  endif()
  if (NOT EXISTS ${CPM_DIR}/CPM.cmake)
    execute_process(
      COMMAND "${GIT_EXECUTABLE}" clone https://github.com/iauns/cpm ${CPM_DIR}
      RESULT_VARIABLE error_code
      OUTPUT_VARIABLE head_sha)
    if(error_code)
      message(FATAL_ERROR "CPM failed to get the hash for HEAD")
    endif()
  endif()
  include(${CPM_DIR}/CPM.cmake)
endif()

# All externals *must* define this.
CPM_ForceOnlyOneModuleVersion()

CPM_InitModule(${CPM_MODULE_NAME})

#------------------------------------------------------------------------------
# Google Test
#------------------------------------------------------------------------------
# Google test as an external project is a bad idea! You really should add it
# as a subdirectory so that it can capture your compiler flags
set(GOOGLE_TEST_DIR ${CMAKE_CURRENT_SOURCE_DIR}/3rdParty/gtest)
CPM_EnsureRepoIsCurrent(
  TARGET_DIR ${GOOGLE_TEST_DIR}
  GIT_REPOSITORY "https://github.com/google/googletest.git"
  USE_CACHING TRUE
  )

# Compiler flags for MSVC 2010
if (MSVC_VERSION EQUAL 1600)
  add_definitions(-DGTEST_USE_OWN_TR1_TUPLE=0)
  CPM_ExportAdditionalDefinition("-DGTEST_USE_OWN_TR1_TUPLE=0")
endif()

# Compiler flags for MSVC 2012
if(MSVC_VERSION EQUAL 1700)
  add_definitions(-D_VARIADIC_MAX=10)
endif()

# For All versions of gtest, we force shared CRT.
set(gtest_force_shared_crt ON)
set(gtest_force_shared_crt ON)

# Add gtest now that we have the appropriate flags set.
add_subdirectory(${GOOGLE_TEST_DIR})

CPM_ExportAdditionalIncludeDir("${GOOGLE_TEST_DIR}/include")
CPM_ExportAdditionalLibraryTarget("gtest")


# To see how one would implement google test as an external project,
# see the following stack overflow question:
# http://stackoverflow.com/questions/9689183/cmake-googletest
#
# It turns out this is a bad idea because the external project does not share
# your compiler flags.
#
# See: 592ba73ab495c8b2661315b6f97e0ac7919f4d4d for an implementation of this
#      module using an external project.
