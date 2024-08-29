// Sources flattened with hardhat v2.22.9 https://hardhat.org
// Original license: SPDX_License_Identifier: MIT
pragma solidity ^0.8.24;

abstract contract ERC20 {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event Transfer(address indexed from, address indexed to, uint256 amount);

    event Approval(address indexed owner, address indexed spender, uint256 amount);

    /*//////////////////////////////////////////////////////////////
                            METADATA STORAGE
    //////////////////////////////////////////////////////////////*/

    string public name;

    string public symbol;

    uint8 public immutable decimals;

    /*//////////////////////////////////////////////////////////////
                              ERC20 STORAGE
    //////////////////////////////////////////////////////////////*/

    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;

    mapping(address => mapping(address => uint256)) public allowance;

    /*//////////////////////////////////////////////////////////////
                            EIP-2612 STORAGE
    //////////////////////////////////////////////////////////////*/

    uint256 internal immutable INITIAL_CHAIN_ID;

    bytes32 internal immutable INITIAL_DOMAIN_SEPARATOR;

    mapping(address => uint256) public nonces;

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals
    ) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;

        INITIAL_CHAIN_ID = block.chainid;
        INITIAL_DOMAIN_SEPARATOR = computeDomainSeparator();
    }

    /*//////////////////////////////////////////////////////////////
                               ERC20 LOGIC
    //////////////////////////////////////////////////////////////*/

    function approve(address spender, uint256 amount) public virtual returns (bool) {
        allowance[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);

        return true;
    }

    function transfer(address to, uint256 amount) public virtual returns (bool) {
        balanceOf[msg.sender] -= amount;

        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(msg.sender, to, amount);

        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual returns (bool) {
        uint256 allowed = allowance[from][msg.sender]; // Saves gas for limited approvals.

        if (allowed != type(uint256).max) allowance[from][msg.sender] = allowed - amount;

        balanceOf[from] -= amount;

        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(from, to, amount);

        return true;
    }

    /*//////////////////////////////////////////////////////////////
                             EIP-2612 LOGIC
    //////////////////////////////////////////////////////////////*/

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual {
        require(deadline >= block.timestamp, "PERMIT_DEADLINE_EXPIRED");

        // Unchecked because the only math done is incrementing
        // the owner's nonce which cannot realistically overflow.
        unchecked {
            address recoveredAddress = ecrecover(
                keccak256(
                    abi.encodePacked(
                        "\x19\x01",
                        DOMAIN_SEPARATOR(),
                        keccak256(
                            abi.encode(
                                keccak256(
                                    "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
                                ),
                                owner,
                                spender,
                                value,
                                nonces[owner]++,
                                deadline
                            )
                        )
                    )
                ),
                v,
                r,
                s
            );

            require(recoveredAddress != address(0) && recoveredAddress == owner, "INVALID_SIGNER");

            allowance[recoveredAddress][spender] = value;
        }

        emit Approval(owner, spender, value);
    }

    function DOMAIN_SEPARATOR() public view virtual returns (bytes32) {
        return block.chainid == INITIAL_CHAIN_ID ? INITIAL_DOMAIN_SEPARATOR : computeDomainSeparator();
    }

    function computeDomainSeparator() internal view virtual returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                    keccak256(bytes(name)),
                    keccak256("1"),
                    block.chainid,
                    address(this)
                )
            );
    }

    /*//////////////////////////////////////////////////////////////
                        INTERNAL MINT/BURN LOGIC
    //////////////////////////////////////////////////////////////*/

    function _mint(address to, uint256 amount) internal virtual {
        totalSupply += amount;

        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(address(0), to, amount);
    }

    function _burn(address from, uint256 amount) internal virtual {
        balanceOf[from] -= amount;

        // Cannot underflow because a user's balance
        // will never be larger than the total supply.
        unchecked {
            totalSupply -= amount;
        }

        emit Transfer(from, address(0), amount);
    }
}


