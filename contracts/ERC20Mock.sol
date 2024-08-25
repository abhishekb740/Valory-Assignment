// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@rari-capital/solmate/src/tokens/ERC20.sol";

contract ERC20Mock is ERC20 {
    constructor(string memory name, string memory symbol, uint8 decimals, uint256 initialSupply)
        ERC20(name, symbol, decimals)
    {
        _mint(msg.sender, initialSupply);
    }

    function mint(address account, uint256 amount) external {
        _mint(account, amount);
    }
}
