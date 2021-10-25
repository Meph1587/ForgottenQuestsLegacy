//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;

contract StorageMock {
    constructor() {}

    mapping(uint256 => uint16[]) affinities;
    mapping(uint256 => uint16[]) traits;
    mapping(uint16 => uint16[]) affinitiesForTraits;
    mapping(uint16 => uint256) occurrence;
    mapping(uint256 => bool) hasStored;

    function hasTraitsStored(uint256 wizardId) public view returns (bool) {
        return hasStored[wizardId];
    }

    function setStored(uint256 wizardId) public {
        hasStored[wizardId] = true;
    }

    function getWizardName(uint256 wizardId)
        public
        view
        returns (string memory)
    {
        return "A Wizard Name";
    }

    function wizardHasTrait(uint256 wizardId, uint16 trait)
        public
        view
        returns (bool)
    {
        for (uint8 i = 0; i < traits[wizardId].length; i++) {
            if (trait == traits[wizardId][i]) {
                return true;
            }
        }
        return false;
    }

    function storeAffinityForWiz(uint256 wizardId, uint16 affinity) public {
        affinities[wizardId].push(affinity);
    }

    function storeTraitForWiz(uint256 wizardId, uint16 trait) public {
        traits[wizardId].push(trait);
    }

    function storeOccurrence(uint16 affId, uint256 occ) public {
        occurrence[affId] = occ;
    }

    function storeAffinityForTrait(uint16 trait, uint16 affinity) public {
        affinitiesForTraits[trait].push(affinity);
    }

    function getAllTraitsAffinities(uint16[5] memory traits)
        public
        view
        returns (uint16[] memory)
    {
        return affinitiesForTraits[traits[0]];
    }

    function getAffinityOccurrences(uint16 affinity)
        public
        view
        returns (uint256)
    {
        if (occurrence[affinity] != 0) {
            return occurrence[affinity];
        } else {
            return 200;
        }
    }

    function getWizardAffinities(uint256 wizardId)
        public
        view
        returns (uint16[] memory)
    {
        return affinities[wizardId];
    }
}
