// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Test} from "forge-std/Test.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {GovernanceDAO, ProposalDoesNotExist, ProposalNftDoesNotExist, InvalidFactoryAddress, InvalidGovernanceNFTRedeemerAddress, NFTAlreadyUsed, NotNFTOwner, NFTNotValidForProposal, VotingClosed} from "../src/GovernanceDAO.sol";
import {GovernanceNFT} from "../src/GovernanceNFT.sol";
import {GovernanceNFTFactory} from "../src/GovernanceNFTFactory.sol";
import {IGovernanceNFTFactory} from "../src/IGovernanceNFTFactory.sol";

contract MockProposalNft {
    mapping(uint256 => address) private s_owners;
    uint256 private s_proposalId;

    constructor(uint256 proposalId_) {
        s_proposalId = proposalId_;
    }

    function transferOwnership(address) external {}

    function ownerOf(uint256 tokenId) external view returns (address) {
        return s_owners[tokenId];
    }

    function getProposalId() external view returns (uint256) {
        return s_proposalId;
    }

    function setOwnerOf(uint256 tokenId, address owner_) external {
        s_owners[tokenId] = owner_;
    }

    function setProposalId(uint256 proposalId_) external {
        s_proposalId = proposalId_;
    }
}

contract MockGovernanceNFTFactory is IGovernanceNFTFactory {
    address private s_nftAddress;
    bool private s_returnZeroInGet;

    constructor(address nftAddress_) {
        s_nftAddress = nftAddress_;
    }

    function createGovernanceNFT(uint256) external view returns (address) {
        return s_nftAddress;
    }

    function getNFTByProposal(uint256) external view returns (address) {
        if (s_returnZeroInGet) {
            return address(0);
        }
        return s_nftAddress;
    }

    function setReturnZeroInGet(bool value) external {
        s_returnZeroInGet = value;
    }
}

