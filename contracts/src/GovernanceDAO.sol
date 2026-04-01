// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IGovernanceNFTFactory} from "./IGovernanceNFTFactory.sol";

interface IProposalGovernanceNFT {
    function transferOwnership(address newOwner) external;

    function ownerOf(uint256 tokenId) external view returns (address);

    function getProposalId() external view returns (uint256);
}

error ProposalDoesNotExist(uint256 proposalId);
error ProposalNftDoesNotExist(uint256 proposalId);
error InvalidFactoryAddress();
error InvalidMerkleClaimAddress();
error NFTAlreadyUsed(uint256 tokenId);
error NotNFTOwner(address caller, uint256 tokenId);
error NFTNotValidForProposal(uint256 tokenId, uint256 proposalId);
error VotingClosed(uint256 proposalId);

contract GovernanceDAO is Ownable {
    IGovernanceNFTFactory private immutable i_governanceNFTFactory;
    address private immutable i_merkleClaimAddress;
    mapping(uint256 => Proposal) private proposals;
    mapping(uint256 => mapping(uint256 => bool)) private nftUsed;
    uint256 private proposalCounter;

    struct Proposal {
        string description;
        uint256 votesFor;
        uint256 votesAgainst;
        uint256 startTime;
        uint256 endTime;
        bool exists;
    }

    event ProposalCreated(uint256 indexed proposalId, string description, uint256 startTime);
    event VoteCast(uint256 indexed proposalId, address indexed voter, uint256 indexed tokenId, bool support);
    event ProposalClosed(uint256 indexed proposalId, uint256 endTime);

    /*//////////////////////////////////////////////////////////////
                              CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(address governanceNFTFactoryAddress, address merkleClaimAddress) Ownable(msg.sender) {
        if (governanceNFTFactoryAddress == address(0)) {
            revert InvalidFactoryAddress();
        }
        if (merkleClaimAddress == address(0)) revert InvalidMerkleClaimAddress();

        i_governanceNFTFactory = IGovernanceNFTFactory(governanceNFTFactoryAddress);
        i_merkleClaimAddress = merkleClaimAddress;
        proposalCounter = 1;
    }

    /*//////////////////////////////////////////////////////////////
                            PUBLIC FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function createProposal(string calldata description) external onlyOwner returns (address) {
        uint256 proposalId = proposalCounter;

        proposals[proposalId] = Proposal({
            description: description, votesFor: 0, votesAgainst: 0, startTime: block.timestamp, endTime: 0, exists: true
        });

        proposalCounter++;

        emit ProposalCreated(proposalId, description, block.timestamp);

        address nftAddress = i_governanceNFTFactory.createGovernanceNFT(proposalId);
        IProposalGovernanceNFT(nftAddress).transferOwnership(i_merkleClaimAddress);
        return nftAddress;
    }

    function vote(uint256 proposalId, uint256 tokenId, bool support) external {
        Proposal storage proposal = proposals[proposalId];

        if (!proposal.exists) revert ProposalDoesNotExist(proposalId);
        if (proposal.endTime != 0) revert VotingClosed(proposalId);
        if (nftUsed[proposalId][tokenId]) revert NFTAlreadyUsed(tokenId);

        address proposalNft = i_governanceNFTFactory.getNFTByProposal(proposalId);
        if (proposalNft == address(0)) {
            revert ProposalNftDoesNotExist(proposalId);
        }

        IProposalGovernanceNFT governanceNft = IProposalGovernanceNFT(proposalNft);

        if (governanceNft.ownerOf(tokenId) != msg.sender) {
            revert NotNFTOwner(msg.sender, tokenId);
        }

        if (governanceNft.getProposalId() != proposalId) {
            revert NFTNotValidForProposal(tokenId, proposalId);
        }

        nftUsed[proposalId][tokenId] = true;

        if (support) {
            proposal.votesFor++;
        } else {
            proposal.votesAgainst++;
        }

        emit VoteCast(proposalId, msg.sender, tokenId, support);
    }

    function closeProposal(uint256 proposalId) external onlyOwner {
        Proposal storage proposal = proposals[proposalId];

        if (!proposal.exists) revert ProposalDoesNotExist(proposalId);
        if (proposal.endTime != 0) revert VotingClosed(proposalId);

        proposal.endTime = block.timestamp;

        emit ProposalClosed(proposalId, block.timestamp);
    }

    /*//////////////////////////////////////////////////////////////
                             VIEW FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function getProposal(uint256 proposalId)
        external
        view
        returns (
            string memory description,
            uint256 votesFor,
            uint256 votesAgainst,
            uint256 startTime,
            uint256 endTime,
            bool exists
        )
    {
        Proposal storage proposal = proposals[proposalId];
        return (
            proposal.description,
            proposal.votesFor,
            proposal.votesAgainst,
            proposal.startTime,
            proposal.endTime,
            proposal.exists
        );
    }
}
