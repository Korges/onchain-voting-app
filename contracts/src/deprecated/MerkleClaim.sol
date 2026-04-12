// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IGovernanceNFTFactory} from "../IGovernanceNFTFactory.sol";

interface IGovernanceNFT {
    function safeMint(address to) external returns (uint256);
}

error MerkleRootLocked(uint256 proposalId);

contract MerkleClaim is Ownable {
    /*//////////////////////////////////////////////////////////////
                                STORAGE
    //////////////////////////////////////////////////////////////*/

    IGovernanceNFTFactory private immutable i_factory;
    mapping(uint256 => bytes32) private s_merkleRoots;
    mapping(uint256 => mapping(bytes32 => bool)) private s_claimed;
    mapping(uint256 => bool) private s_rootLocked;

    /*//////////////////////////////////////////////////////////////
                                EVENTS
    //////////////////////////////////////////////////////////////*/

    event Claimed(
        address indexed user,
        uint256 indexed proposalId,
        bytes32 leaf
    );
    event RootUpdated(uint256 indexed proposalId, bytes32 root);
    event RootLocked(uint256 indexed proposalId);

    /*//////////////////////////////////////////////////////////////
                              CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(address _factoryAddress) Ownable(msg.sender) {
        require(_factoryAddress != address(0), "Invalid factory");
        i_factory = IGovernanceNFTFactory(_factoryAddress);
    }

    /*//////////////////////////////////////////////////////////////
                            EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function setMerkleRoot(
        uint256 proposalId,
        bytes32 root
    ) external onlyOwner {
        if (s_rootLocked[proposalId]) revert MerkleRootLocked(proposalId);
        s_merkleRoots[proposalId] = root;
        emit RootUpdated(proposalId, root);
    }

    function claim(
        uint256 proposalId,
        string calldata code,
        bytes32[] calldata proof
    ) external returns (uint256 tokenId) {
        bytes32 root = s_merkleRoots[proposalId];
        require(root != bytes32(0), "Root not set");

        bytes32 leaf = keccak256(abi.encodePacked(proposalId, code));
        require(!s_claimed[proposalId][leaf], "Already claimed");

        bool valid = MerkleProof.verify(proof, root, leaf);
        require(valid, "Invalid proof");

        s_claimed[proposalId][leaf] = true;
        if (!s_rootLocked[proposalId]) {
            s_rootLocked[proposalId] = true;
            emit RootLocked(proposalId);
        }

        address nftAddress = i_factory.getNFTByProposal(proposalId);
        require(nftAddress != address(0), "NFT not found");

        tokenId = IGovernanceNFT(nftAddress).safeMint(msg.sender);

        emit Claimed(msg.sender, proposalId, leaf);
    }
}
