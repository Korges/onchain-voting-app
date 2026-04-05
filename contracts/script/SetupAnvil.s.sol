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

contract SetupAnvil is Script {
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
            deployGovernanceNFTRedeemer.deploy(
                claimTicket,
                governanceNftFactory
            )
        );
        console.log("GovernanceNFTRedeemer deployed at:", redeemer);

        address dao = address(
            deployGovernanceDAO.deploy(governanceNftFactory, redeemer)
        );
        console.log("GovernanceDAO deployed at:", dao);

        vm.startBroadcast();

        // 2. Wire up permissions
        // DAO needs to be factory owner so it can create proposal NFTs
        GovernanceNFTFactory(governanceNftFactory).transferOwnership(dao);

        // ClaimTicket needs to know who is allowed to burn tickets (the redeemer)
        ClaimTicket(claimTicket).setGovernanceNFTRedeemer(redeemer);

        // 3. Create a proposal - this also clones a GovernanceNFT and gives ownership to the redeemer
        GovernanceDAO(dao).createProposal(
            "Proposal 1: Should we adopt the new on-chain voting mechanism?"
        );

        vm.stopBroadcast();
    }
}
