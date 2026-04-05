// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Script} from "forge-std/Script.sol";
import {GovernanceDAO} from "../src/GovernanceDAO.sol";
import {DevOpsTools} from "../lib/foundry-devops/src/DevOpsTools.sol";

contract DeployGovernanceDAO is Script {
    function deploy(
        address governanceNftFactoryAddress,
        address governanceNFTRedeemerAddress
    ) public returns (GovernanceDAO dao) {
        vm.startBroadcast();

        dao = new GovernanceDAO(
            governanceNftFactoryAddress,
            governanceNFTRedeemerAddress
        );

        vm.stopBroadcast();
    }

    function run() external returns (GovernanceDAO dao) {
        address governanceNftFactoryAddress = DevOpsTools
            .get_most_recent_deployment("GovernanceNFTFactory", block.chainid);
        address governanceNFTRedeemerAddress = DevOpsTools
            .get_most_recent_deployment("GovernanceNFTRedeemer", block.chainid);

        dao = deploy(governanceNftFactoryAddress, governanceNFTRedeemerAddress);
    }
}
