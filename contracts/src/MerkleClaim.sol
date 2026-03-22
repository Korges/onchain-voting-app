// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IGovernanceNFTFactory} from "./IGovernanceNFTFactory.sol";

interface IGovernanceNFT {
    function safeMint(address to) external returns (uint256);
}

contract MerkleClaim is Ownable {
    /*//////////////////////////////////////////////////////////////
                                STORAGE
    //////////////////////////////////////////////////////////////*/

    mapping(uint256 => bytes32) private s_merkleRoots;
    mapping(bytes32 => bool) private claimed;
    IGovernanceNFTFactory private factory;

    /*//////////////////////////////////////////////////////////////
                                EVENTS
    //////////////////////////////////////////////////////////////*/

    event Claimed(address indexed user, uint256 indexed proposalId, bytes32 leaf);

    event RootUpdated(uint256 indexed proposalId, bytes32 root);

    /*//////////////////////////////////////////////////////////////
                              CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(address _factory) Ownable(msg.sender) {
        require(_factory != address(0), "Invalid factory");
        factory = IGovernanceNFTFactory(_factory);
    }

    /*//////////////////////////////////////////////////////////////
                            EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function setMerkleRoot(uint256 proposalId, bytes32 root) external onlyOwner {
        s_merkleRoots[proposalId] = root;
        emit RootUpdated(proposalId, root);
    }

    function claim(uint256 proposalId, string calldata code, bytes32[] calldata proof)
        external
        returns (uint256 tokenId)
    {
        bytes32 root = s_merkleRoots[proposalId];
        require(root != bytes32(0), "Root not set");

        bytes32 leaf = keccak256(abi.encodePacked(proposalId, code));
        require(!claimed[leaf], "Already claimed");

        bool valid = MerkleProof.verify(proof, root, leaf);
        require(valid, "Invalid proof");

        claimed[leaf] = true;

        address nftAddress = factory.getNFTByProposal(proposalId);
        require(nftAddress != address(0), "NFT not found");

        tokenId = IGovernanceNFT(nftAddress).safeMint(msg.sender);

        emit Claimed(msg.sender, proposalId, leaf);
    }
}
