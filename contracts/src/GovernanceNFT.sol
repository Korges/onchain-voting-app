// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import "./CodeVerifier.sol";

contract GovernanceNFT is ERC721, Ownable {
    uint256 private s_tokenCounter;
    uint16 private immutable s_proposalId;

    CodeVerifier public verifier;

    event GovernanceNftMinted(address indexed to, uint256 indexed tokenId, uint256 indexed proposalId);

    /*//////////////////////////////////////////////////////////////
                              CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(uint16 proposalId) ERC721("Governance Token", "GT") Ownable(msg.sender) {
        s_proposalId = proposalId;
    }

    /*//////////////////////////////////////////////////////////////
                            PUBLIC FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function safeMint() public onlyOwner returns (uint256 tokenId) {
        uint256 tokenId = s_tokenCounter++;
        _safeMint(msg.sender, tokenId);

        emit GovernanceNftMinted(msg.sender, tokenId, s_proposalId);
    }

    /*//////////////////////////////////////////////////////////////
                             VIEW FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function getProposalId() external view returns (uint256) {
        return s_proposalId;
    }

    function getTokenCounter() external view returns (uint256) {
        return s_tokenCounter;
    }
}
