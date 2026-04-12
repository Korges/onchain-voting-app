// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Test} from "forge-std/Test.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {GovernanceNFT} from "../src/GovernanceNFT.sol";
import {GovernanceNFTFactory} from "../src/GovernanceNFTFactory.sol";

contract GovernanceNFTFactoryTest is Test {
    GovernanceNFT private implementation;
    GovernanceNFTFactory private factory;

    address private constant OWNER = address(0xA11CE);
    address private constant ATTACKER = address(0xBAD);

    function setUp() external {
        implementation = new GovernanceNFT();

        vm.prank(OWNER);
        factory = new GovernanceNFTFactory(address(implementation));
    }

    function test_Constructor_SetsOwner() external view {
        assertEq(factory.owner(), OWNER);
    }

    function test_Constructor_RevertWhenImplementationIsZero() external {
        vm.expectRevert("Invalid implementation");
        new GovernanceNFTFactory(address(0));
    }

    function test_CreateGovernanceNFT_CreatesCloneAndStoresMapping() external {
        uint256 proposalId = 1;

        vm.prank(OWNER);
        address nftAddress = factory.createGovernanceNFT(proposalId);

        assertEq(factory.getNFTByProposal(proposalId), nftAddress);
        assertTrue(nftAddress != address(0));

        GovernanceNFT proposalNft = GovernanceNFT(nftAddress);
        assertEq(proposalNft.owner(), OWNER);
        assertEq(proposalNft.getProposalId(), proposalId);
        assertEq(proposalNft.getTokenCounter(), 0);
    }

    function test_CreateGovernanceNFT_EmitsEvent() external {
        uint256 proposalId = 7;

        vm.expectEmit(true, false, false, false);
        emit GovernanceNFTFactory.GovernanceNFTCreated(proposalId, address(0));

        vm.prank(OWNER);
        factory.createGovernanceNFT(proposalId);
    }

    function test_CreateGovernanceNFT_RevertWhenProposalAlreadyHasNft()
        external
    {
        uint256 proposalId = 2;

        vm.startPrank(OWNER);
        factory.createGovernanceNFT(proposalId);

        vm.expectRevert("Proposal already has NFT");
        factory.createGovernanceNFT(proposalId);
        vm.stopPrank();
    }

    function test_CreateGovernanceNFT_RevertWhenCallerIsNotOwner() external {
        vm.prank(ATTACKER);
        vm.expectRevert(
            abi.encodeWithSelector(
                Ownable.OwnableUnauthorizedAccount.selector,
                ATTACKER
            )
        );
        factory.createGovernanceNFT(1);
    }

    function test_GetNFTByProposal_ReturnsZeroWhenNotCreated() external view {
        assertEq(factory.getNFTByProposal(999), address(0));
    }

    function test_GetAllProposalIds_ReturnsCreatedIdsInOrder() external {
        vm.startPrank(OWNER);
        factory.createGovernanceNFT(11);
        factory.createGovernanceNFT(22);
        vm.stopPrank();

        uint256[] memory proposalIds = factory.getAllProposalIds();

        assertEq(proposalIds.length, 2);
        assertEq(proposalIds[0], 11);
        assertEq(proposalIds[1], 22);
    }

    function test_GetAllNFTs_ReturnsCreatedNftsInOrder() external {
        vm.startPrank(OWNER);
        address firstNft = factory.createGovernanceNFT(111);
        address secondNft = factory.createGovernanceNFT(222);
        vm.stopPrank();

        address[] memory nfts = factory.getAllNFTs();

        assertEq(nfts.length, 2);
        assertEq(nfts[0], firstNft);
        assertEq(nfts[1], secondNft);
    }
}