contract GovernanceDAOTest is Test {
    GovernanceNFT private governanceNftImplementation;
    GovernanceNFTFactory private factory;
    GovernanceDAO private dao;

    address private constant OWNER = address(0xA11CE);
    address private constant REDEEMER = address(0xDEAD);
    address private constant USER_1 = address(0xB0B);
    address private constant USER_2 = address(0xCAFE);
    address private constant ATTACKER = address(0xBAD);

    function setUp() external {
        governanceNftImplementation = new GovernanceNFT();

        vm.prank(OWNER);
        factory = new GovernanceNFTFactory(
            address(governanceNftImplementation)
        );

        vm.prank(OWNER);
        dao = new GovernanceDAO(address(factory), REDEEMER);

        vm.prank(OWNER);
        factory.transferOwnership(address(dao));
    }

    function test_Constructor_RevertWhenFactoryIsZero() external {
        vm.expectRevert(InvalidFactoryAddress.selector);
        new GovernanceDAO(address(0), REDEEMER);
    }

    function test_Constructor_RevertWhenRedeemerIsZero() external {
        vm.expectRevert(InvalidGovernanceNFTRedeemerAddress.selector);
        new GovernanceDAO(address(factory), address(0));
    }

    function test_CreateProposal_CreatesProposalAndTransfersNftOwnership()
        external
    {
        vm.prank(OWNER);
        (uint256 proposalId, address nftAddress) = dao.createProposal("P1");

        (
            string memory description,
            uint256 votesFor,
            uint256 votesAgainst,
            uint256 startTime,
            uint256 endTime,
            bool exists
        ) = dao.getProposal(proposalId);

        assertEq(proposalId, 1);
        assertEq(description, "P1");
        assertEq(votesFor, 0);
        assertEq(votesAgainst, 0);
        assertTrue(startTime > 0);
        assertEq(endTime, 0);
        assertTrue(exists);

        assertEq(factory.getNFTByProposal(proposalId), nftAddress);
        assertEq(GovernanceNFT(nftAddress).owner(), REDEEMER);
    }

    function test_CreateProposal_ReturnsSequentialProposalIds() external {
        vm.startPrank(OWNER);
        (uint256 firstProposalId, ) = dao.createProposal("A");
        (uint256 secondProposalId, ) = dao.createProposal("B");
        vm.stopPrank();

        assertEq(firstProposalId, 1);
        assertEq(secondProposalId, 2);
    }

    function test_CreateProposal_RevertWhenCallerIsNotOwner() external {
        vm.prank(ATTACKER);
        vm.expectRevert(
            abi.encodeWithSelector(
                Ownable.OwnableUnauthorizedAccount.selector,
                ATTACKER
            )
        );
        dao.createProposal("X");
    }

    function test_Vote_IncrementsVotesFor() external {
        vm.prank(OWNER);
        (uint256 proposalId, address nftAddress) = dao.createProposal("P1");

        vm.prank(REDEEMER);
        uint256 tokenId = GovernanceNFT(nftAddress).safeMint(USER_1);

        vm.prank(USER_1);
        dao.vote(proposalId, tokenId, true);

        (, uint256 votesFor, uint256 votesAgainst, , , ) = dao.getProposal(
            proposalId
        );
        assertEq(votesFor, 1);
        assertEq(votesAgainst, 0);
    }

    function test_Vote_IncrementsVotesAgainst() external {
        vm.prank(OWNER);
        (uint256 proposalId, address nftAddress) = dao.createProposal("P1");

        vm.prank(REDEEMER);
        uint256 tokenId = GovernanceNFT(nftAddress).safeMint(USER_1);

        vm.prank(USER_1);
        dao.vote(proposalId, tokenId, false);

        (, uint256 votesFor, uint256 votesAgainst, , , ) = dao.getProposal(
            proposalId
        );
        assertEq(votesFor, 0);
        assertEq(votesAgainst, 1);
    }

    function test_Vote_RevertWhenProposalDoesNotExist() external {
        vm.prank(USER_1);
        vm.expectRevert(
            abi.encodeWithSelector(ProposalDoesNotExist.selector, 999)
        );
        dao.vote(999, 1, true);
    }

    function test_Vote_RevertWhenCallerIsNotNftOwner() external {
        vm.prank(OWNER);
        (uint256 proposalId, address nftAddress) = dao.createProposal("P1");

        vm.prank(REDEEMER);
        uint256 tokenId = GovernanceNFT(nftAddress).safeMint(USER_1);

        vm.prank(ATTACKER);
        vm.expectRevert(
            abi.encodeWithSelector(NotNFTOwner.selector, ATTACKER, tokenId)
        );
        dao.vote(proposalId, tokenId, true);
    }

    function test_Vote_RevertWhenNftAlreadyUsed() external {
        vm.prank(OWNER);
        (uint256 proposalId, address nftAddress) = dao.createProposal("P1");

        vm.prank(REDEEMER);
        uint256 tokenId = GovernanceNFT(nftAddress).safeMint(USER_1);

        vm.prank(USER_1);
        dao.vote(proposalId, tokenId, true);

        vm.prank(USER_1);
        vm.expectRevert(
            abi.encodeWithSelector(NFTAlreadyUsed.selector, tokenId)
        );
        dao.vote(proposalId, tokenId, false);
    }

    function test_Vote_RevertWhenVotingClosed() external {
        vm.prank(OWNER);
        (uint256 proposalId, address nftAddress) = dao.createProposal("P1");

        vm.prank(REDEEMER);
        uint256 tokenId = GovernanceNFT(nftAddress).safeMint(USER_1);

        vm.prank(OWNER);
        dao.closeProposal(proposalId);

        vm.prank(USER_1);
        vm.expectRevert(
            abi.encodeWithSelector(VotingClosed.selector, proposalId)
        );
        dao.vote(proposalId, tokenId, true);
    }

    function test_CloseProposal_SetsEndTime() external {
        vm.prank(OWNER);
        (uint256 proposalId, ) = dao.createProposal("P1");

        vm.prank(OWNER);
        dao.closeProposal(proposalId);

        (, , , , uint256 endTime, ) = dao.getProposal(proposalId);
        assertTrue(endTime > 0);
    }

    function test_CloseProposal_RevertWhenProposalDoesNotExist() external {
        vm.prank(OWNER);
        vm.expectRevert(
            abi.encodeWithSelector(ProposalDoesNotExist.selector, 999)
        );
        dao.closeProposal(999);
    }

    function test_CloseProposal_RevertWhenAlreadyClosed() external {
        vm.prank(OWNER);
        (uint256 proposalId, ) = dao.createProposal("P1");

        vm.startPrank(OWNER);
        dao.closeProposal(proposalId);
        vm.expectRevert(
            abi.encodeWithSelector(VotingClosed.selector, proposalId)
        );
        dao.closeProposal(proposalId);
        vm.stopPrank();
    }

    function test_CloseProposal_RevertWhenCallerIsNotOwner() external {
        vm.prank(OWNER);
        (uint256 proposalId, ) = dao.createProposal("P1");

        vm.prank(ATTACKER);
        vm.expectRevert(
            abi.encodeWithSelector(
                Ownable.OwnableUnauthorizedAccount.selector,
                ATTACKER
            )
        );
        dao.closeProposal(proposalId);
    }

    function test_Vote_RevertWhenProposalNftDoesNotExist() external {
        MockProposalNft mockNft = new MockProposalNft(1);
        MockGovernanceNFTFactory mockFactory = new MockGovernanceNFTFactory(
            address(mockNft)
        );

        vm.prank(OWNER);
        GovernanceDAO daoWithMockFactory = new GovernanceDAO(
            address(mockFactory),
            REDEEMER
        );

        vm.prank(OWNER);
        daoWithMockFactory.createProposal("P1");

        mockFactory.setReturnZeroInGet(true);

        vm.prank(USER_1);
        vm.expectRevert(
            abi.encodeWithSelector(ProposalNftDoesNotExist.selector, 1)
        );
        daoWithMockFactory.vote(1, 1, true);
    }

    function test_Vote_RevertWhenNftNotValidForProposal() external {
        MockProposalNft mockNft = new MockProposalNft(999);
        MockGovernanceNFTFactory mockFactory = new MockGovernanceNFTFactory(
            address(mockNft)
        );

        vm.prank(OWNER);
        GovernanceDAO daoWithMockFactory = new GovernanceDAO(
            address(mockFactory),
            REDEEMER
        );

        vm.prank(OWNER);
        daoWithMockFactory.createProposal("P1");

        mockNft.setOwnerOf(5, USER_1);

        vm.prank(USER_1);
        vm.expectRevert(
            abi.encodeWithSelector(NFTNotValidForProposal.selector, 5, 1)
        );
        daoWithMockFactory.vote(1, 5, true);
    }
}
