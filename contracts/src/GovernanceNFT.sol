// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {ERC721Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract GovernanceNFT is Initializable, ERC721Upgradeable, OwnableUpgradeable {
    /*//////////////////////////////////////////////////////////////
                                STORAGE
    //////////////////////////////////////////////////////////////*/

    uint256 private s_tokenCounter;
    uint256 private s_proposalId;

    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event GovernanceNftMinted(address indexed to, uint256 indexed tokenId);

    /*//////////////////////////////////////////////////////////////
                              CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor() {
        _disableInitializers();
    }

    /*//////////////////////////////////////////////////////////////
                              INITIALIZER
    //////////////////////////////////////////////////////////////*/

    function initialize(uint256 _proposalId, address owner_) external initializer {
        __ERC721_init("GovernanceNFT", "GT");
        __Ownable_init(owner_);

        s_proposalId = _proposalId;
    }

    /*//////////////////////////////////////////////////////////////
                            PUBLIC FUNCTIONS
    //////////////////////////////////////////////////////////////*/

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

    function getProposalId() external view returns (uint256) {
        return s_proposalId;
    }
}
