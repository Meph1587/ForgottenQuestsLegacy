// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.7;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "wizard-storage/contracts/Grimoire.sol";

library LibTavernStorage {
    bytes32 constant STORAGE_POSITION = keccak256("abrahadabra");

    uint256 public constant BASE_EXPIRATION = 604800; // 1 week
    uint256 public constant BASE_FEE = 20**16; //0.02 ETH
    uint256 public constant BASE_DURATION = 1209600; //1209600; // 2 weeks
    uint256 public constant TIME_ADJUSTMENT = 86400; //86400; // 1 day
    uint256 public constant COOLDOWN = 21600; //21600; //6 hours

    struct Storage {
        bool initialized;
        Grimoire wizardStorage;
        ERC721 wizards;
        ERC20 weth;
    }

    function tavernStorage() internal pure returns (Storage storage ds) {
        bytes32 position = STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }
}
