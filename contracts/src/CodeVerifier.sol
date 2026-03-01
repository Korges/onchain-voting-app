// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract CodeVerifier is Ownable {
    mapping(uint256 => Proposal) public proposals; // proposalId => Merkle root
    mapping(bytes32 => bool) public codeUsed; // hash(code) => used

    struct Proposal {
        bytes32 merkleRoot;
        bool exists;
    }

    event ProposalMerkleRootSet(uint256 indexed proposalId, bytes32 merkleRoot);

    /*//////////////////////////////////////////////////////////////
                              CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/
    constructor() Ownable(msg.sender) {}

    /*//////////////////////////////////////////////////////////////
                               FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function setMerkleRoot(uint256 proposalId, bytes32 root) external onlyOwner {
        proposals[proposalId] = Proposal(root, true);
        emit ProposalMerkleRootSet(proposalId, root);
    }

    function verifyAndMarkCode(uint256 proposalId, bytes8 code, bytes32[] calldata proof) external returns (bool) {
        require(proposals[proposalId].exists, "Invalid proposalId");

        bytes32 leaf = keccak256(abi.encodePacked(code));
        require(!codeUsed[leaf], "Code already used");

        bool valid = MerkleProof.verify(proof, proposals[proposalId].merkleRoot, leaf);
        require(valid, "Invalid code/proof");

        codeUsed[leaf] = true;
        return true;
    }
}
