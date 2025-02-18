#=============================================================================
# Copyright (c) 2022, NVIDIA CORPORATION.
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

function(find_and_configure_cumlprims_mg)

    include(${CMAKE_CURRENT_FUNCTION_LIST_DIR}/get_cpm.cmake)
    include(${CMAKE_CURRENT_FUNCTION_LIST_DIR}/get_version.cmake)
    include(${CMAKE_CURRENT_FUNCTION_LIST_DIR}/ConfigureRAFT.cmake)

    _get_rapidsai_module_version(cumlprims_mg VERSION)

    _clean_build_dirs_if_not_fully_built(cumlprims_mg libcumlprims_mg)

    _set_package_dir_if_exists(cumlprims_mg cumlprims_mg)

    find_package(OpenMP REQUIRED)

    if(NOT TARGET cumlprims_mg::cumlprims_mg)
        _get_major_minor_version(${VERSION} MAJOR_AND_MINOR)
        _get_update_disconnected_state(cumlprims_mg ${VERSION} UPDATE_DISCONNECTED)
        CPMFindPackage(NAME        cumlprims_mg
            VERSION                ${VERSION}
            # EXCLUDE_FROM_ALL       TRUE
            GIT_REPOSITORY         "git@github.com:rapidsai/cumlprims_mg.git"
            GIT_TAG                branch-${MAJOR_AND_MINOR}
            GIT_SHALLOW            TRUE
            ${UPDATE_DISCONNECTED}
            SOURCE_SUBDIR          cpp
            OPTIONS                "BUILD_TESTS OFF"
                                   "BUILD_BENCHMARKS OFF"
                                   "DETECT_CONDA_ENV OFF"
                                   "BUILD_SHARED_LIBS OFF")
    endif()
    # Make sure consumers of our libs can see cumlprims_mg::cumlprims_mg
    _fix_cmake_global_defaults(cumlprims_mg::cumlprims_mg)

    include(${CMAKE_CURRENT_FUNCTION_LIST_DIR}/link_utils.cmake)
    _statically_link_cuda_toolkit_libs(cumlprims_mg::cumlprims_mg)

    set(cumlprims_mg_VERSION "${cumlprims_mg_VERSION}" PARENT_SCOPE)
endfunction()

find_and_configure_cumlprims_mg()
