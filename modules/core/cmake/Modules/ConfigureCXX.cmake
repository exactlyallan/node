#=============================================================================
# Copyright (c) 2020-2022, NVIDIA CORPORATION.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#=============================================================================
include_guard(GLOBAL)

###################################################################################################
# - CMake properties ------------------------------------------------------------------------------

if(UNIX AND NOT APPLE)
    set(LINUX TRUE)
endif()

if(NODE_RAPIDS_USE_SCCACHE)
    find_program(SCCACHE_PROGRAM_PATH sccache)
    if(SCCACHE_PROGRAM_PATH)
        message(STATUS "Using sccache: ${SCCACHE_PROGRAM_PATH}")
        set_property(GLOBAL PROPERTY RULE_LAUNCH_COMPILE "${SCCACHE_PROGRAM_PATH}")
        if(DEFINED ENV{SCCACHE_DIR})
            message(STATUS "Using sccache directory: $ENV{SCCACHE_DIR}")
            set_property(GLOBAL PROPERTY RULE_LAUNCH_COMPILE "SCCACHE_DIR=${SCCACHE_DIR} ${SCCACHE_PROGRAM_PATH}")
        endif(DEFINED ENV{SCCACHE_DIR})
    endif(SCCACHE_PROGRAM_PATH)
endif(NODE_RAPIDS_USE_SCCACHE)

execute_process(COMMAND node -p
                "require('@rapidsai/core').cpp_core_include_path"
                WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
                OUTPUT_VARIABLE RAPIDS_CORE_INCLUDE_DIR
                OUTPUT_STRIP_TRAILING_WHITESPACE)

message(STATUS "RAPIDS core include: ${RAPIDS_CORE_INCLUDE_DIR}")

###################################################################################################
# - compiler options ------------------------------------------------------------------------------

list(APPEND NODE_RAPIDS_CMAKE_C_FLAGS ${CMAKE_C_FLAGS})
list(APPEND NODE_RAPIDS_CMAKE_CXX_FLAGS ${CMAKE_CXX_FLAGS})
list(APPEND NODE_RAPIDS_CMAKE_CUDA_FLAGS ${CMAKE_CUDA_FLAGS})

unset(CMAKE_C_FLAGS)
unset(CMAKE_C_FLAGS CACHE)
unset(CMAKE_CXX_FLAGS)
unset(CMAKE_CXX_FLAGS CACHE)
unset(CMAKE_CUDA_FLAGS)
unset(CMAKE_CUDA_FLAGS CACHE)

if(CMAKE_COMPILER_IS_GNUCXX)
    option(NODE_RAPIDS_CMAKE_CXX11_ABI "Enable the GLIBCXX11 ABI" ON)
    list(APPEND NODE_RAPIDS_CMAKE_CXX_FLAGS -Wall -Werror -Wno-unknown-pragmas -Wno-error=deprecated-declarations)
    if(NODE_RAPIDS_CMAKE_CXX11_ABI)
        message(STATUS "Enabling the GLIBCXX11 ABI")
    else()
        message(STATUS "Disabling the GLIBCXX11 ABI")
        list(APPEND NODE_RAPIDS_CMAKE_C_FLAGS -D_GLIBCXX_USE_CXX11_ABI=0)
        list(APPEND NODE_RAPIDS_CMAKE_CXX_FLAGS -D_GLIBCXX_USE_CXX11_ABI=0)
        list(APPEND NODE_RAPIDS_CMAKE_CUDA_FLAGS -Xcompiler=-D_GLIBCXX_USE_CXX11_ABI=0)
    endif(NODE_RAPIDS_CMAKE_CXX11_ABI)
    # always colors
    list(APPEND CMAKE_C_FLAGS -fdiagnostics-color=always)
    list(APPEND CMAKE_CXX_FLAGS -fdiagnostics-color=always)
    list(APPEND CMAKE_CUDA_FLAGS -Xcompiler=-fdiagnostics-color=always)
endif(CMAKE_COMPILER_IS_GNUCXX)

if(WIN32)
    list(APPEND NODE_RAPIDS_CMAKE_C_FLAGS -D_WIN32)
    list(APPEND NODE_RAPIDS_CMAKE_CXX_FLAGS -D_WIN32)
    list(APPEND NODE_RAPIDS_CMAKE_CUDA_FLAGS -D_WIN32)
elseif(LINUX)
    list(APPEND NODE_RAPIDS_CMAKE_C_FLAGS -D__linux__)
    list(APPEND NODE_RAPIDS_CMAKE_CXX_FLAGS -D__linux__)
    list(APPEND NODE_RAPIDS_CMAKE_CUDA_FLAGS -D__linux__)
elseif(APPLE)
    list(APPEND NODE_RAPIDS_CMAKE_C_FLAGS -D__APPLE__)
    list(APPEND NODE_RAPIDS_CMAKE_CXX_FLAGS -D__APPLE__)
    list(APPEND NODE_RAPIDS_CMAKE_CUDA_FLAGS -D__APPLE__)
endif()

if(DISABLE_DEPRECATION_WARNINGS)
    list(APPEND NODE_RAPIDS_CMAKE_C_FLAGS -Wno-deprecated-declarations)
    list(APPEND NODE_RAPIDS_CMAKE_CXX_FLAGS -Wno-deprecated-declarations)
    list(APPEND NODE_RAPIDS_CMAKE_CUDA_FLAGS -Xcompiler=-Wno-deprecated-declarations)
endif(DISABLE_DEPRECATION_WARNINGS)

# Enable -fPIC for all libs
set(CMAKE_POSITION_INDEPENDENT_CODE ON)
