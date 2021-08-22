pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

// Base ERC721 mocking Wizards for testing
contract RewardNFT is ERC721("REWARDS", "REWARDS") {
    constructor() {}

    function mint(
        address to,
        uint256 tokenId,
        uint256 wizardId,
        string calldata story,
        uint16 affinity,
        uint256 duration
    ) public {
        super._safeMint(to, tokenId);
    }
}
