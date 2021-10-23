//SPDX-License-Identifier: UNLICENSED
interface Spells {
    function getName(uint256 tokenId) external view returns (string memory);

    function getSchool(uint256 tokenId) external view returns (string memory);

    function getRange(uint256 tokenId) external view returns (string memory);

    function getDuration(uint256 tokenId) external view returns (string memory);
}
