TsInfo = provider(
    doc = "TypeScript package",
    fields = {
        "id": "ID",
        "name": "Default module prefix",
        "globals": "Depset of globally available packages",
        "transitive_files": "Depset of files",
        "transitive_packages": "Depset of packages",
        "transitive_declarations": "Depset of declaration packages",
    },
)

TsCompilerInfo = provider(
    doc = "TypeScript compiler",
    fields = {
        "manifest": "Manifest",
        "runtime": "Runtime library",
        "dep": "Library",
        "target": "Language version",
    },
)
