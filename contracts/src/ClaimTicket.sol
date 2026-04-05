// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

error InvalidRecipient();
error InvalidProposalId();
error InvalidGovernanceNFTRedeemer();
error TicketDoesNotExist(uint256 ticketId);
error UnauthorizedGovernanceNFTRedeemer(address caller);

contract ClaimTicket is ERC721, Ownable {
    /*//////////////////////////////////////////////////////////////
                                STORAGE
    //////////////////////////////////////////////////////////////*/
    uint256 private s_nextTicketId;
    address private s_governanceNFTRedeemer;
    mapping(uint256 => uint256) private s_ticketToProposalId;

    /*//////////////////////////////////////////////////////////////
                                EVENTS
    //////////////////////////////////////////////////////////////*/

    event ClaimTicketMinted(
        address indexed to,
        uint256 indexed ticketId,
        uint256 indexed proposalId
    );
    event ClaimTicketBurned(
        uint256 indexed ticketId,
        address indexed governanceNFTRedeemer,
        uint256 indexed proposalId
    );
    event GovernanceNFTRedeemerUpdated(address indexed governanceNFTRedeemer);

    /*//////////////////////////////////////////////////////////////
                             CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor() ERC721("Claim Ticket", "CTKT") Ownable(msg.sender) {
        s_nextTicketId = 1;
    }

    /*//////////////////////////////////////////////////////////////
                           OWNER FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function mintTicket(
        address to,
        uint256 proposalId
    ) external onlyOwner returns (uint256 ticketId) {
        if (to == address(0)) revert InvalidRecipient();
        if (proposalId == 0) revert InvalidProposalId();

        ticketId = s_nextTicketId;
        s_nextTicketId++;

        s_ticketToProposalId[ticketId] = proposalId;
        _safeMint(to, ticketId);

        emit ClaimTicketMinted(to, ticketId, proposalId);
    }

    function mintBatch(
        address[] calldata recipients,
        uint256 proposalId
    ) external onlyOwner returns (uint256[] memory ticketIds) {
        if (proposalId == 0) revert InvalidProposalId();

        uint256 recipientsLength = recipients.length;
        ticketIds = new uint256[](recipientsLength);

        for (uint256 index = 0; index < recipientsLength; index++) {
            address recipient = recipients[index];
            if (recipient == address(0)) revert InvalidRecipient();

            uint256 ticketId = s_nextTicketId;
            s_nextTicketId++;

            s_ticketToProposalId[ticketId] = proposalId;
            _safeMint(recipient, ticketId);
            ticketIds[index] = ticketId;

            emit ClaimTicketMinted(recipient, ticketId, proposalId);
        }
    }

    function setGovernanceNFTRedeemer(
        address governanceNFTRedeemer
    ) external onlyOwner {
        if (governanceNFTRedeemer == address(0)) {
            revert InvalidGovernanceNFTRedeemer();
        }

        s_governanceNFTRedeemer = governanceNFTRedeemer;

        emit GovernanceNFTRedeemerUpdated(governanceNFTRedeemer);
    }

    /*//////////////////////////////////////////////////////////////
                          EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function burnTicket(uint256 ticketId) external {
        if (msg.sender != s_governanceNFTRedeemer) {
            revert UnauthorizedGovernanceNFTRedeemer(msg.sender);
        }

        uint256 proposalId = s_ticketToProposalId[ticketId];
        if (proposalId == 0) revert TicketDoesNotExist(ticketId);

        delete s_ticketToProposalId[ticketId];
        _burn(ticketId);

        emit ClaimTicketBurned(ticketId, msg.sender, proposalId);
    }

    /*//////////////////////////////////////////////////////////////
                            VIEW FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function getProposalId(
        uint256 ticketId
    ) external view returns (uint256 proposalId) {
        proposalId = s_ticketToProposalId[ticketId];
        if (proposalId == 0) revert TicketDoesNotExist(ticketId);
    }

    function getNextTicketId() external view returns (uint256) {
        return s_nextTicketId;
    }

    function getGovernanceNFTRedeemer() external view returns (address) {
        return s_governanceNFTRedeemer;
    }
}