// File @rari-capital/solmate/src/tokens/ERC721.sol@v6.4.0
/// @notice Modern, minimalist, and gas efficient ERC-721 implementation.
/// @author Solmate (https://github.com/Rari-Capital/solmate/blob/main/src/tokens/ERC721.sol)
abstract contract ERC721 {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event Transfer(address indexed from, address indexed to, uint256 indexed id);

    event Approval(address indexed owner, address indexed spender, uint256 indexed id);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /*//////////////////////////////////////////////////////////////
                         METADATA STORAGE/LOGIC
    //////////////////////////////////////////////////////////////*/

    string public name;

    string public symbol;

    function tokenURI(uint256 id) public view virtual returns (string memory);

    /*//////////////////////////////////////////////////////////////
                      ERC721 BALANCE/OWNER STORAGE
    //////////////////////////////////////////////////////////////*/

    mapping(uint256 => address) internal _ownerOf;

    mapping(address => uint256) internal _balanceOf;

    function ownerOf(uint256 id) public view virtual returns (address owner) {
        require((owner = _ownerOf[id]) != address(0), "NOT_MINTED");
    }

    function balanceOf(address owner) public view virtual returns (uint256) {
        require(owner != address(0), "ZERO_ADDRESS");

        return _balanceOf[owner];
    }

    /*//////////////////////////////////////////////////////////////
                         ERC721 APPROVAL STORAGE
    //////////////////////////////////////////////////////////////*/

    mapping(uint256 => address) public getApproved;

    mapping(address => mapping(address => bool)) public isApprovedForAll;

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
    }

    /*//////////////////////////////////////////////////////////////
                              ERC721 LOGIC
    //////////////////////////////////////////////////////////////*/

    function approve(address spender, uint256 id) public virtual {
        address owner = _ownerOf[id];

        require(msg.sender == owner || isApprovedForAll[owner][msg.sender], "NOT_AUTHORIZED");

        getApproved[id] = spender;

        emit Approval(owner, spender, id);
    }

    function setApprovalForAll(address operator, bool approved) public virtual {
        isApprovedForAll[msg.sender][operator] = approved;

        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function transferFrom(
        address from,
        address to,
        uint256 id
    ) public virtual {
        require(from == _ownerOf[id], "WRONG_FROM");

        require(to != address(0), "INVALID_RECIPIENT");

        require(
            msg.sender == from || isApprovedForAll[from][msg.sender] || msg.sender == getApproved[id],
            "NOT_AUTHORIZED"
        );

        // Underflow of the sender's balance is impossible because we check for
        // ownership above and the recipient's balance can't realistically overflow.
        unchecked {
            _balanceOf[from]--;

            _balanceOf[to]++;
        }

        _ownerOf[id] = to;

        delete getApproved[id];

        emit Transfer(from, to, id);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id
    ) public virtual {
        transferFrom(from, to, id);

        require(
            to.code.length == 0 ||
                ERC721TokenReceiver(to).onERC721Received(msg.sender, from, id, "") ==
                ERC721TokenReceiver.onERC721Received.selector,
            "UNSAFE_RECIPIENT"
        );
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        bytes calldata data
    ) public virtual {
        transferFrom(from, to, id);

        require(
            to.code.length == 0 ||
                ERC721TokenReceiver(to).onERC721Received(msg.sender, from, id, data) ==
                ERC721TokenReceiver.onERC721Received.selector,
            "UNSAFE_RECIPIENT"
        );
    }

    /*//////////////////////////////////////////////////////////////
                              ERC165 LOGIC
    //////////////////////////////////////////////////////////////*/

    function supportsInterface(bytes4 interfaceId) public view virtual returns (bool) {
        return
            interfaceId == 0x01ffc9a7 || // ERC165 Interface ID for ERC165
            interfaceId == 0x80ac58cd || // ERC165 Interface ID for ERC721
            interfaceId == 0x5b5e139f; // ERC165 Interface ID for ERC721Metadata
    }

    /*//////////////////////////////////////////////////////////////
                        INTERNAL MINT/BURN LOGIC
    //////////////////////////////////////////////////////////////*/

    function _mint(address to, uint256 id) internal virtual {
        require(to != address(0), "INVALID_RECIPIENT");

        require(_ownerOf[id] == address(0), "ALREADY_MINTED");

        // Counter overflow is incredibly unrealistic.
        unchecked {
            _balanceOf[to]++;
        }

        _ownerOf[id] = to;

        emit Transfer(address(0), to, id);
    }

    function _burn(uint256 id) internal virtual {
        address owner = _ownerOf[id];

        require(owner != address(0), "NOT_MINTED");

        // Ownership check above ensures no underflow.
        unchecked {
            _balanceOf[owner]--;
        }

        delete _ownerOf[id];

        delete getApproved[id];

        emit Transfer(owner, address(0), id);
    }

    /*//////////////////////////////////////////////////////////////
                        INTERNAL SAFE MINT LOGIC
    //////////////////////////////////////////////////////////////*/

    function _safeMint(address to, uint256 id) internal virtual {
        _mint(to, id);

        require(
            to.code.length == 0 ||
                ERC721TokenReceiver(to).onERC721Received(msg.sender, address(0), id, "") ==
                ERC721TokenReceiver.onERC721Received.selector,
            "UNSAFE_RECIPIENT"
        );
    }

    function _safeMint(
        address to,
        uint256 id,
        bytes memory data
    ) internal virtual {
        _mint(to, id);

        require(
            to.code.length == 0 ||
                ERC721TokenReceiver(to).onERC721Received(msg.sender, address(0), id, data) ==
                ERC721TokenReceiver.onERC721Received.selector,
            "UNSAFE_RECIPIENT"
        );
    }
}

