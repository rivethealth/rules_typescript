load("@better_rules_javascript//rules/nodejs/bzl:workspace.bzl", nodejs_repositories = "repositories")
load("@better_rules_javascript//rules/npm/bzl:workspace.bzl", "npm", npm_repositories = "repositories")
load("//:npm_data.bzl", "PACKAGES", "ROOTS")

def repositories():
    nodejs_repositories()
    npm_repositories()

    npm("better_rules_typescript_npm", PACKAGES, ROOTS)
