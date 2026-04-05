// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Script} from "forge-std/Script.sol";
import {ClaimTicket} from "../src/ClaimTicket.sol";
import {DevOpsTools} from "../lib/foundry-devops/src/DevOpsTools.sol";

contract DeployClaimTicket is Script {
    function deploy() public returns (ClaimTicket claimTicket) {
        vm.startBroadcast();

        claimTicket = new ClaimTicket();

        vm.stopBroadcast();
    }

    function run() external returns (ClaimTicket claimTicket) {
        claimTicket = deploy();
    }
}
