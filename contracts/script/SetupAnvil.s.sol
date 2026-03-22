// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Script, console} from "forge-std/Script.sol";
import {DeployGovernanceNFT} from "./DeployGovernanceNFT.s.sol";
import {DeployGovernanceNFTFactory} from "./DeployGovernanceNFTFactory.s.sol";
import {DeployMerkleClaim} from "./DeployMerkleClaim.s.sol";
import {IGovernanceNFTFactory} from "../src/IGovernanceNFTFactory.sol";

contract SetupAnvil is Script {
    DeployGovernanceNFT deployGovernanceNFT;
    DeployGovernanceNFTFactory deployGovernanceNFTFactory;
    DeployMerkleClaim deployMerkleClaim;

    function run() external {
        deployGovernanceNFT = new DeployGovernanceNFT();
        deployGovernanceNFTFactory = new DeployGovernanceNFTFactory();
        deployMerkleClaim = new DeployMerkleClaim();

        address governanceNft = address(deployGovernanceNFT.run());
        console.log("GovernanceNFT deployed at:", governanceNft);

        address governanceNftFactory = address(deployGovernanceNFTFactory.run());
        console.log("GovernanceNFTFactory deployed at:", governanceNftFactory);

        address merkleClaim = address(deployMerkleClaim.run());
        console.log("MerkleClaim deployed at:", merkleClaim);

        // Wywołanie createGovernanceNFT z proposalId = 1
        vm.startBroadcast();
        address clonedNFT = IGovernanceNFTFactory(governanceNftFactory).createGovernanceNFT(1);
        vm.stopBroadcast();
        console.log("Cloned GovernanceNFT for proposal 1 at:", clonedNFT);
    }
}
