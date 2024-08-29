// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./IERC20.sol";
import "./IERC721.sol";
import "./ERC721TokenReceiver.sol";

contract MiniTreasury is ERC721TokenReceiver {
    /**
    @dev Address of the owner of the contract 
    */
    address public owner;

    /**
    @dev Events to log the deposit and withdrawal of ERC20 and ERC721 tokens
    */
    event ERC20TokenDeposited(address from, address token, uint256 amount);
    event ERC20TokenWithdrawn(address to, address token, uint256 amount);
    event ERC721TokenDeposited(address from, address token, uint256 tokenId);
    event ERC721TokenWithdrawn(address to, address token, uint256 tokenId);
    event TokenEnabled(address token);
    event TokenDisabled(address token);

    /**
    @dev Error messages for the contract
    */
    error OnlyOwner(address sender, address manager);
    error TokenNotEnabled(address token);
    error NotSufficientBalance(
        address token,
        uint256 balanceInContract,
        uint256 requestedAmount
    );
    error TokenIdNotFound(address token, uint256 tokenId);
    error TransferFailed(address token, address recipient, uint256 tokenId);
    error ERC20DepositFailed(address token);
    error ZeroAddressNotAllowed();

    constructor() {
        owner = msg.sender;
    }

    /**
    @dev Variables to store the balances of ERC20 tokens, ERC721 tokens and the if the token is enabled for withdrawal
    */
    mapping(address => bool) public enabledTokens;
    mapping(address => mapping(address => uint256)) public erc20TokenBalances;
    mapping(address => mapping(address => mapping(uint256 => bool))) public erc721TokenDeposits;

    /**
    @notice Function to change the ownership of the contract
    Required that the caller is the owner of the contract
    @param newOwner Address of the new owner
    */
    function changeOwnerShip(address newOwner) external {
        if (msg.sender != owner) {
            revert OnlyOwner(msg.sender, owner);
        }
        owner = newOwner;
    }


    /**
    @notice Function to enable a token for withdrawal
    Required that the token is not the zero address
    Required that the caller is the owner of the contract
    @param token Address of the token to be enabled
    */
    function enableAToken(address token) external {
        if (token == address(0)) {
            revert ZeroAddressNotAllowed();
        }
        if (msg.sender != owner) {
            revert OnlyOwner(msg.sender, owner);
        }
        enabledTokens[token] = true;
        emit TokenEnabled(token);
    }

    /**
    @notice Function to disable a token for withdrawal
    Required that the token is not the zero address
    Required that the caller is the owner of the contract
    @param token Address of the token to be disabled
    */
    function disableAToken(address token) external {
        if (token == address(0)) {
            revert ZeroAddressNotAllowed();
        }
        if (msg.sender != owner) {
            revert OnlyOwner(msg.sender, owner);
        }
        enabledTokens[token] = false;
        emit TokenDisabled(token);
    }

    /**
    @notice Function to deposit ERC20 tokens
    Required that the token is not the zero address
    Required that the token is enabled for deposit
    Required that the user has approved the contract to spend the tokens
    @param token Address of the token to be deposited
    @param amount Amount of the token to be deposited
    */
    function depositERC20(address token, uint256 amount) external {
        if (token == address(0)) {
            revert ZeroAddressNotAllowed();
        }
        if (enabledTokens[token] == false) {
            revert TokenNotEnabled(token);
        }
        erc20TokenBalances[msg.sender][token] += amount;
        bool success = IERC20(token).transferFrom(
            msg.sender,
            address(this),
            amount
        );
        if (!success) {
            revert ERC20DepositFailed(token);
        }
        emit ERC20TokenDeposited(msg.sender, token, amount);
    }

    /**
    @notice Function to withdraw ERC20 tokens
    Required that the token is not the zero address
    Required that the token is enabled for withdrawal and the user has sufficient balance
    @param token Address of the token to be withdrawn
    @param amount Amount of the token to be withdrawn
    */
    function withdrawERC20(address token, uint256 amount) external {
        if (token == address(0)) {
            revert ZeroAddressNotAllowed();
        }
        if (enabledTokens[token] == false) {
            revert TokenNotEnabled(token);
        }
        uint256 balance = erc20TokenBalances[msg.sender][token];
        if (balance < amount) {
            revert NotSufficientBalance(token, balance, amount);
        }
        erc20TokenBalances[msg.sender][token] = balance - amount;
        IERC20(token).transfer(msg.sender, amount);
        emit ERC20TokenWithdrawn(msg.sender, token, amount);
    }

    /**
    @notice Function to deposit ERC721 tokens
    Required that the token is not the zero address
    Required that the token is enabled for deposit
    Required that the user has approved the contract to spend the tokens
    @param token Address of the token to be deposited
    @param tokenId Token ID of the token to be deposited
    */
    function depositERC721(address token, uint256 tokenId) external {
        if (token == address(0)) {
            revert ZeroAddressNotAllowed();
        }
        if (enabledTokens[token] == false) {
            revert TokenNotEnabled(token);
        }
        IERC721(token).safeTransferFrom(msg.sender, address(this), tokenId);
        emit ERC721TokenDeposited(msg.sender, token, tokenId);
    }

    /**
    @notice Function to withdraw ERC721 tokens
    Required that the token is not the zero address
    Required that the token is enabled for withdrawal and the user has the token
    @param token Address of the token to be withdrawn
    @param tokenId Token ID of the token to be withdrawn
    */
    function withdrawERC721(address token, uint256 tokenId) external {
        if (token == address(0)) {
            revert ZeroAddressNotAllowed();
        }
        if (!enabledTokens[token]) {
            revert TokenNotEnabled(token);
        }
        erc721TokenDeposits[msg.sender][token][tokenId] = false;
        IERC721(token).safeTransferFrom(address(this), msg.sender, tokenId);
        emit ERC721TokenWithdrawn(msg.sender, token, tokenId);
    }

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external override returns (bytes4) {
        erc721TokenDeposits[from][msg.sender][tokenId] = true;
        return this.onERC721Received.selector;
    }
}