/// @notice A generic interface for a contract which properly accepts ERC721 tokens.
/// @author Solmate (https://github.com/Rari-Capital/solmate/blob/main/src/tokens/ERC721.sol)
abstract contract ERC721TokenReceiver {
    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external virtual returns (bytes4) {
        return ERC721TokenReceiver.onERC721Received.selector;
    }
}


// File contracts/MiniTreasury.sol


contract MiniTreasury is ERC721TokenReceiver {
    /**
    @dev Address of the owner of the contract 
    */
    address public immutable owner;

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
    mapping(address => mapping(address => uint256[]))
        public erc721TokenDeposits;

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
    Required that the user has approved the contract to spend the tokens
    @param token Address of the token to be deposited
    @param amount Amount of the token to be deposited
    */
    function depositERC20(address token, uint256 amount) external {
        if (token == address(0)) {
            revert ZeroAddressNotAllowed();
        }
        bool success = ERC20(token).transferFrom(
            msg.sender,
            address(this),
            amount
        );
        if (!success) {
            revert ERC20DepositFailed(token);
        }
        erc20TokenBalances[msg.sender][token] += amount;
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
        ERC20(token).transfer(msg.sender, amount);
        emit ERC20TokenWithdrawn(msg.sender, token, amount);
    }

    /**
    @notice Function to deposit ERC721 tokens
    Required that the token is not the zero address
    Required that the user has approved the contract to spend the tokens
    @param token Address of the token to be deposited
    @param tokenId Token ID of the token to be deposited
    */
    function depositERC721(address token, uint256 tokenId) external {
        if (token == address(0)) {
            revert ZeroAddressNotAllowed();
        }
        ERC721(token).safeTransferFrom(msg.sender, address(this), tokenId);
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
        uint256[] storage userTokenIds = erc721TokenDeposits[msg.sender][token];
        bool tokenExists = false;
        uint256 tokenIndex;

        for (uint256 i = 0; i < userTokenIds.length; i++) {
            if (userTokenIds[i] == tokenId) {
                tokenExists = true;
                tokenIndex = i;
                break;
            }
        }

        if (!tokenExists) {
            revert TokenIdNotFound(token, tokenId);
        }

        userTokenIds[tokenIndex] = userTokenIds[userTokenIds.length - 1];
        userTokenIds.pop();

        ERC721(token).safeTransferFrom(address(this), msg.sender, tokenId);
        emit ERC721TokenWithdrawn(msg.sender, token, tokenId);
    }

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external override returns (bytes4) {
        erc721TokenDeposits[from][msg.sender].push(tokenId);
        return this.onERC721Received.selector;
    }
}
