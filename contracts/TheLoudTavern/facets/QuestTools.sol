//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "lost-grimoire/contracts/Grimoire.sol";
import "../libraries/LibOwnership.sol";
import "../libraries/LibTavernStorage.sol";

contract QuestTools {
    using SafeMath for uint256;

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

    function getRandomAffinityFromTraits(
        uint256 nonce,
        uint16[5] memory traitIds
    ) public view returns (uint16) {
        LibTavernStorage.Storage storage ts = LibTavernStorage.tavernStorage();

        uint16[] calldata affinities = ts.wizardStorage.getAllTraitsAffinities(
            traitIds
        );

        uint256 bigNr = uint256(
            keccak256(
                abi.encodePacked(
                    blockhash(block.number.sub(1)),
                    tx.origin,
                    nonce,
                    block.difficulty
                )
            )
        );
        //overflow can not happen here
        uint16 aff = uint16(bigNr % affinities.length);
        return affinities[aff];
    }

    function getRandomTrait(uint256 nonce) public view returns (uint16) {
        uint256 bigNr = uint256(
            keccak256(
                abi.encodePacked(
                    nonce,
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

    function wizardHasOneOfTraits(uint256 wizardId, uint16[] memory traitIds)
        public
        view
        returns (bool)
    {
        LibTavernStorage.Storage storage ws = LibTavernStorage
            .tavernStorage()
            .wizardStorage;
        for (uint8 i = 0; i < traitIds.length; i++) {
            if (ws.wizardHasTrait(wizardId, i)) {
                return true;
            }
        }
        return false;
    }

    function getQuestDuration(
        uint256 wizardId,
        uint16[2] memory pos_affinities,
        uint16[2] memory neg_affinities
    ) public view returns (uint256) {
        LibTavernStorage.Storage storage ts = LibTavernStorage.tavernStorage();

        require(
            ts.wizardStorage.hasTraitsStored(wizardId),
            "Wizard does not have traits stored"
        );

        uint16[] memory wizAffinities = ts.wizardStorage.getWizardAffinities(
            wizardId
        );

        // count how many times selected wizard has affinity
        uint256 affinityCountPositive = 0;
        for (uint8 i = 0; i < wizAffinities.length; i++) {
            if (
                (wizAffinities[i] == pos_affinities[0]) ||
                (wizAffinities[i] == pos_affinities[1])
            ) {
                affinityCountPositive += 1;
            }
        }

        uint256 affinityCountNegative = 0;
        for (uint8 i = 0; i < wizAffinities.length; i++) {
            if (
                (wizAffinities[i] == neg_affinities[0]) ||
                (wizAffinities[i] == neg_affinities[1])
            ) {
                affinityCountNegative += 1;
            }
        }

        require(
            affinityCountPositive > 0,
            "Wizard does not have required affinity"
        );

        // this is safe because affinityCount can not be greater then 5
        // reduce duration by 2 days for every positive affinity
        // increases duration by 2 days for every negative affinity
        return
            LibTavernStorage.BASE_DURATION -
            (affinityCountPositive).mul(LibTavernStorage.TIME_ADJUSTMENT) +
            (affinityCountNegative).mul(LibTavernStorage.TIME_ADJUSTMENT);
    }
}
