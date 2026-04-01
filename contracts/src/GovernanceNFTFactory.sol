// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Clones} from "@openzeppelin/contracts/proxy/Clones.sol";
import {GovernanceNFT} from "./GovernanceNFT.sol";
import {IGovernanceNFTFactory} from "./IGovernanceNFTFactory.sol";

contract GovernanceNFTFactory is Ownable, IGovernanceNFTFactory {
    using Clones for address;

    /*//////////////////////////////////////////////////////////////
                                STORAGE
    //////////////////////////////////////////////////////////////*/

    address private immutable i_governanceNFT;
    uint256[] private s_allProposalIds;
    mapping(uint256 => address) private s_proposalToNFT;
    address[] private s_clonedContracts;

    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event GovernanceNFTCreated(uint256 indexed proposalId, address indexed nftAddress);

    /*//////////////////////////////////////////////////////////////
                              CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(address _governanceNFTAddress) Ownable(msg.sender) {
        require(_governanceNFTAddress != address(0), "Invalid implementation");
        i_governanceNFT = _governanceNFTAddress;
    }

    /*//////////////////////////////////////////////////////////////
                            EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function createGovernanceNFT(uint256 _proposalId) external onlyOwner returns (address clone) {
        require(s_proposalToNFT[_proposalId] == address(0), "Proposal already has NFT");

        clone = i_governanceNFT.clone();

        GovernanceNFT(clone).initialize(_proposalId, msg.sender);

        s_proposalToNFT[_proposalId] = clone;
        s_allProposalIds.push(_proposalId);
        s_clonedContracts.push(clone);

        emit GovernanceNFTCreated(_proposalId, clone);
    }

    /*//////////////////////////////////////////////////////////////
                              VIEW FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function getNFTByProposal(uint256 proposalId) external view returns (address) {
        return s_proposalToNFT[proposalId];
    }

    function getAllProposalIds() external view returns (uint256[] memory) {
        return s_allProposalIds;
    }

    function getAllNFTs() external view returns (address[] memory) {
        return s_clonedContracts;
    }
}
