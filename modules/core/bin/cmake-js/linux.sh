#!/usr/bin/env bash

set -Eeo pipefail

RAPIDS_CORE_HOME=$(dirname $(realpath "$0"))
RAPIDS_CORE_HOME=$(realpath "$RAPIDS_CORE_HOME/../../")

JOBS=$(node -e "console.log(require('os').cpus().length)") \
    PARALLEL_LEVEL=$JOBS CMAKE_BUILD_PARALLEL_LEVEL=$JOBS  \
    HOME="$RAPIDS_CORE_HOME"                               \
    npx cmake-js $@                                        \
 && ln -f -s build/compile_commands.json compile_commands.json
