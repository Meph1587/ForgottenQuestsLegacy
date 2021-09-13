//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// Base ERC721 mocking Wizards for testing
contract BaseQuestRewardNFT is ERC721("REWARDS", "REWARDS"), Ownable {
    constructor() {}

    function mint(
        address to,
        uint256 tokenId,
        uint256 wizardId,
        string calldata story,
        uint16[2] memory affinity,
        uint256 duration
    ) public onlyOwner {
        super._safeMint(to, tokenId);
    }
}
