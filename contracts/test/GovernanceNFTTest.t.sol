// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Test} from "forge-std/Test.sol";
import {Clones} from "@openzeppelin/contracts/proxy/Clones.sol";
import {GovernanceNFT} from "../src/GovernanceNFT.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract GovernanceNFTTest is Test {
    GovernanceNFT private nft;

    address private constant OWNER = address(0xA11CE);
    address private constant USER_1 = address(0xB0B);
    address private constant USER_2 = address(0xCAFE);
    address private constant ATTACKER = address(0xBAD);

    uint256 private constant PROPOSAL_ID = 42;

    function setUp() external {
        address implementation = address(new GovernanceNFT());
        nft = GovernanceNFT(Clones.clone(implementation));
        nft.initialize(PROPOSAL_ID, OWNER);
    }

    function test_Initialize_SetsProposalId() external view {
        assertEq(nft.getProposalId(), PROPOSAL_ID);
    }

    function test_Initialize_SetsOwner() external view {
        assertEq(nft.owner(), OWNER);
    }

    function test_Initialize_StartsTokenCounterAtZero() external view {
        assertEq(nft.getTokenCounter(), 0);
    }

    function test_Initialize_RevertWhenCalledAgain() external {
        vm.expectRevert(Initializable.InvalidInitialization.selector);
        nft.initialize(1, OWNER);
    }

    function test_SafeMint_MintsTokenToRecipient() external {
        vm.prank(OWNER);
        uint256 tokenId = nft.safeMint(USER_1);

        assertEq(tokenId, 0);
        assertEq(nft.ownerOf(0), USER_1);
    }

    function test_SafeMint_EmitsEvent() external {
        vm.prank(OWNER);
        vm.expectEmit(true, true, false, false);
        emit GovernanceNFT.GovernanceNftMinted(USER_1, 0);
        nft.safeMint(USER_1);
    }

    function test_SafeMint_IncrementsTokenCounter() external {
        vm.startPrank(OWNER);
        nft.safeMint(USER_1);
        nft.safeMint(USER_2);
        vm.stopPrank();

        assertEq(nft.getTokenCounter(), 2);
    }

    function test_SafeMint_AssignsSequentialTokenIds() external {
        vm.startPrank(OWNER);
        uint256 firstId = nft.safeMint(USER_1);
        uint256 secondId = nft.safeMint(USER_2);
        vm.stopPrank();

        assertEq(firstId, 0);
        assertEq(secondId, 1);
        assertEq(nft.ownerOf(0), USER_1);
        assertEq(nft.ownerOf(1), USER_2);
    }

    function test_SafeMint_RevertWhenCallerIsNotOwner() external {
        vm.prank(ATTACKER);
        vm.expectRevert(
            abi.encodeWithSelector(
                OwnableUpgradeable.OwnableUnauthorizedAccount.selector,
                ATTACKER
            )
        );
        nft.safeMint(USER_1);
    }
}
