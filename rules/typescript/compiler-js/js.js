"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const fs = require("fs");
const path = require("path");
const ts = require("typescript");
function target(value) {
    switch (value) {
        case 'es3':
            return ts.ScriptTarget.ES3;
        case 'es5':
            return ts.ScriptTarget.ES5;
        case 'es6':
        case 'es2015':
            return ts.ScriptTarget.ES2015;
        case 'es2016':
            return ts.ScriptTarget.ES2016;
        case 'es2017':
            return ts.ScriptTarget.ES2017;
        case 'es2018':
            return ts.ScriptTarget.ES2018;
        case 'es2019':
            return ts.ScriptTarget.ES2019;
        case 'es2020':
            return ts.ScriptTarget.ES2020;
        default:
            return ts.ScriptTarget.ESNext;
    }
}
function default_1(args) {
    for (const [input_path, js_path, map_path] of args.files) {
        const input = fs.readFileSync(input_path, "utf8");
        const result = ts.transpileModule(input, {
            fileName: input_path,
            compilerOptions: {
                importHelpers: true,
                module: ts.ModuleKind.CommonJS,
                sourceMap: true,
                target: target(args.target),
            },
        });
        for (const diagnostic of result.diagnostics) {
            if (diagnostic.file) {
                const { line, character } = diagnostic.file.getLineAndCharacterOfPosition(diagnostic.start);
                const message = ts.flattenDiagnosticMessageText(diagnostic.messageText, "\n");
                console.log(`${diagnostic.file.fileName} (${line + 1},${character + 1}): ${message}`);
            }
            else {
                console.log(ts.flattenDiagnosticMessageText(diagnostic.messageText, "\n"));
            }
        }
        fs.mkdirSync(path.dirname(js_path), { recursive: true });
        fs.writeFileSync(js_path, result.outputText, "utf8");
        fs.mkdirSync(path.dirname(map_path), { recursive: true });
        fs.writeFileSync(map_path, result.sourceMapText, "utf8");
    }
}
exports.default = default_1;
//# sourceMappingURL=js.js.map