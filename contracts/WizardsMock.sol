pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

// Base ERC721 mocking Wizards for testing
contract Wizards is ERC721("WIZARDS", "WIZARDS") {
    constructor() {}

    function mint(address to, uint256 tokenId) public {
        super._safeMint(to, tokenId);
    }
}
