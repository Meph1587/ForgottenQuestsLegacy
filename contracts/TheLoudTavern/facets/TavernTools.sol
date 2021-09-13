//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "lost-grimoire/contracts/Grimoire.sol";
import "../libraries/LibOwnership.sol";
import "../libraries/LibTavernStorage.sol";

contract TavernTools {
    using SafeMath for uint256;

    //receive() external payable {}

    // executed only once
    function initialize(
        address _weth,
        address _wizardStorage,
        address _wizards
    ) public {
        require(_weth != address(0), "WETH must not be 0x0");

        LibTavernStorage.Storage storage ts = LibTavernStorage.tavernStorage();

        require(!ts.initialized, "LoudTavern: already initialized");
        LibOwnership.enforceIsContractOwner();

        ts.initialized = true;

        ts.weth = ERC20(_weth);
        ts.wizardStorage = Grimoire(_wizardStorage);
        ts.wizards = ERC721(_wizards);
    }

    function getRandomAffinity(uint256 _nonce) public view returns (uint16) {
        uint256 bigNr = uint256(
            keccak256(
                abi.encodePacked(
                    blockhash(block.number.sub(1)),
                    tx.origin,
                    _nonce,
                    block.difficulty
                )
            )
        );
        //overflow can not happen here
        uint16 aff = uint16(bigNr % 340);
        return aff;
    }

    function getRandomTrait(uint256 _nonce) public view returns (uint16) {
        uint256 bigNr = uint256(
            keccak256(
                abi.encodePacked(
                    _nonce,
                    tx.origin,
                    block.difficulty,
                    blockhash(block.number.sub(1))
                )
            )
        );
        //overflow can not happen here
        uint16 aff = uint16(bigNr % 286);
        return aff;
    }
}
