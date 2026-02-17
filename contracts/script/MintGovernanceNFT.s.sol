// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Script} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {GovernanceNFT} from "../src/GovernanceNft.sol";

contract MintGovernanceNFT is Script {
    function run() external {
        address nftAddress = DevOpsTools.get_most_recent_deployment(
            "GovernanceNFT",
            block.chainid
        );

        GovernanceNFT nft = GovernanceNFT(nftAddress);

        uint256 proposalId = 0;

        vm.startBroadcast();
        nft.mint(proposalId);
        vm.stopBroadcast();
    }
}
