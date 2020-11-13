#!/usr/bin/env sh
set -e
cd "$(dirname "$0")/.."

bazel build rules/typescript:ts
rm -fr rules/typescript/compiler-js
cp -r "$(bazel info bazel-bin)/rules/typescript/ts" rules/typescript/compiler-js

