// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Clones} from "@openzeppelin/contracts/proxy/Clones.sol";
import {GovernanceNFT} from "./GovernanceNFT.sol";

contract GovernanceNFTFactory is Ownable {
    using Clones for address;

    /*//////////////////////////////////////////////////////////////
                                STORAGE
    //////////////////////////////////////////////////////////////*/

    address public immutable implementation;

    uint256[] private _allProposalIds;
    mapping(uint256 => address) private _proposalToNFT;

    address[] public clonedContracts;

    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event GovernanceNFTCreated(uint256 indexed proposalId, address indexed nftAddress);

    /*//////////////////////////////////////////////////////////////
                              CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(address _implementation) Ownable(msg.sender) {
        require(_implementation != address(0), "Invalid implementation");
        implementation = _implementation;
    }

    /*//////////////////////////////////////////////////////////////
                            EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function createGovernanceNFT(uint256 _proposalId) external onlyOwner returns (address clone) {
        require(_proposalToNFT[_proposalId] == address(0), "Proposal already has NFT");

        clone = implementation.clone();

        GovernanceNFT(clone).initialize(_proposalId, msg.sender);

        _proposalToNFT[_proposalId] = clone;
        _allProposalIds.push(_proposalId);
        clonedContracts.push(clone);

        emit GovernanceNFTCreated(_proposalId, clone);
    }

    /*//////////////////////////////////////////////////////////////
                              VIEW FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function getNFTByProposal(uint256 proposalId) external view returns (address) {
        return _proposalToNFT[proposalId];
    }

    function getAllProposalIds() external view returns (uint256[] memory) {
        return _allProposalIds;
    }

    function getAllNFTs() external view returns (address[] memory) {
        return clonedContracts;
    }
}
