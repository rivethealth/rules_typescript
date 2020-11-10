load("@better_rules_javascript//rules/javascript/bzl:providers.bzl", "JsPackage")
load(":providers.bzl", "TsCompiler")

def _ts_compiler_impl(ctx):
    return TsCompiler(
        compiler = ctx.attr.compiler,
        runtime = ctx.attr.runtime[JsPackage],
    )

ts_compiler = rule(
    implementation = _ts_compiler_impl,
    attrs = {
        "compiler": attr.label(
            mandatory = True,
        ),
        "runtime": attr.label(
            mandatory = True,
            providers = [JsPackage],
        )
    }
)

def _ts_library_impl(ctx):
    js = ctx.actions.declare_directory("js")
    ts = ctx.attr.ts[TsCompiler]

    ctx.actions.run(
        executable = ts.compiler.files_to_run,
        arguments = ["--outDir", js.path] + [file.path for file in ctx.files.srcs],
        inputs = ctx.files.srcs,
        outputs = [js],
    )

    return DefaultInfo(files = depset([js]))

ts_library = rule(
    implementation = _ts_library_impl,
    attrs = {
        "srcs": attr.label_list(
            allow_files = [".ts"],
            mandatory = True,
        ),
        "ts": attr.label(
            mandatory = True,
            providers = [TsCompiler],
        ),
    },
)
