// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Test} from "forge-std/Test.sol";
import {ClaimTicket, InvalidRecipient, InvalidProposalId, InvalidGovernanceNFTRedeemer, TicketDoesNotExist, UnauthorizedGovernanceNFTRedeemer} from "../src/ClaimTicket.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract ClaimTicketTest is Test {
    ClaimTicket private claimTicket;

    address private constant OWNER = address(0xA11CE);
    address private constant USER_1 = address(0xB0B);
    address private constant USER_2 = address(0xCAFE);
    address private constant USER_3 = address(0xD00D);
    address private constant REDEEMER = address(0xDEAD);
    address private constant ATTACKER = address(0xBAD);

    function setUp() external {
        vm.prank(OWNER);
        claimTicket = new ClaimTicket();
    }

    function test_ConstructorInitializesState() external view {
        assertEq(claimTicket.getNextTicketId(), 1);
        assertEq(claimTicket.getGovernanceNFTRedeemer(), address(0));
    }

    function test_MintTicket_MintsAndStoresProposalId() external {
        uint256 proposalId = 7;

        vm.prank(OWNER);
        uint256 ticketId = claimTicket.mintTicket(USER_1, proposalId);

        assertEq(ticketId, 1);
        assertEq(claimTicket.ownerOf(ticketId), USER_1);
        assertEq(claimTicket.getProposalId(ticketId), proposalId);
        assertEq(claimTicket.getNextTicketId(), 2);
    }

    function test_MintTicket_RevertWhenRecipientIsZero() external {
        vm.prank(OWNER);
        vm.expectRevert(InvalidRecipient.selector);
        claimTicket.mintTicket(address(0), 1);
    }

    function test_MintTicket_RevertWhenProposalIdIsZero() external {
        vm.prank(OWNER);
        vm.expectRevert(InvalidProposalId.selector);
        claimTicket.mintTicket(USER_1, 0);
    }

    function test_MintTicket_RevertWhenCallerIsNotOwner() external {
        vm.prank(ATTACKER);
        vm.expectRevert(
            abi.encodeWithSelector(
                Ownable.OwnableUnauthorizedAccount.selector,
                ATTACKER
            )
        );
        claimTicket.mintTicket(USER_1, 1);
    }

    function test_MintBatch_MintsSequentialIdsAndReturnsThem() external {
        address[] memory recipients = new address[](3);
        recipients[0] = USER_1;
        recipients[1] = USER_2;
        recipients[2] = USER_3;
        uint256 proposalId = 5;

        vm.prank(OWNER);
        uint256[] memory ticketIds = claimTicket.mintBatch(
            recipients,
            proposalId
        );

        assertEq(ticketIds.length, 3);
        assertEq(ticketIds[0], 1);
        assertEq(ticketIds[1], 2);
        assertEq(ticketIds[2], 3);

        assertEq(claimTicket.ownerOf(1), USER_1);
        assertEq(claimTicket.ownerOf(2), USER_2);
        assertEq(claimTicket.ownerOf(3), USER_3);

        assertEq(claimTicket.getProposalId(1), proposalId);
        assertEq(claimTicket.getProposalId(2), proposalId);
        assertEq(claimTicket.getProposalId(3), proposalId);
        assertEq(claimTicket.getNextTicketId(), 4);
    }

    function test_MintBatch_RevertWhenProposalIdIsZero() external {
        address[] memory recipients = new address[](1);
        recipients[0] = USER_1;

        vm.prank(OWNER);
        vm.expectRevert(InvalidProposalId.selector);
        claimTicket.mintBatch(recipients, 0);
    }

    function test_MintBatch_RevertWhenAnyRecipientIsZero() external {
        address[] memory recipients = new address[](2);
        recipients[0] = USER_1;
        recipients[1] = address(0);

        vm.prank(OWNER);
        vm.expectRevert(InvalidRecipient.selector);
        claimTicket.mintBatch(recipients, 1);
    }

    function test_SetGovernanceNFTRedeemer_UpdatesAddress() external {
        vm.prank(OWNER);
        claimTicket.setGovernanceNFTRedeemer(REDEEMER);

        assertEq(claimTicket.getGovernanceNFTRedeemer(), REDEEMER);
    }

    function test_SetGovernanceNFTRedeemer_RevertWhenZeroAddress() external {
        vm.prank(OWNER);
        vm.expectRevert(InvalidGovernanceNFTRedeemer.selector);
        claimTicket.setGovernanceNFTRedeemer(address(0));
    }

    function test_BurnTicket_RevertWhenCallerIsNotRedeemer() external {
        vm.prank(OWNER);
        uint256 ticketId = claimTicket.mintTicket(USER_1, 1);

        vm.prank(ATTACKER);
        vm.expectRevert(
            abi.encodeWithSelector(
                UnauthorizedGovernanceNFTRedeemer.selector,
                ATTACKER
            )
        );
        claimTicket.burnTicket(ticketId);
    }

    function test_BurnTicket_BurnsAndDeletesProposalMapping() external {
        vm.startPrank(OWNER);
        claimTicket.setGovernanceNFTRedeemer(REDEEMER);
        uint256 ticketId = claimTicket.mintTicket(USER_1, 9);
        vm.stopPrank();

        vm.prank(REDEEMER);
        claimTicket.burnTicket(ticketId);

        vm.expectRevert();
        claimTicket.ownerOf(ticketId);

        vm.expectRevert(
            abi.encodeWithSelector(TicketDoesNotExist.selector, ticketId)
        );
        claimTicket.getProposalId(ticketId);
    }

    function test_GetProposalId_RevertWhenTicketDoesNotExist() external {
        vm.expectRevert(
            abi.encodeWithSelector(TicketDoesNotExist.selector, 999)
        );
        claimTicket.getProposalId(999);
    }

    function test_BurnTicket_RevertWhenTicketDoesNotExist() external {
        vm.prank(OWNER);
        claimTicket.setGovernanceNFTRedeemer(REDEEMER);

        uint256 nonExistentTicketId = 999;

        vm.prank(REDEEMER);
        vm.expectRevert(
            abi.encodeWithSelector(
                TicketDoesNotExist.selector,
                nonExistentTicketId
            )
        );
        claimTicket.burnTicket(nonExistentTicketId);
    }
}
