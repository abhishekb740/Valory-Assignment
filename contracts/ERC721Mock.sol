// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@rari-capital/solmate/src/tokens/ERC721.sol";

contract ERC721Mock is ERC721 {
    uint256 private _tokenIdCounter;

    constructor(
        string memory name,
        string memory symbol
    ) ERC721(name, symbol) {}

    function mint(address to, uint256 tokenId) external {
        _mint(to, tokenId);
    }

    function tokenURI(
        uint256 id
    ) public view virtual override returns (string memory) {
        return
            string(
                abi.encodePacked("https://example.com/token/", toString(id))
            );
    }

    // Custom implementation of toString to convert uint256 to string
    function toString(uint256 value) internal pure returns (string memory) {
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
}
