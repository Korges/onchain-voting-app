import fs from "fs";
import crypto from "crypto";

let count = 10;
let proposalId = 1;

process.argv.forEach((arg, i) => {
  if (arg === "--count" && process.argv[i + 1]) {
    count = parseInt(process.argv[i + 1]);
  }
  if (arg === "--proposal" && process.argv[i + 1]) {
    proposalId = parseInt(process.argv[i + 1]);
  }
});

function randomBytes8() {
  return crypto.randomBytes(8).toString("hex"); // 16 znaków hex
}

const codes = Array.from({ length: count }, randomBytes8);

fs.mkdirSync("output", { recursive: true });
fs.writeFileSync(
  `output/proposal-${proposalId}-codes.json`,
  JSON.stringify(codes, null, 2)
);

console.log(`✅ Generated ${count} codes for proposal ${proposalId} (user-friendly)`);
