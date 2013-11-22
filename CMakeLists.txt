cmake_minimum_required(VERSION 2.8.7 FATAL_ERROR)

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
# Much of this is pulled from the following stack overflow question:
# http://stackoverflow.com/questions/9689183/cmake-googletest

# We manually download GLM into our source directory so the user can access
# glm through 'glm/...'. There is no build step since this is a header only
# library.
set(REPO_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/3rdParty/glm")
CPM_EnsureRepoIsCurrent(
  TARGET_DIR ${REPO_SOURCE_DIR}
  GIT_REPOSITORY "https://github.com/g-truc/glm.git"
  GIT_TAG "0.9.4.6"
  )
CPM_ExportAdditionalIncludeDir("${REPO_SOURCE_DIR}")

#file( GLOB_RECURSE GLM_HEADERS
#  ${REPO_SOURCE_DIR}/*.hpp
#)
#add_custom_target( ${CPM_TARGET_NAME} SOURCES ${GLM_HEADERS} )

file(WRITE gtest.patch "")

# Enable ExternalProject CMake module
include(ExternalProject)

# Set the build type if it isn't already
if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE Release)
endif()

# Set default ExternalProject root directory
set_directory_properties(PROPERTIES EP_PREFIX ${CMAKE_CURRENT_SOURCE_DIR}/3rdParty)

# Add gtest
ExternalProject_Add(
    googletest
    SVN_REPOSITORY http://googletest.googlecode.com/svn/trunk/
    SVN_REVISION -r 662
    TIMEOUT 10
    PATCH_COMMAND svn patch ${CMAKE_SOURCE_DIR}/gtest.patch ${CMAKE_CURRENT_SOURCE_DIR}/3rdParty/src/googletest
    # Force separate output paths for debug and release builds to allow easy
    # identification of correct lib in subsequent TARGET_LINK_LIBRARIES commands
    CMAKE_ARGS -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
    #           -DCMAKE_ARCHIVE_OUTPUT_DIRECTORY_DEBUG:PATH=DebugLibs
    #           -DCMAKE_ARCHIVE_OUTPUT_DIRECTORY_RELEASE:PATH=ReleaseLibs
    #           -Dgtest_force_shared_crt=ON
    # Disable install step
    INSTALL_COMMAND ""
    # Wrap download, configure and build steps in a script to log output
    LOG_DOWNLOAD ON
    LOG_CONFIGURE ON
    LOG_BUILD ON)

# Specify include dir
ExternalProject_Get_Property(googletest source_dir)
include_directories(${source_dir}/include)
CPM_ExportAdditionalIncludeDir("${source_dir}/include")

# Add compiler flag for MSVC 2012
if(MSVC_VERSION EQUAL 1700)
  CPM_ExportAdditionalDefinition("-D_VARIADIC_MAX=10")
endif()

set(GOOGLE_TEST_LIBRARY ${CPM_LIB_TARGET_NAME})
add_library(${GOOGLE_TEST_LIBRARY} SHARED IMPORTED GLOBAL)
add_dependencies(${GOOGLE_TEST_LIBRARY} ${MONGO_EP_TARGET_NAME})

# Grab the source directory, that is where all of the library files
# will reside. We will staically link against them.
ExternalProject_Get_Property(${MONGO_EP_TARGET_NAME} SOURCE_DIR)
ExternalProject_Get_Property(googletest binary_dir)
if(MSVC)
  set(Suffix ".lib")
else()
  set(Suffix ".a")
  set(Pthread "-pthread")
endif()

#debug ${binary_dir}/DebugLibs/${CMAKE_FIND_LIBRARY_PREFIXES}gtest${Suffix}
#optimized ${binary_dir}/ReleaseLibs/${CMAKE_FIND_LIBRARY_PREFIXES}gtest${Suffix}

# Generate a library path and set the imported location.
# TODO: Set imported location for debug / release libraries.
set_target_properties(${GOOGLE_TEST_LIBRARY}
  PROPERTIES
  IMPORTED_LOCATION ${binary_dir}/DebugLibs/${CMAKE_FIND_LIBRARY_PREFIXES}gtest${Suffix}
  )

