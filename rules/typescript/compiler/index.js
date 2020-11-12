const { ArgumentParser } = require('argparse');
const fs = require('fs');
const path = require('path');

const parser = new ArgumentParser();
parser.add_argument('--typescript-manifest', { required: true });
parser.add_argument('--typescript-id', { required: true });
parser.add_argument('files', { action: 'append', nargs: 2 });

const args = parser.parse_args();

readResolverManifest(args.typescript_manifest);
const ts = require(resolveById(args.typescript_id, "typescript"));

for (const [input_path, output_path] of args.files) {
    const input = fs.readFileSync(input_path, 'utf8');
    const output = ts.transpileModule(input, { compilerOptions: { module: ts.ModuleKind.CommonJS }});
    fs.mkdirSync(path.dirname(output_path), { recursive: true });
    fs.writeFileSync(output_path, output.outputText, 'utf8');
}
