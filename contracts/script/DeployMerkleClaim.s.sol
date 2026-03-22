// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Script} from "forge-std/Script.sol";
import {MerkleClaim} from "../src/MerkleClaim.sol";
import {DevOpsTools} from "../lib/foundry-devops/src/DevOpsTools.sol";

contract DeployMerkleClaim is Script {
    function run() external returns (MerkleClaim merkleClaim) {
        address governanceNftFactoryAddress =
            DevOpsTools.get_most_recent_deployment("GovernanceNFTFactory", block.chainid);

        vm.startBroadcast();

        merkleClaim = new MerkleClaim(governanceNftFactoryAddress);

        vm.stopBroadcast();
    }
}
