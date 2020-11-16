import * as path from "path";
import * as fs from "fs";
import * as ts from "typescript";
import { Resolver } from "@better_rules_javascript/rules/javascript/resolver";

const resolver = new Resolver();

function compilerHost(files: Map<string, string>): ts.CompilerHost {
  const compilerHost = ts.createCompilerHost({});
  compilerHost.resolveModuleNames = (moduleNames, containingFile) => {
    console.log(moduleNames, containingFile);
    const a = moduleNames.map((moduleName) =>
      ts.resolveModuleName(
        moduleName,
        containingFile,
        {},
        {
          fileExists: compilerHost.fileExists,
          readFile: compilerHost.readFile,
        },
      ),
    );
    console.log(a);
    return a.map(
      (a) =>
        a.resolvedModule && {
          resolvedFileName: a.resolvedModule.resolvedFileName,
        },
    );
  };

  ((delegate: ts.WriteFileCallback) =>
    (compilerHost.writeFile = (
      fileName,
      contents,
      writeByteOrderMark,
      onError,
      sourceFiles,
    ) => {
      console.log(fileName);
      if (fileName.startsWith(process.cwd())) {
        fileName = fileName.slice(process.cwd().length + 1);
      }
      const input = fileName.replace(".d.ts", ".ts");
      const output = files.get(input);
      if (!output) {
        throw new Error(`Cannot find input ${input}`);
      }
      console.log(output);
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

export default function (args) {
  const host = compilerHost(new Map(args.file));
  const program = ts.createProgram(
    args.file.map(([source]) => source),
    {
      emitDeclarationOnly: true,
      declaration: true,
    },
    host,
  );

  // for (const [_, file] of args.file) {
  //   fs.mkdirSync(path.dirname(file), { recursive: true });
  // }

  const result = program.emit();
  console.log(result);

  for (const diagnostic of ts
    .getPreEmitDiagnostics(program)
    .concat(result.diagnostics)) {
    if (diagnostic.file) {
      const { line, character } = diagnostic.file.getLineAndCharacterOfPosition(
        diagnostic.start!,
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
}
