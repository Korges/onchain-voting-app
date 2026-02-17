// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Script} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {GovernanceDAO} from "../src/GovernanceDAO.sol";

contract Vote is Script {
    function run(uint256 proposalId, uint256 tokenId, bool support) external {
        address daoAddress = DevOpsTools.get_most_recent_deployment(
            "GovernanceDAO",
            block.chainid
        );

        GovernanceDAO dao = GovernanceDAO(daoAddress);

        vm.startBroadcast();
        dao.vote(proposalId, tokenId, support);
        vm.stopBroadcast();
    }
}
