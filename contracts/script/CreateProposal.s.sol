// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Script} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {GovernanceDAO} from "../src/GovernanceDAO.sol";

contract CreateProposal is Script {
    function run() external {
        address daoAddress = DevOpsTools.get_most_recent_deployment(
            "GovernanceDAO",
            block.chainid
        );

        GovernanceDAO dao = GovernanceDAO(daoAddress);

        string memory description = "Add new feature X";

        vm.startBroadcast();
        dao.createProposal(description);
        vm.stopBroadcast();
    }
}
