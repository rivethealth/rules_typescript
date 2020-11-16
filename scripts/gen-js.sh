#!/usr/bin/env sh
set -e
cd "$(dirname "$0")/.."

bazel build --output_groups=js rules/typescript:ts
rm -fr rules/typescript/compiler-js
cp -r "$(bazel info bazel-bin)/rules/typescript/ts" rules/typescript/compiler-js
find rules/typescript/compiler-js -type f -name '*.d.ts' -delete
