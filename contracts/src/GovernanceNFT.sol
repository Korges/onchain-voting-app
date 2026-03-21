// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract GovernanceNFT is ERC721, Ownable {
  bool private initialized;

    uint256 private s_tokenCounter;
    uint256 private s_proposalId;

    event GovernanceNftMinted(address indexed to, uint256 indexed tokenId);

    /*//////////////////////////////////////////////////////////////
                              CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor() ERC721("GovernanceNFT", "GT") Ownable(msg.sender) {}

    /*//////////////////////////////////////////////////////////////
                            PUBLIC FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function initialize(uint256 _proposalId, address owner_) external {
        require(!initialized, "Already initialized");
        initialized = true;

        _transferOwnership(owner_);

        s_proposalId = _proposalId;
    }

    function safeMint(address to) public onlyOwner returns (uint256 tokenId) {
        tokenId = s_tokenCounter++;
        _safeMint(to, tokenId);

        emit GovernanceNftMinted(to, tokenId);
    }

    /*//////////////////////////////////////////////////////////////
                             VIEW FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function getTokenCounter() external view returns (uint256) {
        return s_tokenCounter;
    }
}
