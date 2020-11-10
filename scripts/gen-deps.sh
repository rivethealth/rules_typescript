#!/bin/sh -e

cd "$(dirname "$0")/../tests"
yarn install
bazel run @better_rules_javascript//rules/npm/gen:bin -- \
    yarn \
    --package "$(pwd)/package.json" \
    --lock "$(pwd)/yarn.lock" \
    "$(pwd)/npm_data.bzl"
