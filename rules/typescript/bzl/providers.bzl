TsPackage = provider(
    doc = "TypeScript package",
    fields = {
        "id": "ID",
        "name": "Default module prefix",
        "transitive_files": "Depset of files",
        "transitive_packages": "Depset of packages",
        "transitive_declarations": "Depset of declaration packages",
        "transitive_source_maps": "Depset of source maps",
    },
)

TsCompiler = provider(
    doc = "TypeScript compiler",
    fields = {
        "compiler": "Compiler",
        "runtime": "Runtime library"
    }
)
