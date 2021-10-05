//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.7;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./libraries/stringsutils.sol";

contract QuestAchievements is ERC721Enumerable, Ownable {
    using stringsutils for string;

    string[] private locations = [
        " at The Alchemists Archipelago",
        " at The Salt",
        " at The Red Wizard Keep",
        " at The Calista's Citadel",
        " at The Omega Oxbow",
        " at The Brine",
        " at The Weird House",
        " at The Scared Tower",
        " at The Skylord Rookery",
        " at Alessar's Keep",
        " at Aldo's Island",
        " at Asmodeus's Surf",
        " at The Kobold's Crossroad",
        " at The Sacred Pillars",
        " at The Gate to the Seventh Realm",
        " at The Dream Master Lake",
        " at The Fur Gnome World",
        " at The Hedge Wizard Wood",
        " at Kelpie's Bay",
        " at Chronomancer's Riviera",
        " at The Blue Wizard Bastion",
        " at The Carnival Pass",
        " at The Frog Master Marsh",
        " at The Goblin Town",
        " at The BattleMage Mountains",
        " at The Yellow Wizard Haven",
        " at Atlanta's Pool",
        " at The Infinity Veild",
        " at The Fey",
        " at The Thorn",
        " at The Quantum Shadow",
        " at The Great Owl Obelisk",
        " at The Sand",
        " at The Zaros Oasis",
        " at The Cave of the Platonic Shadow",
        " at The Valley of the Void Disciple",
        " at The Vampyre Mist",
        " at The Toadstool",
        " at The Hue Master's Pass",
        " at The Cuckoo Land",
        " at The Psychic Leap"
    ];

    string[] private actions = [
        "The Rescue of ",
        "A Rescue for ",
        "A Discovery for ",
        "A Battle with ",
        "A Battle for ",
        "An Intreague with ",
        "The Betreyal of ",
        "An Arrangement with ",
        "An Arrangement for ",
        "The Assault against ",
        "The Escape with ",
        "The Escape from ",
        "A Delivery for ",
        "A Delivery from ",
        "A Hunt for ",
        "A Hunt with ",
        "The Hunt of ",
        "A Negotiation with ",
        "An Analysis for ",
        "A Distraction of ",
        "The Protection of ",
        "A Purchase from ",
        "A Purchase for ",
        "A Theft for ",
        "A Theft from ",
        "A Blackmail of ",
        "A Blackmail for ",
        "The Murder of ",
        "A Murder for ",
        "To The Aid of ",
        "The Saving of ",
        "An Espionage of ",
        "An Espionage for "
    ];

    string[] private names = [
        "Cronus",
        "Merlin",
        "Sharkey",
        "Mephistopheles",
        "Aleister Crowley",
        "Katherine",
        "Zubin",
        "Nikolas",
        "Zaros",
        "Zelroth",
        "Jeldor",
        "Azahl",
        "Udor",
        "Andy",
        "Bernardo",
        "Braindraind",
        "Andolini",
        "Catherine",
        "Dwarzgarth",
        "Bringer",
        "Zagan",
        "Toby",
        "Pezo",
        "Apollo",
        "Vatar",
        "Vlad",
        "Ilu",
        "Damien",
        "Lupa",
        "Faustus",
        "Celah",
        "Louis",
        "Benito",
        "Rainman",
        "Alvaro",
        "Argus",
        "Twinkletoes",
        "Black Goat",
        "Abaddon",
        "Pepo",
        "Corvin",
        "Ixar",
        "Hu",
        "Victor",
        "Hongo",
        "Gwendolin",
        "Ravana",
        "Jasper",
        "Eliphas",
        "Norix",
        "Juniper",
        "Yan",
        "Kang",
        "Alice",
        "Bullock",
        "Yookoo",
        "Voidoth",
        "Willow",
        "Milo",
        "Karasu",
        "Oxnard",
        "Liliana",
        "Behemoth",
        "Brutus",
        "Jastor",
        "Elizabeth",
        "Izible",
        "Asmodeus",
        "JackDaw",
        "Lux",
        "Drusilla",
        "Talon",
        "Maia",
        "Robert",
        "Lavinia",
        "Peppy",
        "Florah",
        "Ursula",
        "Eronin",
        "Adium",
        "Samuel",
        "Delilah",
        "Beyna",
        "Tundror",
        "Hothor",
        "Shivra",
        "Velorina",
        "Circe",
        "Nadeem",
        "Ramiz",
        "Hagar",
        "Zelda",
        "Lamia",
        "Isaac",
        "Lenora",
        "Artis",
        "Axel",
        "Magnus",
        "Jahid",
        "Aslan",
        "Amir",
        "Eric",
        "Jerret",
        "Ozohr",
        "Zane",
        "Goliath",
        "Lumos",
        "Basil",
        "Alatar",
        "Cairon",
        "Oberon",
        "Aleister",
        "David",
        "Milton",
        "George",
        "Hue",
        "Iluzor",
        "Devo",
        "Lucifer",
        "Kobold",
        "Squiddly",
        "Stefan",
        "Prisma",
        "Charlie",
        "Drako",
        "Edward",
        "Shukri",
        "Vorvadoss",
        "Suc'Naath",
        "Anubis",
        "Fidget",
        "Devon",
        "Gee",
        "Dotta",
        "Virgil",
        "Ulthar",
        "Iris",
        "Kalo",
        "Aiko",
        "Soran",
        "Merlon",
        "Iprix",
        "Akron",
        "Embrose",
        "Orpheus",
        "Feng",
        "Mina",
        "Remus",
        "Jadis",
        "Rixxa",
        "Ulysse",
        "Froggy",
        "Davos",
        "Larissa",
        "Uur'lok",
        "Elmo",
        "Salvatore",
        "Oiq",
        "Huizhong",
        "Trollin",
        "Eizo",
        "Ariadne",
        "Thana",
        "Galatea",
        "Titania",
        "Sondra",
        "Astrid",
        "Asphodel",
        "Adrienne",
        "Rodolfo",
        "Althea",
        "Calliope",
        "Lin",
        "Sonja",
        "Nixie",
        "Daphne",
        "Stag",
        "Leah",
        "Kurama",
        "Celeste",
        "Diana",
        "Pumlo",
        "Alessar",
        "Faye",
        "Arabella",
        "Layla",
        "Peter",
        "Ghorhoth",
        "Takao",
        "Fallow",
        "Billy",
        "Hedgie",
        "Morfran",
        "Hydra",
        "Shabbith-Ka",
        "Meloogen",
        "Pus Mother",
        "Porto",
        "Hanataka",
        "Azathoth",
        "Jiang",
        "Rook",
        "Cullen",
        "Hank",
        "Shi",
        "Jay",
        "Shu",
        "Kryll",
        "Liu",
        "Ai",
        "Robin",
        "Morrow",
        "Ronald",
        "Chandler",
        "Finch",
        "Bane",
        "Zevi",
        "Enzo",
        "Shizu",
        "Zolona",
        "Sturgis",
        "Ratko",
        "Amanita",
        "Sabina",
        "Suki",
        "Hecate",
        "Imeena",
        "Nicolas",
        "Ivy",
        "Tumbaj",
        "Lilith",
        "Fungi"
    ];

    struct TokenData {
        string wizard;
        uint256 score;
        uint256 duration;
        string name;
    }

    mapping(uint256 => TokenData) tokenData;

    constructor() ERC721("WizardTrophies", "TROPHY") Ownable() {}

    function tokenURI(uint256 tokenId)
        public
        view
        override
        returns (string memory)
    {
        TokenData storage token = tokenData[tokenId];

        string[11] memory parts;
        parts[
            0
        ] = '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 500 500"><style>.base { fill: white; font-family: serif; font-size: 14px; }</style><rect width="100%" height="100%" fill="black" /><text x="10" y="20" class="base"> Quest Name: ';

        parts[1] = token.wizard;
        if (token.score > 1514) {
            parts[
                2
            ] = '</text><style>.diff {fill: orange}</style><text x="10" y="40" class="diff"> ';
            parts[3] = "Legendary";
        } else if (token.score > 601) {
            parts[
                2
            ] = '</text><style>.diff {fill: purple}</style><text x="10" y="40" class="diff"> ';
            parts[3] = "Epic";
        } else if (token.score > 179) {
            parts[
                2
            ] = '</text><style>.diff {fill: blue}</style><text x="10" y="40" class="diff"> ';
            parts[3] = "Hard";
        } else {
            parts[
                2
            ] = '</text><style>.diff {fill: gray}</style><text x="10" y="40" class="base"> ';
            parts[3] = "Easy";
        }

        parts[4] = '</text><text x="10" y="60" class="base"> Wizard: ';

        parts[5] = token.wizard;

        parts[6] = '</text><text x="10" y="80" class="base"> Score: ';

        parts[7] = toString(token.score);

        parts[8] = '</text><text x="10" y="100" class="base"> Duration: ';

        parts[9] = toString(token.duration / 86400);

        parts[10] = " days </text></svg>";

        string memory output = string(
            abi.encodePacked(
                parts[0],
                parts[1],
                parts[2],
                parts[3],
                parts[4],
                parts[5],
                parts[6],
                parts[7],
                parts[8],
                parts[9],
                parts[10]
            )
        );

        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "Quest #',
                        toString(tokenId),
                        '", "description": "Quest Achievements are records of heroic adventures acomplished by Wiarrds.", "attributes": [{"trait_type": "difficulty", "value": "',
                        parts[3],
                        '"}], "image": "data:image/svg+xml;base64,',
                        Base64.encode(bytes(output)),
                        '"}'
                    )
                )
            )
        );
        output = string(
            abi.encodePacked("data:application/json;base64,", json)
        );

        return output;
    }

    function mint(
        address to,
        uint256 questId,
        string memory wizard,
        uint256 score,
        uint256 duration
    ) public {
        tokenData[questId] = TokenData({
            wizard: wizard,
            score: score,
            duration: duration,
            name: getName(questId)
        });
        _safeMint(to, questId);
    }

    function mintWithName(
        string memory name,
        address to,
        uint256 questId,
        string memory wizard,
        uint256 score,
        uint256 duration
    ) public {
        tokenData[questId] = TokenData({
            wizard: wizard,
            score: score,
            duration: duration,
            name: name
        });
        _safeMint(to, questId);
    }

    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT license
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    function random(string memory input) internal pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked(input)));
    }

    function getName(uint256 tokenId) public view returns (string memory) {
        string[3] memory parts;
        parts[0] = pluck(tokenId, actions);
        parts[1] = pluck(tokenId, names);
        parts[2] = pluck(tokenId, locations);

        string memory output = string(
            abi.encodePacked(parts[0], parts[1], parts[2])
        );
        return output;
    }

    function pluck(uint256 tokenId, string[] memory sourceArray)
        internal
        pure
        returns (string memory)
    {
        uint256 rand = random(toString(tokenId));
        string memory output = sourceArray[rand % sourceArray.length];

        return output;
    }
}

