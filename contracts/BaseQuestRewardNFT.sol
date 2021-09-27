//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./libraries/stringsutils.sol";

contract BaseQuestRewardNFT is ERC721Enumerable, ReentrancyGuard, Ownable {
    using stringsutils for string;

    struct TokenData {
        string wizard;
        uint256 difficulty;
        uint256 duration;
    }

    mapping(uint256 => TokenData) tokenData;

    function tokenURI(uint256 tokenId)
        public
        view
        override
        returns (string memory)
    {}

    function mint(
        address to,
        uint256 questId,
        string memory wizard,
        uint256 difficulty,
        uint256 duration
    ) public nonReentrant {
        tokenData[questId] = TokenData({
            wizard: wizard,
            difficulty: difficulty,
            duration: duration
        });
        _safeMint(to, questId);
    }

    constructor() ERC721("WizardTrophies", "TROPHY") Ownable() {}
}
