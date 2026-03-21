// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Script} from "forge-std/Script.sol";
import {GovernanceNFT} from "../src/GovernanceNft.sol";
import {DevOpsTools} from "../lib/foundry-devops/src/DevOpsTools.sol";

contract DeployGovernanceNFT is Script {
    function run() external returns (GovernanceNFT governanceNft) {
        vm.startBroadcast();

        governanceNft = new GovernanceNFT();

        vm.stopBroadcast();
    }
}
