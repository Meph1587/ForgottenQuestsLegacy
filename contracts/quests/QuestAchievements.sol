//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.7;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../libraries/stringsutils.sol";
import "../libraries/Base64.sol";

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
        "An Espionage for ",
        "An Initiation with ",
        "Entertainment for "
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
        "Shizu",
        "Zolona",
        "Sturgis",
        "Ratko",
        "Amanita",
        "Suki",
        "Hecate",
        "Imeena",
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
        uint8 symbol;
    }

    mapping(uint256 => TokenData) public tokenData;
    mapping(address => bool) public allowedMinterContracts;

    modifier onlyMinter() {
        require(
            allowedMinterContracts[msg.sender] == true,
            "Not allowed to mint"
        );
        _;
    }

    constructor() ERC721("QuestAchievements", "ACHIEVEMENTS") Ownable() {}

    function setMintingAllowance(address quest, bool val) public onlyOwner {
        allowedMinterContracts[quest] = val;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override
        returns (string memory)
    {
        string[14] memory parts;

        parts[0] = tokenData[tokenId].name;

        if (tokenData[tokenId].score > 1514) {
            parts[1] = "Legendary";
        } else if (tokenData[tokenId].score > 601) {
            parts[1] = "Epic";
        } else if (tokenData[tokenId].score > 179) {
            parts[1] = "Hard";
        } else {
            parts[1] = "Easy";
        }

        parts[2] = tokenData[tokenId].wizard;

        parts[3] = toString(tokenData[tokenId].score);

        parts[4] = toString(tokenData[tokenId].duration / 86400);

        string memory symbol;
        if (tokenData[tokenId].symbol == 6) {
            parts[
                5
            ] = '<polygon points="225,325 200,365 250,338 225,378 200,338 250,365" class="shape"/>';
            symbol = "Hexagram";
        } else if (tokenData[tokenId].symbol == 5) {
            parts[
                5
            ] = '<polygon points="225,325 207,376 253,344 197,344 242,376" class="shape"/>';
            symbol = "Pentagram";
        } else if (tokenData[tokenId].symbol == 4) {
            parts[
                5
            ] = '<rect x="200" y="325" width="50" height="50" class="shape"/>';
            symbol = "Square";
        } else {
            parts[
                5
            ] = '<polygon points="225,324 200,368 250,368" class="shape"/>';
            symbol = "Triangle";
        }

        string memory output = string(
            abi.encodePacked(
                '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 450 450"><style>.base{fill:white;font-family:serif;font-size:14px;} .gray{fill:grey} .shape{fill:black;stroke:white;stroke-width:2}</style><rect width="100%" height="100%" fill="black" /><text x="50%" y="10" class="base" text-anchor="middle">o }={}==={}====={}==={}===][==||==][==={}==={}====={}==={}={ o</text><text x="50%" y="55" class="base" text-anchor="middle">',
                parts[0],
                '</text><style>.diff {fill: orange}</style><text text-anchor="middle" x="50%" y="90" class="diff"> ',
                parts[1],
                '</text><text text-anchor="middle" x="50%" y="120" class="base">=================================================</text><text text-anchor="middle" x="50%" y="150" class="base"> Acomplished by Wizard: </text><text text-anchor="middle" x="50%" y="175" class="base gray"> ',
                parts[2],
                '</text><text text-anchor="middle" x="50%" y="225" class="base"> Score: ',
                parts[3],
                '</text><text text-anchor="middle" x="50%" y="250" class="base"> Duration: ',
                parts[4],
                " days </text>",
                parts[5],
                '<text x="15" y="73" class="base" transform="rotate(90 40,40)">}==={}====={}==={} {}==={}====={}==={} {}==={}====={}==={</text><text x="15" y="14" class="base" transform="rotate(90 225,225)">}==={}====={}==={} {}==={}====={}==={} {}==={}====={}==={</text><text x="50%" y="441" class="base" text-anchor="middle">o }={}==={}====={}==={}===][==||==][==={}==={}====={}==={}={ o</text></svg>'
            )
        );

        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(
                        bytes(
                            string(
                                abi.encodePacked(
                                    '{"name": "Quest #',
                                    toString(tokenId),
                                    '", "description": "Quest Achievements are records of heroic adventures acomplished by Wiarrds.", "attributes": [{"trait_type": "difficulty", "value": "',
                                    parts[1],
                                    '"},{"trait_type": "symbol", "value": " ',
                                    symbol,
                                    '"}], "image": "data:image/svg+xml;base64,',
                                    Base64.encode(bytes(output)),
                                    '"}'
                                )
                            )
                        )
                    )
                )
            );
    }

    function mint(
        address to,
        string memory name,
        string memory wizard,
        uint256 score,
        uint256 duration
    ) public onlyMinter {
        uint256 newTokenId = totalSupply();
        uint256 random = random(newTokenId) % 100;
        uint8 symbol;
        if (random >= 90) {
            symbol = 6;
        } else if (random >= 70) {
            symbol = 5;
        } else if (random >= 40) {
            symbol = 4;
        } else {
            symbol = 3;
        }

        tokenData[newTokenId] = TokenData({
            wizard: wizard,
            score: score,
            duration: duration,
            name: name,
            symbol: symbol
        });
        _safeMint(to, newTokenId);
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

    function random(uint256 input) internal view returns (uint256) {
        return
            uint256(
                keccak256(abi.encodePacked(input, msg.sender, block.timestamp))
            );
    }

    function pluck(uint256 tokenId, string[] memory sourceArray)
        internal
        view
        returns (string memory)
    {
        uint256 rand = random(tokenId);
        string memory output = sourceArray[rand % sourceArray.length];

        return output;
    }
}
