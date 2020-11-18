load("@better_rules_javascript//rules/javascript/bzl:rules.bzl", "default_package_name", "default_strip_prefix")
load("@better_rules_javascript//rules/javascript/bzl:providers.bzl", "JsInfo", "create_js", "create_module", "create_package", "create_package_dep", "merge_js")
load("@better_rules_javascript//rules/nodejs/bzl:rules.bzl", "write_packages_manifest")
load("@better_rules_javascript//rules/util/bzl:json.bzl", "json")
load("@better_rules_javascript//rules/util/bzl:path.bzl", "runfile_path")
load(":providers.bzl", "TsCompilerInfo", "TsInfo", "create_ts")

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
        lib = ctx.attr.lib,
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
        "lib": attr.string_list(),
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

def _path(file):
    return file.path

def _package_arg(package):
    arg = struct(
        id = package.id,
        name = package.name,
        main = package.main,
        modules = tuple([struct(name = module.name, file = module.file.path) for module in package.modules]),
        deps = [struct(id = str(dep.id), name = dep.name) for dep in package.deps],
    )
    return json.encode(struct(type = "PACKAGE", value = arg))

def write_ts_packages_manifest(ctx, file, dts_info):
    package_args = ctx.actions.args()
    package_args.set_param_file_format("multiline")
    package_args.add_all(dts_info.transitive_packages, map_each = _package_arg)
    ctx.actions.write(file, package_args)

def _ts_library_impl(ctx):
    package_name = ctx.attr.package_name or default_package_name(ctx)
    strip_prefix = ctx.attr.strip_prefix or default_strip_prefix(ctx)

    compiler = ctx.attr.compiler[TsCompilerInfo]

    outputs = []
    source_maps = []
    modules = []
    ts_modules = []
    dts_modules = []
    dts = []

    ts_args = ctx.actions.args()
    ts_args.add(compiler.manifest.path)
    ts_args.add("@better_rules_typescript/rules/typescript")
    ts_args.add("dts")

    manifest = ctx.actions.declare_file("%s/packages-manifest.txt" % ctx.label.name)
    ts_args.add("--manifest", manifest.path)

    for lib in compiler.lib:
        ts_args.add("--lib", lib)

    for src in ctx.files.srcs:
        path = runfile_path(ctx, src)
        if strip_prefix:
            if not path.startswith(strip_prefix + "/"):
                fail("Source %s does not have prefix %s" % (path, strip_prefix))
            path = path[len(strip_prefix + "/"):]
        if ctx.attr.prefix:
            path = ctx.attr.prefix + "/" + path
        ts_modules.append(create_module(path, src))

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
        source_map = ctx.actions.declare_file("%s/%s" % (ctx.label.name, map_path))
        source_maps.append(source_map)
        args.add("--js", output.path)
        args.add("--map", source_map.path)
        args.add(src.path)
        modules.append(create_module(js_path, output))
        ctx.actions.run(
            executable = ctx.attr._runner.files_to_run,
            arguments = [args],
            inputs = depset([compiler.manifest, src], transitive = [compiler.dep.transitive_files]),
            outputs = [output, source_map],
        )

        # TS

        declaration_path = path.replace(".ts", ".d.ts")
        declaration = ctx.actions.declare_file("%s/%s" % (ctx.label.name, declaration_path))
        dts.append(declaration)
        dts_modules.append(create_module(declaration_path, declaration))
        ts_args.add("--src")
        ts_args.add(src.path)
        ts_args.add(declaration.path)

    package_deps = [
        create_package_dep(dep[JsInfo].name, id)
        for dep in ctx.attr.deps
        if JsInfo in dep
        for id in dep[JsInfo].ids
    ]
    package_deps += [
        create_package_dep(compiler.runtime.name, id)
        for id in compiler.runtime.ids
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
        source_maps = source_maps,
        deps = [compiler.runtime] + [dep[JsInfo] for dep in ctx.attr.deps if JsInfo in dep],
    )

    ts_deps = [
        create_package_dep(dep[TsInfo].name, id)
        for dep in ctx.attr.deps
        if TsInfo in dep
        for id in dep[TsInfo].ids
    ]

    ts_package = create_package(
        id = str(ctx.label),
        name = package_name,
        modules = tuple(ts_modules),
        deps = tuple(ts_deps),
    )
    ts_info = create_ts(
        ts_package,
        declarations = ctx.files.srcs,
        deps = [dep[TsInfo] for dep in ctx.attr.deps if TsInfo in dep],
    )
    write_ts_packages_manifest(ctx, manifest, ts_info)

    ts_args.add_all(ts_info.transitive_ambiant, before_each = "--dts", map_each = _path)

    ctx.actions.run(
        executable = ctx.attr._runner.files_to_run,
        arguments = [ts_args],
        inputs = depset(
            [compiler.manifest, manifest] + ctx.files.srcs,
            transitive = [compiler.dep.transitive_files, ts_info.transitive_ambiant, ts_info.transitive_declarations],
        ),
        outputs = dts,
    )

    dts_package = create_package(
        id = str(ctx.label),
        name = package_name,
        modules = tuple(dts_modules),
        deps = tuple(ts_deps),
    )
    dts_info = create_ts(
        dts_package,
        declarations = dts,
        deps = [dep[TsInfo] for dep in ctx.attr.deps if TsInfo in dep],
    )

    default_info = DefaultInfo(
        files = depset(outputs + source_maps + dts),
    )

    output_group_info = OutputGroupInfo(
        js = outputs + source_maps,
    )

    return [default_info, js_info, dts_info, output_group_info]

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

