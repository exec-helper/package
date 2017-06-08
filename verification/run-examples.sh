#!/bin/bash

function DIE
{
    echo "$@"
    echo "*** ABORTED ***"
    exit 42
}

CONFIG_EXAMPLES=(
    'exec-helper-config.example'
)

PLUGIN_EXAMPLES=(
    'bootstrap.example'
    'clang-static-analyzer.example'
    'clang-tidy.example'
    'command-line-command.example'
    'cppcheck.example'
    'lcov.example'
    'make.example'
    'pmd.example'
    'scons.example'
    'selector.example'
    'valgrind.example'
)

pushd exec-helper/src/config/examples
for example in "${CONFIG_EXAMPLES[@]}"; do
    exec-helper --settings-file ${example} build clean rebuild || DIE "Failed executing ${example} example"
done
popd

pushd exec-helper/src/plugins/examples
for example in "${PLUGIN_EXAMPLES[@]}"; do
    exec-helper --settings-file ${example} example || DIE "Failed executing ${example} example"
done
popd
