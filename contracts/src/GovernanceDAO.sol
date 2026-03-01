// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {GovernanceNFT} from "./GovernanceNFT.sol";

error ProposalDoesNotExist(uint256 proposalId);
error NFTAlreadyUsed(uint256 tokenId);
error NotNFTOwner(address caller, uint256 tokenId);
error NFTNotValidForProposal(uint256 tokenId, uint256 proposalId);
error VotingClosed(uint256 proposalId);

contract GovernanceDAO {
    GovernanceNFT private immutable i_governanceNFT;
    mapping(uint256 => Proposal) private proposals;
    mapping(uint256 => bool) private nftUsed;
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

    constructor(address governanceNftAddress) {
        i_governanceNFT = GovernanceNFT(governanceNftAddress);
    }

    /*//////////////////////////////////////////////////////////////
                            PUBLIC FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function createProposal(string calldata description) external returns (uint256 proposalId) {
        proposalId = proposalCounter;

        proposals[proposalId] = Proposal({
            description: description,
            votesFor: 0,
            votesAgainst: 0,
            startTime: block.timestamp,
            endTime: 0, // otwarte
            exists: true
        });

        proposalCounter++;

        emit ProposalCreated(proposalId, description, block.timestamp);
    }

    function vote(uint256 proposalId, uint256 tokenId, bool support) external {
        Proposal storage proposal = proposals[proposalId];

        if (!proposal.exists) revert ProposalDoesNotExist(proposalId);
        if (proposal.endTime != 0) revert VotingClosed(proposalId);
        if (nftUsed[tokenId]) revert NFTAlreadyUsed(tokenId);

        // check ownership
        if (i_governanceNFT.ownerOf(tokenId) != msg.sender) {
            revert NotNFTOwner(msg.sender, tokenId);
        }

        // check NFT is valid for this proposal
        if (i_governanceNFT.getProposalId() != proposalId) {
            revert NFTNotValidForProposal(tokenId, proposalId);
        }

        // Mark NFT as used
        nftUsed[tokenId] = true;

        // Count vote
        if (support) {
            proposal.votesFor++;
        } else {
            proposal.votesAgainst++;
        }

        assert(proposal.votesFor + proposal.votesAgainst <= i_governanceNFT.getTokenCounter());

        emit VoteCast(proposalId, msg.sender, tokenId, support);
    }

    function closeProposal(uint256 proposalId) external {
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
