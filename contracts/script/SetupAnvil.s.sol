// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Script, console} from "forge-std/Script.sol";
import {DeployGovernanceNFT} from "./DeployGovernanceNFT.s.sol";
import {DeployGovernanceNFTFactory} from "./DeployGovernanceNFTFactory.s.sol";
import {DeployClaimTicket} from "./DeployClaimTicket.s.sol";
import {DeployGovernanceNFTRedeemer} from "./DeployGovernanceNFTRedeemer.s.sol";
import {DeployGovernanceDAO} from "./DeployGovernanceDAO.s.sol";
import {GovernanceNFTFactory} from "../src/GovernanceNFTFactory.sol";
import {ClaimTicket} from "../src/ClaimTicket.sol";
import {GovernanceDAO} from "../src/GovernanceDAO.sol";
import {GovernanceNFTRedeemer} from "../src/GovernanceNFTRedeemer.sol";

contract SetupAnvil is Script {
    // Standard Anvil accounts derived from mnemonic:
    // "test test test test test test test test test test test junk"
    address constant ADMIN   = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;

    address constant VOTER_1 = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8;
    uint256 constant VOTER_1_KEY = 0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d;

    address constant VOTER_2 = 0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC;
    uint256 constant VOTER_2_KEY = 0x5de4111afa1a4b94908f83103eb1f1706367c2e68ca870fc3fb9a804cdab365a;

    address constant VOTER_3 = 0x90F79bf6EB2c4f870365E785982E1f101E93b906;
    uint256 constant VOTER_3_KEY = 0x7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6;

    DeployGovernanceNFT deployGovernanceNFT;
    DeployGovernanceNFTFactory deployGovernanceNFTFactory;
    DeployClaimTicket deployClaimTicket;
    DeployGovernanceNFTRedeemer deployGovernanceNFTRedeemer;
    DeployGovernanceDAO deployGovernanceDAO;

    function run() external {
        deployGovernanceNFT = new DeployGovernanceNFT();
        deployGovernanceNFTFactory = new DeployGovernanceNFTFactory();
        deployClaimTicket = new DeployClaimTicket();
        deployGovernanceNFTRedeemer = new DeployGovernanceNFTRedeemer();
        deployGovernanceDAO = new DeployGovernanceDAO();

        // 1. Deploy core infrastructure
        address governanceNft = address(deployGovernanceNFT.run());
        console.log("GovernanceNFT (impl) deployed at:", governanceNft);

        address governanceNftFactory = address(
            deployGovernanceNFTFactory.deploy(governanceNft)
        );
        console.log("GovernanceNFTFactory deployed at:", governanceNftFactory);

        address claimTicket = address(deployClaimTicket.deploy());
        console.log("ClaimTicket deployed at:", claimTicket);

        address redeemer = address(
            deployGovernanceNFTRedeemer.deploy(claimTicket, governanceNftFactory)
        );
        console.log("GovernanceNFTRedeemer deployed at:", redeemer);

        address dao = address(
            deployGovernanceDAO.deploy(governanceNftFactory, redeemer)
        );
        console.log("GovernanceDAO deployed at:", dao);

        // 2. Wire up permissions + create proposal + distribute tickets (admin)
        vm.startBroadcast();

        // DAO needs to be factory owner so it can call createGovernanceNFT
        GovernanceNFTFactory(governanceNftFactory).transferOwnership(dao);

        // ClaimTicket needs to know who is allowed to burn tickets (the redeemer)
        ClaimTicket(claimTicket).setGovernanceNFTRedeemer(redeemer);

        // Create proposal #1 — clones a GovernanceNFT and transfers its ownership to the redeemer
        (uint256 proposalId, address proposalNft) = GovernanceDAO(dao).createProposal(
            "Proposal 1: Should we adopt the new on-chain voting mechanism?"
        );
        console.log("Proposal #", proposalId, " created with NFT at:", proposalNft);

        // Mint one ClaimTicket per voter for proposalId=1
        // ticketId: 1 -> admin, 2 -> voter1, 3 -> voter2, 4 -> voter3
        address[] memory recipients = new address[](4);
        recipients[0] = ADMIN;
        recipients[1] = VOTER_1;
        recipients[2] = VOTER_2;
        recipients[3] = VOTER_3;
        (uint256[] memory ticketIds) = ClaimTicket(claimTicket).mintBatch(recipients, proposalId);
        console.log("ClaimTickets minted (ticketId 1-4)");

        // Admin redeems ticket #1 -> receives GovernanceNFT tokenId=0
        GovernanceNFTRedeemer(redeemer).redeem(ticketIds[0]);
        console.log("Admin redeemed ticket #1 -> GovernanceNFT tokenId=0");

        vm.stopBroadcast();

        // 3. Voters redeem their tickets independently
        vm.startBroadcast(VOTER_1_KEY);
        GovernanceNFTRedeemer(redeemer).redeem(ticketIds[1]);
        console.log("Voter1 redeemed ticket #2 -> GovernanceNFT tokenId=1");
        vm.stopBroadcast();

        vm.startBroadcast(VOTER_2_KEY);
        GovernanceNFTRedeemer(redeemer).redeem(ticketIds[2]);
        console.log("Voter2 redeemed ticket #3 -> GovernanceNFT tokenId=2");
        vm.stopBroadcast();

        vm.startBroadcast(VOTER_3_KEY);
        GovernanceNFTRedeemer(redeemer).redeem(ticketIds[3]);
        console.log("Voter3 redeemed ticket #4 -> GovernanceNFT tokenId=3");
        vm.stopBroadcast();

        // 4. Summary
        console.log("");
        console.log("=== Setup complete. Ready to vote on proposalId=1 ===");
        console.log("Admin  (tokenId=0):", ADMIN);
        console.log("Voter1 (tokenId=1):", VOTER_1);
        console.log("Voter2 (tokenId=2):", VOTER_2);
        console.log("Voter3 (tokenId=3):", VOTER_3);
    }
}
