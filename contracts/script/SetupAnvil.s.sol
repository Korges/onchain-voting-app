// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Script, console} from "forge-std/Script.sol";
import {DeployGovernanceNFT} from "./DeployGovernanceNFT.s.sol";
import {DeployGovernanceNFTFactory} from "./DeployGovernanceNFTFactory.s.sol";
import {DeployMerkleClaim} from "./DeployMerkleClaim.s.sol";
import {DeployGovernanceDAO} from "./DeployGovernanceDAO.s.sol";
import {IGovernanceNFTFactory} from "../src/IGovernanceNFTFactory.sol";
import {GovernanceNFTFactory} from "../src/GovernanceNFTFactory.sol";
import {MerkleClaim} from "../src/MerkleClaim.sol";
import {GovernanceDAO} from "../src/GovernanceDAO.sol";
import {GovernanceNFT} from "../src/GovernanceNFT.sol";
import {Vote} from "./Vote.s.sol";

contract SetupAnvil is Script {
    uint256 private constant CLAIMING_ADDRESS = 0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d;
    bytes32 private constant ROOT = 0xfe7020b2b0cf90904a691f560c99705d17df57a1bdf98f6a6b3b5158a8ec6d39;
    bytes32 private constant PROOF_ONE = 0xda9e9132aba100b00d62cefaa22ffc89e07ac5fde135acbfd021d5c3ee292495;
    bytes32 private constant PROOF_TWO = 0x28f1e4d0b47c6d6215f407906d687b29dea56d378287cd75f4522dad2b260a7e;
    bytes32 private constant PROOF_THREE = 0x0498b792f92b8d02b20e8dd943360964a58a230a8e506cc0a20db66a1dc226e5;
    bytes32 private constant PROOF_FOUR = 0x768e513bd6f348de1f66c42a029209c19f4a85fa5313443313fb7c84dcdbbce8;

    bytes32[] private proof = [PROOF_ONE, PROOF_TWO, PROOF_THREE, PROOF_FOUR];

    DeployGovernanceNFT deployGovernanceNFT;
    DeployGovernanceNFTFactory deployGovernanceNFTFactory;
    DeployMerkleClaim deployMerkleClaim;
    DeployGovernanceDAO deployGovernanceDAO;
    Vote vote;

    function run() external {
        deployGovernanceNFT = new DeployGovernanceNFT();
        deployGovernanceNFTFactory = new DeployGovernanceNFTFactory();
        deployMerkleClaim = new DeployMerkleClaim();
        deployGovernanceDAO = new DeployGovernanceDAO();
        vote = new Vote();

        address governanceNft = address(deployGovernanceNFT.run());
        console.log("GovernanceNFT deployed at:", governanceNft);

        address governanceNftFactory = address(deployGovernanceNFTFactory.deploy(governanceNft));
        console.log("GovernanceNFTFactory deployed at:", governanceNftFactory);

        address merkleClaim = address(deployMerkleClaim.deploy(governanceNftFactory));
        console.log("MerkleClaim deployed at:", merkleClaim);

        address dao = address(deployGovernanceDAO.deploy(governanceNftFactory, merkleClaim));
        console.log("GovernanceDAO deployed at:", dao);

        vm.startBroadcast();

        // Transfer factory ownership to DAO so it can create NFTs per proposal
        GovernanceNFTFactory(governanceNftFactory).transferOwnership(dao);

        address proposal_1 =
            GovernanceDAO(dao).createProposal("Proposal 1: Should we adopt the new on-chain voting mechanism?");

        MerkleClaim(merkleClaim).setMerkleRoot(1, ROOT);

        vm.stopBroadcast();

        vm.startBroadcast(CLAIMING_ADDRESS);

        uint256 tokenId = MerkleClaim(merkleClaim).claim(1, "7d2f9dcd244a2304", proof);
        GovernanceDAO(dao).vote(1, tokenId, false);

        vm.stopBroadcast();

        console.log("Token ID:", tokenId);
    }
}
