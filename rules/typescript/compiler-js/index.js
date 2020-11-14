"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const argparse_1 = require("argparse");
const parser = new argparse_1.ArgumentParser();
const subparsers = parser.add_subparsers({ dest: "command" });
const jsParser = subparsers.add_parser("js");
jsParser.add_argument("--target");
jsParser.add_argument("--map", { required: true });
jsParser.add_argument("--js", { required: true });
jsParser.add_argument("src");
const dtsParser = subparsers.add_parser("dts");
dtsParser.add_argument("--file", { action: "append", nargs: 2 });
const args = parser.parse_args();
(async function () {
    switch (args.command) {
        case "js": {
            const { default: js } = await Promise.resolve().then(() => require("./js"));
            js(args);
            break;
        }
        case "dts": {
            const { default: dts } = await Promise.resolve().then(() => require("./dts"));
            dts(args);
            break;
        }
    }
})().catch((error) => {
    console.error(error.stack);
    process.exit(1);
});
//# sourceMappingURL=index.js.map