// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {ClaimTicket} from "./ClaimTicket.sol";
import {IGovernanceNFTFactory} from "./IGovernanceNFTFactory.sol";

interface IGovernanceNFT {
    function safeMint(address to) external returns (uint256 tokenId);
}

error InvalidFactoryAddress();
error InvalidClaimTicketAddress();
error TicketNotOwned(address caller, uint256 ticketId);
error ProposalNftDoesNotExist(uint256 proposalId);

contract GovernanceNFTRedeemer is ReentrancyGuard {
    /*//////////////////////////////////////////////////////////////
                                STORAGE
    //////////////////////////////////////////////////////////////*/
    ClaimTicket private immutable i_claimTicket;
    IGovernanceNFTFactory private immutable i_governanceNFTFactory;

    /*//////////////////////////////////////////////////////////////
                                EVENTS
    //////////////////////////////////////////////////////////////*/

    event GovernanceNftRedeemed(
        address indexed user,
        uint256 indexed proposalId,
        uint256 indexed ticketId,
        uint256 governanceNftTokenId
    );

    /*//////////////////////////////////////////////////////////////
                             CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(
        address claimTicketAddress,
        address governanceNftFactoryAddress
    ) {
        if (claimTicketAddress == address(0))
            revert InvalidClaimTicketAddress();
        if (governanceNftFactoryAddress == address(0))
            revert InvalidFactoryAddress();

        i_claimTicket = ClaimTicket(claimTicketAddress);
        i_governanceNFTFactory = IGovernanceNFTFactory(
            governanceNftFactoryAddress
        );
    }

    /*//////////////////////////////////////////////////////////////
                          EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function redeem(
        uint256 ticketId
    ) external nonReentrant returns (uint256 governanceNftTokenId) {
        if (i_claimTicket.ownerOf(ticketId) != msg.sender) {
            revert TicketNotOwned(msg.sender, ticketId);
        }

        uint256 proposalId = i_claimTicket.getProposalId(ticketId);
        address proposalNft = i_governanceNFTFactory.getNFTByProposal(
            proposalId
        );

        if (proposalNft == address(0)) {
            revert ProposalNftDoesNotExist(proposalId);
        }

        i_claimTicket.burnTicket(ticketId);
        governanceNftTokenId = IGovernanceNFT(proposalNft).safeMint(msg.sender);

        emit GovernanceNftRedeemed(
            msg.sender,
            proposalId,
            ticketId,
            governanceNftTokenId
        );
    }

    /*//////////////////////////////////////////////////////////////
                            VIEW FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function getClaimTicket() external view returns (address) {
        return address(i_claimTicket);
    }

    function getGovernanceNFTFactory() external view returns (address) {
        return address(i_governanceNFTFactory);
    }
}
