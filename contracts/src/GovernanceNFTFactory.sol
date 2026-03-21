// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Clones} from "@openzeppelin/contracts/proxy/Clones.sol";
import {GovernanceNFT} from "./GovernanceNFT.sol";

contract GovernanceNFTFactory is Ownable {
    using Clones for address;
    address public immutable implementation;
    uint256[] private _allProposalIds;
    mapping(uint256 => address) private _proposalToNFT;
    address[] public clonedContracts;

    event GovernanceNFTCreated(address indexed nftAddress);

    constructor(address _implementation) Ownable(msg.sender) {
        implementation = _implementation;
    }

    function createGovernanceNFT(
        uint256 _proposalId
    ) external onlyOwner returns (address) {
        require(
            _proposalToNFT[_proposalId] == address(0),
            "Proposal already has NFT"
        );

        address clone = implementation.clone();

        GovernanceNFT(clone).initialize(_proposalId, msg.sender);

        clonedContracts.push(clone);
        _proposalToNFT[_proposalId] = clone;

        emit GovernanceNFTCreated(clone);

        return clone;
    }

    function getNFTByProposal(
        uint256 proposalId
    ) external view returns (address) {
        return _proposalToNFT[proposalId];
    }

    function getAllProposalIds() external view returns (uint256[] memory) {
        return _allProposalIds;
    }

    function getAllNFTs() external view returns (address[] memory) {
        return clonedContracts;
    }
}
