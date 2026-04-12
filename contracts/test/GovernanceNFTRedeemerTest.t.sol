// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Test} from "forge-std/Test.sol";
import {Vm} from "forge-std/Vm.sol";
import {ClaimTicket, TicketDoesNotExist, UnauthorizedGovernanceNFTRedeemer} from "../src/ClaimTicket.sol";
import {GovernanceNFTRedeemer, InvalidFactoryAddress, InvalidClaimTicketAddress, TicketNotOwned, ProposalNftDoesNotExist} from "../src/GovernanceNFTRedeemer.sol";
import {GovernanceNFT} from "../src/GovernanceNFT.sol";
import {GovernanceNFTFactory} from "../src/GovernanceNFTFactory.sol";

contract GovernanceNFTRedeemerTest is Test {
    ClaimTicket private claimTicket;
    GovernanceNFT private governanceNftImplementation;
    GovernanceNFTFactory private factory;
    GovernanceNFTRedeemer private redeemer;

    address private constant OWNER = address(0xA11CE);
    address private constant USER_1 = address(0xB0B);
    address private constant USER_2 = address(0xCAFE);
    address private constant ATTACKER = address(0xBAD);

    uint256 private constant PROPOSAL_ID = 1;

    bytes32 private constant GOVERNANCE_NFT_REDEEMED_EVENT_SIGNATURE =
        keccak256("GovernanceNftRedeemed(address,uint256,uint256,uint256)");

    function setUp() external {
        vm.prank(OWNER);
        claimTicket = new ClaimTicket();

        governanceNftImplementation = new GovernanceNFT();

        vm.prank(OWNER);
        factory = new GovernanceNFTFactory(
            address(governanceNftImplementation)
        );

        redeemer = new GovernanceNFTRedeemer(
            address(claimTicket),
            address(factory)
        );

        vm.prank(OWNER);
        claimTicket.setGovernanceNFTRedeemer(address(redeemer));
    }

    function test_Constructor_RevertWhenClaimTicketIsZero() external {
        vm.expectRevert(InvalidClaimTicketAddress.selector);
        new GovernanceNFTRedeemer(address(0), address(factory));
    }

    function test_Constructor_RevertWhenFactoryIsZero() external {
        vm.expectRevert(InvalidFactoryAddress.selector);
        new GovernanceNFTRedeemer(address(claimTicket), address(0));
    }

    function test_Getters_ReturnConfiguredAddresses() external view {
        assertEq(redeemer.getClaimTicket(), address(claimTicket));
        assertEq(redeemer.getGovernanceNFTFactory(), address(factory));
    }

    function test_Redeem_MintsGovernanceNftAndBurnsTicket() external {
        address proposalNftAddress = _createProposalNftAndTransferOwnershipToRedeemer(
                PROPOSAL_ID
            );

        vm.prank(OWNER);
        uint256 ticketId = claimTicket.mintTicket(USER_1, PROPOSAL_ID);

        vm.prank(USER_1);
        uint256 mintedTokenId = redeemer.redeem(ticketId);

        GovernanceNFT proposalNft = GovernanceNFT(proposalNftAddress);
        assertEq(mintedTokenId, 0);
        assertEq(proposalNft.ownerOf(mintedTokenId), USER_1);

        vm.expectRevert();
        claimTicket.ownerOf(ticketId);

        vm.expectRevert(
            abi.encodeWithSelector(TicketDoesNotExist.selector, ticketId)
        );
        claimTicket.getProposalId(ticketId);
    }

    function test_Redeem_EmitsEvent() external {
        _createProposalNftAndTransferOwnershipToRedeemer(PROPOSAL_ID);

        vm.prank(OWNER);
        uint256 ticketId = claimTicket.mintTicket(USER_1, PROPOSAL_ID);

        vm.recordLogs();
        vm.prank(USER_1);
        redeemer.redeem(ticketId);

        Vm.Log[] memory logs = vm.getRecordedLogs();
        bool foundEvent;

        for (uint256 i = 0; i < logs.length; i++) {
            if (
                logs[i].emitter == address(redeemer) &&
                logs[i].topics[0] == GOVERNANCE_NFT_REDEEMED_EVENT_SIGNATURE
            ) {
                foundEvent = true;
                break;
            }
        }

        assertTrue(foundEvent);
    }

    function test_Redeem_RevertWhenCallerDoesNotOwnTicket() external {
        _createProposalNftAndTransferOwnershipToRedeemer(PROPOSAL_ID);

        vm.prank(OWNER);
        uint256 ticketId = claimTicket.mintTicket(USER_1, PROPOSAL_ID);

        vm.prank(ATTACKER);
        vm.expectRevert(
            abi.encodeWithSelector(TicketNotOwned.selector, ATTACKER, ticketId)
        );
        redeemer.redeem(ticketId);
    }

    function test_Redeem_RevertWhenProposalNftDoesNotExist() external {
        vm.prank(OWNER);
        uint256 ticketId = claimTicket.mintTicket(USER_1, PROPOSAL_ID);

        vm.prank(USER_1);
        vm.expectRevert(
            abi.encodeWithSelector(
                ProposalNftDoesNotExist.selector,
                PROPOSAL_ID
            )
        );
        redeemer.redeem(ticketId);
    }

    function test_Redeem_RevertWhenRedeemerNotAuthorizedInClaimTicket()
        external
    {
        GovernanceNFTRedeemer unregisteredRedeemer = new GovernanceNFTRedeemer(
            address(claimTicket),
            address(factory)
        );

        address proposalNftAddress = _createProposalNftAndTransferOwnershipToRedeemer(
                PROPOSAL_ID
            );

        vm.prank(address(redeemer));
        GovernanceNFT(proposalNftAddress).transferOwnership(
            address(unregisteredRedeemer)
        );

        vm.prank(OWNER);
        uint256 ticketId = claimTicket.mintTicket(USER_1, PROPOSAL_ID);

        vm.prank(USER_1);
        vm.expectRevert(
            abi.encodeWithSelector(
                UnauthorizedGovernanceNFTRedeemer.selector,
                address(unregisteredRedeemer)
            )
        );
        unregisteredRedeemer.redeem(ticketId);
    }

    function test_Redeem_ReturnsSequentialTokenIdsAcrossMultipleUsers()
        external
    {
        address proposalNftAddress = _createProposalNftAndTransferOwnershipToRedeemer(
                PROPOSAL_ID
            );

        vm.startPrank(OWNER);
        uint256 firstTicketId = claimTicket.mintTicket(USER_1, PROPOSAL_ID);
        uint256 secondTicketId = claimTicket.mintTicket(USER_2, PROPOSAL_ID);
        vm.stopPrank();

        vm.prank(USER_1);
        uint256 firstMintedId = redeemer.redeem(firstTicketId);

        vm.prank(USER_2);
        uint256 secondMintedId = redeemer.redeem(secondTicketId);

        GovernanceNFT proposalNft = GovernanceNFT(proposalNftAddress);
        assertEq(firstMintedId, 0);
        assertEq(secondMintedId, 1);
        assertEq(proposalNft.ownerOf(firstMintedId), USER_1);
        assertEq(proposalNft.ownerOf(secondMintedId), USER_2);
    }

    function _createProposalNftAndTransferOwnershipToRedeemer(
        uint256 proposalId
    ) private returns (address proposalNftAddress) {
        vm.prank(OWNER);
        proposalNftAddress = factory.createGovernanceNFT(proposalId);

        vm.prank(OWNER);
        GovernanceNFT(proposalNftAddress).transferOwnership(address(redeemer));
    }
}
