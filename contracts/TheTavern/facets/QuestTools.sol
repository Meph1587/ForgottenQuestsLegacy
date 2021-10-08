//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "wizard-storage/contracts/Grimoire.sol";
import "../libraries/LibOwnership.sol";
import "../libraries/LibTavernStorage.sol";

contract QuestTools {
    using SafeMath for uint256;

    // a big one
    uint256 immutable BONE = uint256(10**18);

    // executed only once
    function initialize(
        address _weth,
        address _wizardStorage,
        address _wizards
    ) public {
        require(_weth != address(0), "WETH must not be 0x0");

        LibTavernStorage.Storage storage ts = LibTavernStorage.tavernStorage();

        require(!ts.initialized, "Tavern: already initialized");
        LibOwnership.enforceIsContractOwner();

        ts.initialized = true;

        ts.weth = ERC20(_weth);
        ts.wizardStorage = Grimoire(_wizardStorage);
        ts.wizards = ERC721(_wizards);
    }

    function getWeth() public view returns (address) {
        LibTavernStorage.Storage storage ts = LibTavernStorage.tavernStorage();

        return address(ts.weth);
    }

    function getWizards() public view returns (address) {
        LibTavernStorage.Storage storage ts = LibTavernStorage.tavernStorage();

        return address(ts.wizards);
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
        uint16 aff = uint16(bigNr % 341);
        return aff;
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
        uint16 aff = uint16(bigNr % 286);
        return aff;
    }

    function getRandomAffinityFromTraits(
        uint256 nonce,
        uint16[5] memory traitIds
    ) public view returns (uint16) {
        LibTavernStorage.Storage storage ts = LibTavernStorage.tavernStorage();

        uint16[] memory affinities = ts.wizardStorage.getAllTraitsAffinities(
            traitIds
        );

        //in case [7777, 7777, 7777, 7777, 7777] is provided
        if (affinities.length == 0) {
            return getRandomAffinity(nonce);
        }

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

    function wizardHasOneOfTraits(uint256 wizardId, uint16[5] memory traitIds)
        public
        view
        returns (bool)
    {
        //exit if required traits is empty
        if (
            traitIds[0] == 7777 &&
            traitIds[1] == 7777 &&
            traitIds[2] == 7777 &&
            traitIds[3] == 7777 &&
            traitIds[4] == 7777
        ) {
            return true;
        }

        Grimoire ws = LibTavernStorage.tavernStorage().wizardStorage;
        for (uint8 i = 0; i < traitIds.length; i++) {
            if (
                ws.wizardHasTrait(wizardId, traitIds[i]) && traitIds[i] != 7777
            ) {
                return true;
            }
        }
        return false;
    }

    function getQuestScore(
        uint16[2] memory positiveAffinities,
        uint16[2] memory negativeAffinities
    ) public view returns (uint256) {
        LibTavernStorage.Storage storage ts = LibTavernStorage.tavernStorage();
        uint256 scorePositive = uint256(
            ts.wizardStorage.getAffinityOccurrences(positiveAffinities[0])
        ).add(ts.wizardStorage.getAffinityOccurrences(positiveAffinities[1]));

        uint256 scoreNegative = uint256(
            ts.wizardStorage.getAffinityOccurrences(negativeAffinities[0])
        ).add(ts.wizardStorage.getAffinityOccurrences(negativeAffinities[1]));

        uint256 score = sqrt(
            scoreNegative.mul(BONE.mul(100000).div(scorePositive)).div(BONE)
        );

        return score;
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
            if (wizAffinities[i] == pos_affinities[0]) {
                affinityCountPositive += 1;
            }

            if (wizAffinities[i] == pos_affinities[1]) {
                affinityCountPositive += 1;
            }
        }

        uint256 affinityCountNegative = 0;
        for (uint8 i = 0; i < wizAffinities.length; i++) {
            if (wizAffinities[i] == neg_affinities[0]) {
                affinityCountNegative += 1;
            }
            if (wizAffinities[i] == neg_affinities[1]) {
                affinityCountNegative += 1;
            }
        }

        // require(
        //     affinityCountPositive > 0,
        //     "Wizard does not have required affinity"
        // );

        // this is safe because affinityCount can not be greater then 5
        // reduce duration by 2 days for every positive affinity
        // increases duration by 2 days for every negative affinity
        return
            LibTavernStorage.BASE_DURATION -
            (affinityCountPositive).mul(LibTavernStorage.TIME_ADJUSTMENT) +
            (affinityCountNegative).mul(LibTavernStorage.TIME_ADJUSTMENT);
    }

    // babylonian method (https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method)
    function sqrt(uint256 y) public pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}
