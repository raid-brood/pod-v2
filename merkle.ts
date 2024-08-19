import { StandardMerkleTree } from "@openzeppelin/merkle-tree";
import fs from "fs";

// Creating a Merkle Tree
// (1)
const values = [
  ["randomClaimCode1"],
  ["randomClaimCode2"]
];

// (2)
const tree = StandardMerkleTree.of(values, ["string"]);

// (3)
console.log('Merkle Root:', tree.root);

// (4)
fs.writeFileSync("tree.json", JSON.stringify(tree.dump()));

// Generating a proof
// (1)
for (const [i, v] of tree.entries()) {
  if (v[0] === 'randomClaimCode1') {
    // (2)
    const proof = tree.getProof(i);
    console.log('Value:', v);
    console.log('Proof:', proof);
  }
}