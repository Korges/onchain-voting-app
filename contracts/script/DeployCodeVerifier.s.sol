// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Script} from "forge-std/Script.sol";
import {CodeVerifier} from "../src/CodeVerifier.sol";
import {DevOpsTools} from "../lib/foundry-devops/src/DevOpsTools.sol";

contract DeployCodeVerifier is Script {
    function run() external returns (CodeVerifier codeVerifier) {
        vm.startBroadcast();

        codeVerifier = new CodeVerifier();

        vm.stopBroadcast();
    }
}
