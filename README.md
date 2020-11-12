# rules_typescript

Bazel rules for TypeScript, with an emphasis on idiomatic Bazel APIs.

## Features

- [ ] library
    - [x] basic
    - [ ] declarations
    - [ ] worker
- [ ] external dependency
    - [ ] @types
- [ ] serialization
    - [ ] protobuf
- [ ] targets
    - [x] JS
    - [ ] WebAssembly (AssemblyScript)
- [ ] IDE
    - [ ] tsconfig
- [ ] dev
  - [ ] Stardoc
  - [ ] CI

## Install

**WORKSPACE.bazel**

```bzl
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

# skylib

SKYLIB_VERSION = "16de038c484145363340eeaf0e97a0c9889a931b"
http_archive(
    name = "bazel_skylib",
    sha256 = "96e0cd3f731f0caef9e9919aa119ecc6dace36b149c2f47e40aa50587790402b",
    strip_prefix = "bazel-skylib-%s" % SKYLIB_VERSION,
    urls = ["https://github.com/bazelbuild/bazel-skylib/archive/%s.tar.gz" % SKYLIB_VERSION],
)

# better_rules_javascript

JAVACRIPT_VERSION = "..."
http_archive(
    name = "better_rules_javascript",
    strip_prefix = "rules_javascript-%s" % JAVASCRIPT_VERSION,
    urls = ["https://github.com/rivethealth/rules_javascript/archive/%s.tar.gz" % JAVACRIPT_VERSION],
)

load("@better_rules_javascript//rules/bzl:workspace.bzl", javascript_repositories = "respositories")
javascript_respositories()

# better_rules_typescript

TYPESCRIPT_VERSION = "..."
http_archive(
    name = "better_rules_typescript",
    strip_prefix = "rules_typescript-%s" % TYPESCRIPT_VERSION,
    urls = ["https://github.com/rivethealth/rules_typescript/archive/%s.tar.gz" % TYPESCRIPT_VERSION],
)

load("@better_rules_javascript//rules/bzl:workspace.bzl", typescript_repositories = "respositories")
typescript_respositories()
```

## Usage

### Basic

**a.ts**

```ts
export const example = "apple";
```

**b.ts**

```ts
import { a } from "./a"; 
console.log(a.example);
```

**BUILD.bazel**

```bzl
load("@better_rules_typescript//rules/typescript/bzl:rules.bzl", "ts_library")
load("@better_rules_javascript//rules/nodejs/bzl:rules.bzl", "nodejs_binary")

ts_library(
    name = "a",
    srcs = ["a.ts"],
    compiler = "//:ts",
)

ts_library(
    name = "b",
    srcs = ["b.ts"],
    compiler = "//:ts",
    deps = [":a"],
)

nodejs_binary(
    name = "bin",
    dep = ":b",
    main = "b.js",
)
```

```sh
bazel run :bin
```
