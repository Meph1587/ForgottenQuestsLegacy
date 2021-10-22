//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./interfaces/Spells.sol";
import "wizard-storage/contracts/Grimoire.sol";

contract QuestTools {
    using SafeMath for uint256;

    uint256 public constant BASE_EXPIRATION = 604800; // 1 week
    uint256 public constant BASE_FEE = 20**16; //0.02 ETH
    uint256 public constant BASE_DURATION = 300; //1209600; // 2 weeks
    uint256 public constant TIME_ADJUSTMENT = 20; //86400; // 1 day
    uint256 public constant COOLDOWN = 120; //21600; //6 hours

    // a big one
    uint256 immutable BONE = uint256(10**18);

    bool initialized;
    Grimoire wizardStorage;
    ERC721 wizards;
    Spells spells;
    ERC20 weth;

    // executed only once
    function initialize(
        address _weth,
        address _spells,
        address _wizardStorage,
        address _wizards
    ) public {
        require(_weth != address(0), "WETH must not be 0x0");

        require(!initialized, "Tavern: already initialized");

        initialized = true;

        weth = ERC20(_weth);
        spells = Spells(_spells);
        wizardStorage = Grimoire(_wizardStorage);
        wizards = ERC721(_wizards);
    }

    function getWeth() public view returns (ERC20) {
        return weth;
    }

    function getSpells() public view returns (Spells) {
        return spells;
    }

    function getWizards() public view returns (ERC721) {
        return wizards;
    }

    function getGrimoire() public view returns (Grimoire) {
        return wizardStorage;
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
        uint16[] memory affinities = wizardStorage.getAllTraitsAffinities(
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

        for (uint8 i = 0; i < traitIds.length; i++) {
            if (
                wizardStorage.wizardHasTrait(wizardId, traitIds[i]) &&
                traitIds[i] != 7777
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
        uint256 scorePositive = uint256(
            wizardStorage.getAffinityOccurrences(positiveAffinities[0])
        ).add(wizardStorage.getAffinityOccurrences(positiveAffinities[1]));

        uint256 scoreNegative = uint256(
            wizardStorage.getAffinityOccurrences(negativeAffinities[0])
        ).add(wizardStorage.getAffinityOccurrences(negativeAffinities[1]));

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
        require(
            wizardStorage.hasTraitsStored(wizardId),
            "Wizard does not have traits stored"
        );

        uint16[] memory wizAffinities = wizardStorage.getWizardAffinities(
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
            BASE_DURATION -
            (affinityCountPositive).mul(TIME_ADJUSTMENT) +
            (affinityCountNegative).mul(TIME_ADJUSTMENT);
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

    function extractFromSVG(string base) public pure returns (string z) {}
}
