// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Script, console2} from "forge-std/Script.sol";
import {GovernanceDAO} from "../src/GovernanceDAO.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";

contract GetProposalResult is Script {
    function run(uint256 proposalId) external view {
        address daoAddress = DevOpsTools.get_most_recent_deployment("GovernanceDAO", block.chainid);
        GovernanceDAO dao = GovernanceDAO(daoAddress);

        (
            string memory description,
            uint256 yesVotes,
            uint256 noVotes,
            uint256 startTime,
            uint256 endTime,
            bool exists
        ) = dao.getProposal(proposalId);

        console2.log("Proposal ID:", proposalId);
        console2.log("Description:", description);
        console2.log("Yes votes:", yesVotes);
        console2.log("No votes:", noVotes);
        console2.log("Active:", exists);
        console2.log("Start time:", startTime);
        console2.log("End time:", endTime);
    }
}
