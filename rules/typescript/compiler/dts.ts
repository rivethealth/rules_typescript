import * as ts from "typescript";
import { Resolver } from "@better_rules_javascript/rules/javascript/resolver";

/**
 * Create compiler host
 */
function compilerHost(
  resolver: Resolver,
  files: Map<string, string>,
): ts.CompilerHost {
  const compilerHost = ts.createCompilerHost({});
  compilerHost.resolveModuleNames = (moduleNames, containingFile) =>
    moduleNames.map((moduleName) => {
      let result: ts.ResolvedModule | undefined;
      try {
         result = { resolvedFileName: resolver.resolve(moduleName, containingFile)};
      } catch (e) {
        console.log(e.message);
      }
      return result;
    });

  ((delegate: ts.WriteFileCallback) =>
    (compilerHost.writeFile = (
      fileName,
      contents,
      writeByteOrderMark,
      onError,
      sourceFiles,
    ) => {
      if (fileName.startsWith(process.cwd())) {
        fileName = fileName.slice(process.cwd().length + 1);
      }
      const input = fileName.replace(".d.ts", ".ts");
      const output = files.get(input);
      if (!output) {
        throw new Error(`Cannot find input ${input}`);
      }
      const result = delegate(
        output,
        contents,
        writeByteOrderMark,
        onError,
        sourceFiles,
      );
      return result;
    }))(compilerHost.writeFile);

  return compilerHost;
}

/**
 * TS path variations
 */
function pathVariations(request): string[] {
  let variations: string[] = [];
  if (request.endsWith(".js")) {
    request = request.slice(-".js".length);
    variations = [
      `${request}.ts`,
      `${request}.tsx`,
      `${request}.d.ts`,
      `${request}.js`,
      `${request}.jsx`,
    ];
  } else {
    variations = [
      `${request}.ts`,
      `${request}.tsx`,
      `${request}.d.ts`,
      `${request}.js`,
      `${request}.jsx`,
      `${request}/index.ts`,
      `${request}/index.tsx`,
      `${request}/index.d.ts`,
      `${request}/index.js`,
      `${request}/index.jsx`,
    ];
  }
  return variations;
}

/**
 * dts CLI
 */
export default function (args) {
  const resolver = new Resolver(false, pathVariations);
  Resolver.readManifest(resolver, args.manifest, (path) => path);

  const host = compilerHost(resolver, new Map(args.src));
  const libs = ['lib.d.ts', ...(args.lib || []).map(name => `lib.${name}.d.ts`)];
  const program = ts.createProgram(
    [...(args.dts || []), ...args.src.map(([source]) => source)],
    { emitDeclarationOnly: true, declaration: true, lib: libs, target: ts.ScriptTarget.ESNext },
    host,
  );

  const result = program.emit();

  const diagnostics=  ts.getPreEmitDiagnostics(program)
  .concat(result.diagnostics);

  if (!diagnostics.length) {
    return;
  }

  for (const diagnostic of diagnostics) {
    if (diagnostic.file) {
      const { line, character } = diagnostic.file.getLineAndCharacterOfPosition(
        diagnostic.start,
      );
      const message = ts.flattenDiagnosticMessageText(
        diagnostic.messageText,
        "\n",
      );
      console.log(
        `${diagnostic.file.fileName} (${line + 1},${
          character + 1
        }): ${message}`,
      );
    } else {
      console.log(
        ts.flattenDiagnosticMessageText(diagnostic.messageText, "\n"),
      );
    }
  }

  process.exit(1);
}
