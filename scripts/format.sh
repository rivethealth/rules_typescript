#!/bin/sh -ex
cd "$(dirname "$0")/.."

if [ "$1" = check ]; then
    TARGET=buildifier_check
else
    TARGET=buildifier
fi

bazel run $TARGET

bazel query 'kind("js_library", //...) + kind("ts_library", //...) - //rules/typescript:js' \
    | xargs -r bazel build --aspects //tools/bzl:aspects.bzl%format --output_groups=formatted

if [ "$1" = check ]; then
    ARG=
else
    ARG=write
fi

BAZEL_BIN="$(bazel info bazel-bin)"
bazel query 'kind("js_library", //...) + kind("ts_library", //...)' --output package | while IFS= read -r package; do
    "$BAZEL_BIN/$package/_format/bin" "$ARG"
done

#bazel run //tools:prettier_bin -- -c $(pwd)/prettierrc.yml --write $(pwd)/README.md $(pwd)/rules/javascript/resolver.js $(pwd)/rules/nodejs/shim.js
