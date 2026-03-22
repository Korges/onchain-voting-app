import fs from "fs";
import { keccak256, solidityPacked } from "ethers";
import { MerkleTree } from "merkletreejs";

const proposalId = 1;

const userCodes = JSON.parse(
  fs.readFileSync(`output/proposal-${proposalId}-codes.json`)
);

const leaves = userCodes.map(code =>
  keccak256(solidityPacked(["uint256", "string"], [proposalId, code]))
);

const tree = new MerkleTree(leaves, keccak256, { sortPairs: true });
const root = tree.getHexRoot();

const output = {
  proposalId,
  root: root,
  leaves: userCodes.map((code, i) => ({
    code,
    leaf: leaves[i],
    proof: tree.getHexProof(leaves[i])
  }))
};

fs.writeFileSync(
  `output/proposal-${proposalId}-merkle-tree.json`,
  JSON.stringify(output, null, 2)
);

console.log("🌳 Merkle root:", root);
console.log(`✅ Merkle tree saved in output/proposal-${proposalId}-merkle-tree.json`);
