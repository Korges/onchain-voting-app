// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

interface IGovernanceNFT {
    function mint(address to) external returns (uint256);
}

interface IGovernanceNFTFactory {
    function getNFTByProposal(uint256 proposalId) external view returns (address);
}

contract MerkleClaim is Ownable {


    mapping(uint256 => bytes32) public s_merkleRoots;


    mapping(bytes32 => bool) public claimed;

    IGovernanceNFTFactory public factory;

    event Claimed(
        address indexed user,
        uint256 indexed proposalId,
        bytes32 leaf
    );

    event RootUpdated(
        uint256 indexed proposalId,
        bytes32 root
    );

    constructor(address _factory) Ownable(msg.sender) {
        factory = IGovernanceNFTFactory(_factory);
    }

    function setMerkleRoot(
        uint256 proposalId,
        bytes32 root
    ) external onlyOwner {
        s_merkleRoots[proposalId] = root;
        emit RootUpdated(proposalId, root);
    }

    function claim(
        uint256 proposalId,
        string calldata code,
        bytes32[] calldata proof
    ) external {

        bytes32 root = s_merkleRoots[proposalId];
        require(root != bytes32(0), "Root not set");

        bytes32 leaf = keccak256(
            abi.encodePacked(msg.sender, code, proposalId)
        );

        require(!claimed[leaf], "Already claimed");

        bool valid = MerkleProof.verify(
            proof,
            root,
            leaf
        );

        require(valid, "Invalid proof");

        claimed[leaf] = true;

        address nftAddress = factory.getNFTByProposal(proposalId);

        require(nftAddress != address(0), "NFT not found");

        IGovernanceNFT(nftAddress).mint(msg.sender);

        emit Claimed(msg.sender, proposalId, leaf);
    }
}