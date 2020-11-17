// import "source-map-support/register";
import { ArgumentParser } from "argparse";

const parser = new ArgumentParser();
const subparsers = parser.add_subparsers({ dest: "command" });

const jsParser = subparsers.add_parser("js");
jsParser.add_argument("--target");
jsParser.add_argument("--map", { required: true });
jsParser.add_argument("--js", { required: true });
jsParser.add_argument("src");

const dtsParser = subparsers.add_parser("dts");
dtsParser.add_argument("--manifest", { required: true });
dtsParser.add_argument("--dts", { action: "append" });
dtsParser.add_argument("--src", { action: "append", nargs: 2 });

const args = parser.parse_args();

(async function () {
  switch (args.command) {
    case "js": {
      const { default: js } = await import("./js");
      js(args);
      break;
    }
    case "dts": {
      const { default: dts } = await import("./dts");
      dts(args);
      break;
    }
  }
})().catch((error) => {
  console.error(error.stack);
  process.exit(1);
});
