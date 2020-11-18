TsInfo = provider(
    doc = "TypeScript package",
    fields = {
        "ids": "Package IDs",
        "name": "Default module prefix",
        "transitive_ambiant": "Depset of ambiant declaration files",
        "transitive_packages": "Depset of packages",
        "transitive_declarations": "Depset of declaration files",
    },
)

TsCompilerInfo = provider(
    doc = "TypeScript compiler",
    fields = {
        "lib": "Libs to use",
        "manifest": "Manifest",
        "runtime": "Runtime library",
        "dep": "Library",
        "target": "Language version",
    },
)

def create_ts(package, ambiant = [], declarations = [], deps = []):
    """
    Create TsInfo

    :param struct package: Package
    :param list global_package_ids: Global package ids
    :param list declarations: Declarations
    :param list deps: Dependent TsInfo
    """
    transitive_ambiant = depset(
        ambiant,
        transitive = [ts_info.transitive_ambiant for ts_info in deps],
    )
    transitive_declarations = depset(
        declarations,
        transitive = [ts_info.transitive_declarations for ts_info in deps],
    )
    transitive_packages = depset(
        [package],
        transitive = [ts_info.transitive_packages for ts_info in deps],
    )

    return TsInfo(
        ids = [package.id],
        name = package.name,
        transitive_ambiant = transitive_ambiant,
        transitive_declarations = transitive_declarations,
        transitive_packages = transitive_packages,
    )

def merge_ts(name, deps = []):
    """
    Combine TsInfo

    :param str name: Package name
    :param list deps: Collected TsInfos
    """
    ids = {id: None for ts_info in deps for id in ts_info.ids}.keys()
    transitive_ambiant = depset(
        [],
        transitive = [ts_info.transitive_ambiant for ts_info in deps],
    )
    transitive_declarations = depset(
        [],
        transitive = [ts_info.transitive_declarations for ts_info in deps],
    )
    transitive_packages = depset(
        [],
        transitive = [ts_info.transitive_packages for ts_info in deps],
    )

    return TsInfo(
        ids = ids,
        name = name,
        transitive_ambiant = transitive_ambiant,
        transitive_declarations = transitive_declarations,
        transitive_packages = transitive_packages,
    )
