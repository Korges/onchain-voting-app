// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Script} from "forge-std/Script.sol";
import {GovernanceNFTRedeemer} from "../src/GovernanceNFTRedeemer.sol";
import {DevOpsTools} from "../lib/foundry-devops/src/DevOpsTools.sol";

contract DeployGovernanceNFTRedeemer is Script {
    function deploy(
        address claimTicketAddress,
        address governanceNftFactoryAddress
    ) public returns (GovernanceNFTRedeemer redeemer) {
        vm.startBroadcast();

        redeemer = new GovernanceNFTRedeemer(
            claimTicketAddress,
            governanceNftFactoryAddress
        );

        vm.stopBroadcast();
    }

    function run() external returns (GovernanceNFTRedeemer redeemer) {
        address claimTicketAddress = DevOpsTools.get_most_recent_deployment(
            "ClaimTicket",
            block.chainid
        );
        address governanceNftFactoryAddress = DevOpsTools
            .get_most_recent_deployment("GovernanceNFTFactory", block.chainid);

        redeemer = deploy(claimTicketAddress, governanceNftFactoryAddress);
    }
}