/// [MIT License]
/// @title Base64
/// @notice Provides a function for encoding some bytes in base64
/// @author Brecht Devos <brecht@loopring.org>
library Base64 {
    bytes internal constant TABLE =
        "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

    /// @notice Encodes some bytes to the base64 representation
    function encode(bytes memory data) internal pure returns (string memory) {
        uint256 len = data.length;
        if (len == 0) return "";

        // multiply by 4/3 rounded up
        uint256 encodedLen = 4 * ((len + 2) / 3);

        // Add some extra buffer at the end
        bytes memory result = new bytes(encodedLen + 32);

        bytes memory table = TABLE;

        assembly {
            let tablePtr := add(table, 1)
            let resultPtr := add(result, 32)

            for {
                let i := 0
            } lt(i, len) {

            } {
                i := add(i, 3)
                let input := and(mload(add(data, i)), 0xffffff)

                let out := mload(add(tablePtr, and(shr(18, input), 0x3F)))
                out := shl(8, out)
                out := add(
                    out,
                    and(mload(add(tablePtr, and(shr(12, input), 0x3F))), 0xFF)
                )
                out := shl(8, out)
                out := add(
                    out,
                    and(mload(add(tablePtr, and(shr(6, input), 0x3F))), 0xFF)
                )
                out := shl(8, out)
                out := add(
                    out,
                    and(mload(add(tablePtr, and(input, 0x3F))), 0xFF)
                )
                out := shl(224, out)

                mstore(resultPtr, out)

                resultPtr := add(resultPtr, 4)
            }

            switch mod(len, 3)
            case 1 {
                mstore(sub(resultPtr, 2), shl(240, 0x3d3d))
            }
            case 2 {
                mstore(sub(resultPtr, 1), shl(248, 0x3d))
            }

            mstore(result, encodedLen)
        }

        return string(result);
    }
}
