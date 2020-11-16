load("@better_rules_javascript//rules/util/bzl:path.bzl", "runfile_path")
load("@better_rules_javascript//rules/javascript/bzl:providers.bzl", "JsInfo", "create_js", "create_module", "create_package", "create_package_dep", "merge_js")
load("@better_rules_javascript//rules/nodejs/bzl:rules.bzl", "write_packages_manifest")
load(":providers.bzl", "TsCompilerInfo", "TsInfo")

def _ts_compiler_impl(ctx):
    typescript = ctx.attr.typescript[JsInfo]
    dep = ctx.attr._dep[JsInfo]

    package_deps = [create_package_dep(dep.name, id) for id in dep.ids]
    package = create_package("", "", deps = tuple(package_deps))
    js_info = create_js(package, global_package_ids = typescript.ids, deps = [dep, typescript])

    packages_manifest = ctx.actions.declare_file("%s/packages-manifest.txt" % ctx.label.name)
    write_packages_manifest(ctx, packages_manifest, js_info)

    return TsCompilerInfo(
        dep = js_info,
        manifest = packages_manifest,
        runtime = ctx.attr.runtime[JsInfo],
        target = ctx.attr.target,
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
        "target": attr.string(
            default = "es2017",
        ),
        "runtime": attr.label(
            mandatory = True,
            providers = [JsInfo],
        ),
    },
)

def _ts_library_impl(ctx):
    package_name = ctx.attr.package_name
    if not package_name:
        package_name = "@%s/%s" % (ctx.label.workspace_name or ctx.workspace_name, ctx.label.package) if ctx.label.package else ctx.label.workspace_name
    strip_prefix = ctx.attr.strip_prefix
    if not strip_prefix:
        strip_prefix = "%s/%s" % (ctx.label.workspace_name or ctx.workspace_name, ctx.label.package) if ctx.label.package else ctx.label.workspace_name

    compiler = ctx.attr.compiler[TsCompilerInfo]

    outputs = []
    map_outputs = []
    modules = []
    ts_modules = []
    ts_outputs = []

    ts_args = ctx.actions.args()
    ts_args.add(compiler.manifest.path)
    ts_args.add("@better_rules_typescript/rules/typescript")
    ts_args.add("dts")

    for src in ctx.files.srcs:
        path = runfile_path(ctx, src)
        if strip_prefix:
            if not path.startswith(strip_prefix + "/"):
                fail("Source %s does not have prefix %s" % (path, strip_prefix))
            path = path[len(strip_prefix + "/"):]
        if ctx.attr.prefix:
            path = ctx.attr.prefix + "/" + path

        # JS

        args = ctx.actions.args()
        args.add(compiler.manifest.path)
        args.add("@better_rules_typescript/rules/typescript")
        args.add("js")
        args.add("--target", compiler.target)
        js_path = path.replace(".ts", ".js")
        map_path = path.replace(".ts", ".js.map")
        output = ctx.actions.declare_file("%s/%s" % (ctx.label.name, js_path))
        outputs.append(output)
        output_map = ctx.actions.declare_file("%s/%s" % (ctx.label.name, map_path))
        map_outputs.append(output_map)
        args.add("--js", output.path)
        args.add("--map", output_map.path)
        args.add(src.path)
        modules.append(create_module(js_path, output))
        ctx.actions.run(
            executable = ctx.attr._runner.files_to_run,
            arguments = [args],
            inputs = depset([compiler.manifest, src], transitive = [compiler.dep.transitive_files]),
            outputs = [output, output_map],
        )

        # TS

        declaration_path = path.replace(".ts", ".d.ts")
        declaration = ctx.actions.declare_file("%s/%s" % (ctx.label.name, declaration_path))
        ts_outputs.append(declaration)
        ts_modules.append(create_module(declaration_path, declaration))
        ts_args.add("--file")
        ts_args.add(src.path)
        ts_args.add(declaration.path)

    ctx.actions.run(
        executable = ctx.attr._runner.files_to_run,
        arguments = [ts_args],
        inputs = depset([compiler.manifest] + ctx.files.srcs, transitive = [compiler.dep.transitive_files]),
        outputs = ts_outputs,
    )

    package_deps = [
        create_package_dep(dep[JsInfo].name, id)
        for dep in ctx.attr.deps
        if JsInfo in dep
        for id in dep[JsInfo].ids
    ]
    js_package = create_package(
        id = str(ctx.label),
        name = package_name,
        modules = tuple(modules),
        deps = tuple(package_deps),
    )

    js_info = create_js(
        js_package,
        files = outputs,
        source_maps = map_outputs,
        deps = [compiler.runtime] + [dep[JsInfo] for dep in ctx.attr.deps if JsInfo in dep],
    )

    ts_deps = [create_package_dep(dep[TsInfo].name, dep[TsInfo].id) for dep in ctx.attr.deps if TsInfo in dep]

    ts_package = create_package(
        id = ctx.label,
        name = package_name,
        main = None,
        modules = tuple(ts_modules),
        deps = tuple(ts_deps),
    )

    ts_info = TsInfo(
        id = ctx.label,
        name = package_name,
        globals = depset(),
        transitive_files = depset(ts_outputs),
        transitive_packages = depset([ts_package]),
    )

    default_info = DefaultInfo(
        files = depset(outputs + map_outputs + ts_outputs),
    )

    output_group_info = OutputGroupInfo(
        js = outputs + map_outputs,
    )

    return [default_info, js_info, ts_info, output_group_info]

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
        "lib": attr.string_list(
            doc = "Library declarations",
        ),
        "package_name": attr.string(
            doc = "Package name",
        ),
        "strip_prefix": attr.string(
            doc = "Strip prefix",
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
