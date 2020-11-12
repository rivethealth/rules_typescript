load("@better_rules_javascript//rules/util/bzl:path.bzl", "runfile_path")
load("@better_rules_javascript//rules/javascript/bzl:providers.bzl", "merge_js", "add_globals", "JsInfo", "create_module", "create_package", "create_package_dep")
load("@better_rules_javascript//rules/nodejs/bzl:rules.bzl", "write_packages_manifest")
load(":providers.bzl", "TsCompilerInfo", "TsInfo")

def _ts_compiler_impl(ctx):
    typescript = ctx.attr.typescript[JsInfo]
    dep = ctx.attr._dep[JsInfo]
    dep = merge_js(dep, [typescript])
    dep = add_globals(dep, [typescript.id])

    packages_manifest = ctx.actions.declare_file("%s/packages-manifest.txt" % ctx.label.name)
    write_packages_manifest(ctx, packages_manifest, dep)

    return TsCompilerInfo(
        dep = dep,
        manifest = packages_manifest,
        runtime = ctx.attr.runtime[JsInfo],
    )

ts_compiler = rule(
    implementation = _ts_compiler_impl,
    attrs = {
        "_dep": attr.label(
            default = "//rules/typescript:js",
            providers = [JsInfo],
        ),
        "typescript": attr.label(
            mandatory = True,
            providers = [JsInfo],
        ),
        "runtime": attr.label(
            mandatory = True,
            providers = [JsInfo],
        ),
    }
)

def _ts_library_impl(ctx):
    package_name = ctx.attr.package_name
    if not package_name:
        package_name = "@%s/%s" % (ctx.label.workspace_name or ctx.workspace_name, ctx.label.package) if ctx.label.package else ctx.label.workspace_name
    strip_prefix = ctx.attr.strip_prefix
    if not strip_prefix:
        strip_prefix = "%s/%s" % (ctx.label.workspace_name or ctx.workspace_name, ctx.label.package) if ctx.label.package else ctx.label.workspace_name

    compiler = ctx.attr.compiler[TsCompilerInfo]

    inputs = []
    outputs = []
    modules = []
    args = ctx.actions.args()

    args.add(compiler.manifest.path)
    args.add(compiler.dep.id)
    inputs.append(compiler.manifest)

    args.add(compiler.dep.name)

    for src in ctx.files.srcs:
        inputs.append(src)
        path = runfile_path(ctx, src)
        if strip_prefix:
            if not path.startswith(strip_prefix + "/"):
                fail("Source %s does not have prefix %s" % (path, strip_prefix))
            path = path[len(strip_prefix + "/"):]
        if ctx.attr.prefix:
            path = ctx.attr.prefix + "/" + path
        js_path = path.replace('.ts', '.js')
        output = ctx.actions.declare_file('%s/%s' % (ctx.label.name, js_path))
        outputs.append(output)
        args.add(src.path)
        args.add(output.path)
        modules.append(create_module(js_path, output))

    ctx.actions.run(
        executable = ctx.attr._runner.files_to_run,
        arguments = [args],
        inputs = depset(inputs, transitive = [compiler.dep.transitive_files]),
        outputs = outputs,
    )

    deps = [create_package_dep(dep[JsInfo].name, dep[JsInfo].id) for dep in ctx.attr.deps if JsInfo in dep]

    js_package = create_package(
        id = ctx.label,
        name = package_name,
        main = None,
        modules = tuple(modules),
        deps = tuple(deps),
    )

    js_info = JsInfo(
        id = ctx.label,
        name = package_name,
        globals = depset(),
        transitive_files = depset(outputs),
        transitive_packages = depset([js_package]),
        transitive_source_maps = depset()
    )
    js_info = merge_js(js_info, [compiler.runtime] + [dep[JsInfo] for dep in ctx.attr.deps if JsInfo in dep])

    default_info = DefaultInfo(
        files = depset(outputs)
    )

    return [default_info, js_info]

ts_library = rule(
    implementation = _ts_library_impl,
    attrs = {
        "srcs": attr.label_list(
            allow_files = [".ts"],
            mandatory = True,
        ),
        "deps": attr.label_list(
            doc = "Dependencies",
            providers = [[JsInfo], [TsInfo]],
        ),
        "package_name": attr.string(
            doc = "Package name",
        ),
        "strip_prefix": attr.string(
            doc = "Strip prefix"
        ),
        "prefix": attr.string(
            doc = "Prefix",
        ),
        "compiler": attr.label(
            mandatory = True,
            providers = [TsCompilerInfo],
        ),
        "_runner": attr.label(
            doc = "Node.js runner",
            executable = True,
            cfg = "host",
            default = "@better_rules_javascript//rules/nodejs:bin",
        ),
    },
)
