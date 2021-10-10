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
        TokenData storage token = tokenData[tokenId];

        string[12] memory parts;
        parts[
            0
        ] = '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 450 450"><style>.base { fill: white; font-family: serif; font-size: 14px;} .gray{fill: grey} </style><rect width="100%" height="100%" fill="black" /><text x="50%" y="10" class="base"  text-anchor="middle">o }={}==={}====={}==={}===][==||==][==={}==={}====={}==={}={ o</text><text x="50%" y="40" class="base" text-anchor="middle">';

        parts[1] = token.name;
        if (token.score > 1514) {
            parts[
                2
            ] = '</text><style>.diff {fill: orange}</style><text text-anchor="middle" x="50%" y="70" class="diff"> ';
            parts[3] = "Legendary";
        } else if (token.score > 601) {
            parts[
                2
            ] = '</text><style>.diff {fill: #c14fdd}</style><text text-anchor="middle" x="50%" y="70" class="diff"> ';
            parts[3] = "Epic";
        } else if (token.score > 179) {
            parts[
                2
            ] = '</text><style>.diff {fill: #3e58dd}</style><text text-anchor="middle" x="50%" y="70" class="diff"> ';
            parts[3] = "Hard";
        } else {
            parts[
                2
            ] = '</text><style>.diff {fill: #b7b7b7}</style><text text-anchor="middle" x="50%" y="70" class="diff"> ';
            parts[3] = "Easy";
        }
        parts[
            4
        ] = '</text><text text-anchor="middle" x="50%" y="95" class="base">=================================================</text><text text-anchor="middle" x="50%" y="130" class="base"> Acomplished by Wizard: </text><text text-anchor="middle" x="50%" y="155" class="base gray"> ';

        parts[5] = token.wizard;

        parts[
            6
        ] = '</text><text text-anchor="middle" x="50%" y="195" class="base"> Score: ';

        parts[8] = toString(token.score);

        parts[
            9
        ] = '</text><text text-anchor="middle" x="50%" y="215" class="base"> Duration: ';

        parts[10] = toString(token.duration / 86400);

        parts[
            11
        ] = ' days </text><text x="15" y="73" class="base" transform="rotate(90 40,40)">}====={}====={}====={}====={}====={}====={}===={</text><text x="15" y="14" class="base" transform="rotate(90 225,225)">}====={}====={}====={}====={}====={}====={}===={</text></svg>';
        //<polygon x="10" y="170" points="100,10 40,198 190,78 10,78 160,198" style="fill:lime;stroke:purple;stroke-width:5;fill-rule:evenodd;"/>

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
                parts[10],
                parts[11]
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
        string memory name,
        string memory wizard,
        uint256 score,
        uint256 duration
    ) public onlyMinter {
        uint256 newTokenId = totalSupply();
        tokenData[newTokenId] = TokenData({
            wizard: wizard,
            score: score,
            duration: duration,
            name: name
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

    function random(string memory input) internal view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(input, block.number)));
    }

    function pluck(uint256 tokenId, string[] memory sourceArray)
        internal
        view
        returns (string memory)
    {
        uint256 rand = random(toString(tokenId));
        string memory output = sourceArray[rand % sourceArray.length];

        return output;
    }
}
