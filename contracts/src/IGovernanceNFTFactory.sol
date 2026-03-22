// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

interface IGovernanceNFTFactory {
    function createGovernanceNFT(uint256 _proposalId) external returns (address);
    function getNFTByProposal(uint256 proposalId) external view returns (address);
}