def _ts_import_impl(ctx):
    package_name = ctx.attr.js_name or default_package_name(ctx)
    strip_prefix = ctx.attr.strip_prefix or default_strip_prefix(ctx)

    dts_modules = []
    for src in ctx.files.declarations:
        path = runfile_path(ctx, src)
        if strip_prefix:
            if not path.startswith(strip_prefix + "/"):
                fail("Source %s does not have prefix %s" % (path, strip_prefix))
            path = path[len(strip_prefix + "/"):]
        if ctx.attr.prefix:
            path = ctx.attr.prefix + "/" + path
        dts_modules.append(create_module(path, src))

    ts_deps = [
        create_package_dep(dep[TsInfo].name, id)
        for dep in ctx.attr.deps
        if TsInfo in dep
        for id in dep[TsInfo].ids
    ]

    dts_package = create_package(
        id = str(ctx.label),
        name = package_name,
        main = ctx.attr.main,
        modules = tuple(dts_modules),
        deps = tuple(ts_deps),
    )
    dts_info = create_ts(
        dts_package,
        ambiant = ctx.files.ambiant,
        declarations = ctx.files.declarations,
        deps = [dep[TsInfo] for dep in ctx.attr.deps if TsInfo in dep],
    )

    js_info = merge_js(
        package_name,
        deps = [dep[JsInfo] for dep in ctx.attr.deps if JsInfo in dep],
    )

    return [js_info, dts_info]

ts_import = rule(
    implementation = _ts_import_impl,
    attrs = {
        "ambiant": attr.label_list(
            doc = "Ambiant declarations",
            allow_files = [".d.ts"],
        ),
        "declarations": attr.label_list(
            doc = "Declarations",
            allow_files = [".d.ts"],
        ),
        "deps": attr.label_list(
            doc = "Dependencies",
            providers = [[JsInfo], [TsInfo]],
        ),
        "js_name": attr.string(
            doc = "Package name",
        ),
        "strip_prefix": attr.string(
            doc = "Strip prefix",
        ),
        "main": attr.string(
            doc = "Main",
        ),
        "prefix": attr.string(
            doc = "Prefix",
        ),
    },
)
