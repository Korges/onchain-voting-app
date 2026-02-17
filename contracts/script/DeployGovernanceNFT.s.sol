// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Script} from "forge-std/Script.sol";
import {GovernanceNFT} from "../src/GovernanceNft.sol";

contract DeployGovernanceNFT is Script {
    function run() external returns (GovernanceNFT) {
        vm.startBroadcast();
        GovernanceNFT governanceNft = new GovernanceNFT();
        vm.stopBroadcast();
        return governanceNft;
    }
}
