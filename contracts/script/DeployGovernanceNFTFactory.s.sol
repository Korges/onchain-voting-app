// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Script} from "forge-std/Script.sol";
import {GovernanceNFTFactory} from "../src/GovernanceNFTFactory.sol";
import {DevOpsTools} from "../lib/foundry-devops/src/DevOpsTools.sol";

contract DeployGovernanceNFTFactory is Script {
    function deploy(address governanceNftAddress) public returns (GovernanceNFTFactory governanceNftFactory) {
        vm.startBroadcast();

        governanceNftFactory = new GovernanceNFTFactory(governanceNftAddress);

        vm.stopBroadcast();
    }

    function run() external returns (GovernanceNFTFactory governanceNftFactory) {
        address governanceNftAddress = DevOpsTools.get_most_recent_deployment("GovernanceNFT", block.chainid);

        governanceNftFactory = deploy(governanceNftAddress);
    }
}
