// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract GovernanceNFT is ERC721, Ownable {
    uint256 private s_tokenCounter;
    mapping(uint256 => uint256) public s_proposalOf;

    event GovernanceNftMinted(
        address indexed to,
        uint256 indexed tokenId,
        uint256 indexed proposalId
    );

    /*//////////////////////////////////////////////////////////////
                              CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor() ERC721("Governance Token", "GT") Ownable(msg.sender) {}

    /*//////////////////////////////////////////////////////////////
                            PUBLIC FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function mint(
        uint256 proposalId
    ) external onlyOwner returns (uint256 tokenId) {
        tokenId = s_tokenCounter;
        s_proposalOf[tokenId] = proposalId;

        _safeMint(msg.sender, tokenId);
        s_tokenCounter++;

        emit GovernanceNftMinted(msg.sender, tokenId, proposalId);
    }

    /*//////////////////////////////////////////////////////////////
                             VIEW FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function getProposalId(
        uint256 tokenId
    ) external view returns (uint256) {
        require(_ownerOf(tokenId) != address(0), "Token does not exist");
        return s_proposalOf[tokenId];
    }

    function getTokenCounter() external view returns (uint256) {
        return s_tokenCounter;
    }
}
