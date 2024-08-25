// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./MiniTreasury.sol";
import "@rari-capital/solmate/src/tokens/ERC20.sol";

// The attack on the MiniTreasury Contract is not possible.
contract Attacker {
    MiniTreasury public miniTreasury;
    address public owner;

    constructor(MiniTreasury _miniTreasury) {
        miniTreasury = _miniTreasury;
        owner = msg.sender;
    }

    function attack(address token, uint256 amount) external {
        miniTreasury.depositERC20(token, amount);
        miniTreasury.withdrawERC20(token, amount);
    }

    // This fallback wont be called by the miniTreasury contract
    fallback() external {
        uint256 balance = miniTreasury.erc20TokenBalances(0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2, 0x4D9f44094F448D949fc3EECa230A01d362529424);
        if(balance > 0){
            miniTreasury.withdrawERC20(0x4D9f44094F448D949fc3EECa230A01d362529424, 100);
        }
    }
}
