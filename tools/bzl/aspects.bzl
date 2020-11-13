load("@better_rules_javascript//rules/protobuf/bzl:aspects.bzl", "js_proto_aspect")
load("@better_rules_javascript//rules/prettier/bzl:aspects.bzl", "format_aspect")

format = format_aspect(
    "@better_rules_typescript//tools:prettier",
)
