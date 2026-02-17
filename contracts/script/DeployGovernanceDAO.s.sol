// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Script} from "forge-std/Script.sol";
import {GovernanceDAO} from "../src/GovernanceDAO.sol";
import {GovernanceNFT} from "../src/GovernanceNft.sol";
import {DevOpsTools} from "../lib/foundry-devops/src/DevOpsTools.sol";

contract DeployGovernanceDAO is Script {
    function run() external returns (GovernanceDAO dao) {
        address governanceNftAddress = DevOpsTools.get_most_recent_deployment("GovernanceNFT", block.chainid);

        vm.startBroadcast();

        dao = new GovernanceDAO(governanceNftAddress);

        vm.stopBroadcast();
    }
}
