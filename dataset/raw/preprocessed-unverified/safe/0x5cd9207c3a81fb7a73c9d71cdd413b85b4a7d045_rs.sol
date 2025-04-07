/**
 *Submitted for verification at Etherscan.io on 2021-03-02
*/

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */


/**
 * @dev Collection of functions related to the address type
 */






/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of ERC20 applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20 {
    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    /**
     * @dev Sets the values for {name} and {symbol}, initializes {decimals} with
     * a default value of 18.
     *
     * To select a different value for {decimals}, use {_setupDecimals}.
     *
     * All three of these values are immutable: they can only be set once during
     * construction.
     */
    constructor (string memory name, string memory symbol) public {
        _name = name;
        _symbol = symbol;
        _decimals = 18;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless {_setupDecimals} is
     * called.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20};
     *
     * Requirements:
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Sets {decimals} to a value other than the default one of 18.
     *
     * WARNING: This function should only be called from the constructor. Most
     * applications that interact with token contracts will not expect
     * {decimals} to ever change, and may work incorrectly if it does.
     */
    function _setupDecimals(uint8 decimals_) internal {
        _decimals = decimals_;
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be to transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */



/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    /**
      * @dev Safely transfers `tokenId` token from `from` to `to`.
      *
      * Requirements:
      *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
      * - `tokenId` token must exist and be owned by `from`.
      * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
      * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
      *
      * Emits a {Transfer} event.
      */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
}




interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity 0.6.12;




contract GoaldToken is ERC20 {
    address public _manager = msg.sender;

    /** @dev The DAO versions. DAOs only become invalid if they have a security vulnerability that compromises this contract. */
    address[] private _daoAddresses;
    mapping(address => uint256) private _isValidDAO;
    uint256 private constant UNTRACKED_DAO = 0;
    uint256 private constant VALID_DAO     = 1;
    uint256 private constant INVALID_DAO   = 2;

    /** @dev The number of decimals is small to allow for rewards of tokens with substantially different exchange rates. */
    uint8   private constant DECIMALS = 2;

    /** 
     * @dev The minimum amount of tokens necessary to be eligible for a reward. This is "one token", considering decimal places. We
     * are choosing two decimal places because we are initially targeting WBTC, which has 8. This way we can do a minimum reward ratio
     * of 1 / 1,000,000 of a WBTC, relative to our token. So at $25,000 (2020 value), the minimum reward would be $250 (assuming we
     * have issued all 10,000 tokens).
     */
    uint256 private constant REWARD_THRESHOLD = 10**uint256(DECIMALS);

    /**
     * @dev The maximum supply is 21000 tokens. 11000 tokens are burned on initiating the DAO; 1000 are given to Bittrees for initial
     * management. The remainder are minted on a decreasing schedule based on the total number of deployed Goalds.
     */
    uint256 private constant MAX_SUPPLY = 21000 * REWARD_THRESHOLD;

    /** @dev The base token URI for the Goald metadata. */
    string  private _baseTokenURI;

    /** @dev The total number of deployed Goalds across all DAOs. */
    uint256 private _goaldCount;

    /**
     * @dev The stage of the governance token. Tokens can be issued based on deployments regardless of what stage we are in.
     *      0: Created, with no governance protocol initiated. The initial governance issuance can be claimed.
     *      1: Initial governance issuance has been claimed.
     *      2: The governance protocal has been initiated.
     *      3: All governance tokens have been issued.
     */
    uint256 private constant STAGE_INITIAL               = 0;
    uint256 private constant STAGE_ISSUANCE_CLAIMED      = 1;
    uint256 private constant STAGE_DAO_INITIATED         = 2;
    uint256 private constant STAGE_ALL_GOVERNANCE_ISSUED = 3;
    uint256 private _governanceStage;

    // Reentrancy reversions are the only calls to revert (in this contract) that do not have reasons. We add a third state, 'frozen'
    // to allow for locking non-admin functions. The contract may be permanently frozen if it has been upgraded.
    uint256 private constant RE_NOT_ENTERED = 1;
    uint256 private constant RE_ENTERED     = 2;
    uint256 private constant RE_FROZEN      = 3;
    uint256 private _status;

    // Separate reentrancy status to further guard against arbitrary calls against a DAO contract via `unsafeCallDAO()`.
    uint256 private _daoStatus;

    // Override decimal places to 2. See `GoaldProxy.REWARD_THRESHOLD`.
    constructor() ERC20("Goald", "GOALD") public {
        _setupDecimals(DECIMALS);
        _status    = RE_NOT_ENTERED;
        _daoStatus = RE_NOT_ENTERED;
    }

    /// Events ///
    
    event DAOStatusChanged(address daoAddress, uint256 status);

    event DAOUpgraded(address daoAddress);

    event GoaldDeployed(address goaldAddress);

    event ManagerChanged(address newManager);

    /// Admin ///

    /** Freezes the contract. Only admin functions can be called. */
    function freeze() external {
        // Reentrancy guard.
        require(_status == RE_NOT_ENTERED);
        require(msg.sender == _manager, "Not manager");

        _status = RE_FROZEN;
    }

    /** Sets the status of a given DAO. */
    function setDAOStatus(address daoAddress, uint256 index, uint256 status) external {
        // Reentrancy guard.
        require(_status == RE_NOT_ENTERED || _status == RE_FROZEN);
        require(msg.sender == _manager, "Not manager");

        // Validate the index as well.
        require(_daoAddresses[index] == daoAddress, "Non-matching DAO index");

        // Validate the status.
        require(status == VALID_DAO || status == INVALID_DAO, "Invalid status");
        uint256 currentStatus = _isValidDAO[daoAddress];
        require(currentStatus != status && (currentStatus == VALID_DAO || currentStatus == INVALID_DAO), "Invalid current status");

        // Update the status.
        _isValidDAO[daoAddress] = status;

        // Hello world!
        emit DAOStatusChanged(daoAddress, status);
    }

    function setManager(address newManager) external {
        // Reentrancy guard.
        require(_status == RE_NOT_ENTERED || _status == RE_FROZEN);
        require(msg.sender == _manager,      "Not manager");
        require(newManager != address(0),    "Can't be zero address");
        require(newManager != address(this), "Can't be this address");

        // If the issuance has been claimed but the DAO has not been initialized, then the new manager must be able to initialize it.
        require((_governanceStage != STAGE_ISSUANCE_CLAIMED) || (balanceOf(newManager) > 11000 * REWARD_THRESHOLD), "New manager can't init DAO");

        _manager = newManager;

        // Hello world!
        emit ManagerChanged(newManager);
    }

    /** Unfreezes the contract. Non-admin functions can again be called. */
    function unfreeze() external {
        // Reentrancy guard.
        require(_status == RE_FROZEN);
        require(msg.sender == _manager, "Not manager");

        _status = RE_NOT_ENTERED;
    }

    /** Upgrades to the new DAO version. Can only be done when frozen. */
    function upgradeDAO(address daoAddress) external {
        // Reentrancy guard.
        require(_status == RE_FROZEN);
        _status = RE_ENTERED;

        // It must be a contract.
        uint256 codeSize;
        assembly { codeSize := extcodesize(daoAddress) }
        require(codeSize > 0, "Not a contract");

        // Make sure it hasn't been tracked yet.
        require(_isValidDAO[daoAddress] == UNTRACKED_DAO, "DAO already tracked");

        // Upgrade the DAO.
        _daoAddresses.push(daoAddress);
        _isValidDAO[daoAddress] = VALID_DAO;

        // Enable the DAO.
        IGoaldDAO(daoAddress).makeReady(_governanceStage, _goaldCount);

        // Hello world!
        emit DAOUpgraded(daoAddress);

        // By storing the original amount once again, a refund is triggered (see https://eips.ethereum.org/EIPS/eip-2200).
        _status = RE_FROZEN;
    }

    /// Goalds ///

    /** Gets the base url for Goald metadata. */
    function getBaseTokenURI() external view returns (string memory) {
        return _baseTokenURI;
    }

    /** Gets the total number of deployed Goalds. */
    function getGoaldCount() external view returns (uint256) {
        return _goaldCount;
    }

    /** Returns the address of the DAO which deployed the Goald. */
    function getGoaldDAO(uint256 id) external view returns (address) {
        require(id < _goaldCount, "ID too large");

        uint256 addressesCount = _daoAddresses.length;
        uint256 index;
        uint256 goaldCount;
        address goaldAddress;

        for (; index < addressesCount; index ++) {
            goaldAddress = _daoAddresses[index];
            goaldCount += IGoaldDAO(goaldAddress).getGoaldCount();
            if (id <= goaldCount) {
                return goaldAddress;
            }
        }

        revert("Unknown DAO");
    }

    /**
     * Called when a deployer deploys a new Goald (via the DAO contract). Currently we use this to distribute the governance token
     * according to the following schedule. An additional 12,000 tokens will be claimable by the deployer of this proxy. This will
     * create a total supply of 21,000 tokens. Once the governance protocal is set up, 11,000 tokens will be burned to initiate that
     * mechanism. That will leave 10% ownership for the deployer of the contract, with the remaining 90% disbused on Goald creations.
     * No rewards can be paid out before the governance protocal has been initiated.
     *
     *      # Goalds    # Tokens
     *       0 -  9       100
     *      10 - 19        90
     *      20 - 29        80
     *      30 - 39        70
     *      40 - 49        60
     *      50 - 59        50
     *      60 - 69        40
     *      70 - 79        30
     *      80 - 89        20
     *      90 - 99        10
     *       < 3600         1
     */
    function goaldDeployed(address recipient, address goaldAddress) external returns (uint256) {
        // Reentrancy guard.
        require(_daoStatus == RE_NOT_ENTERED);

        // Validate the caller.
        require(msg.sender == _daoAddresses[_daoAddresses.length - 1], "Caller not latest DAO");
        require(_isValidDAO[msg.sender] == VALID_DAO, "Caller not valid DAO");

        // Hello world!
        emit GoaldDeployed(goaldAddress);

        uint256 goaldCount = _goaldCount++;
        if (_governanceStage == STAGE_ALL_GOVERNANCE_ISSUED) {
            return 0;
        }

        // Calculate the amount of tokens issued based on the schedule.
        uint256 amount;
        if        (goaldCount <   10) {
            amount = 100;
        } else if (goaldCount <   20) {
            amount =  90;
        } else if (goaldCount <   30) {
            amount =  80;
        } else if (goaldCount <   40) {
            amount =  70;
        } else if (goaldCount <   50) {
            amount =  60;
        } else if (goaldCount <   60) {
            amount =  50;
        } else if (goaldCount <   70) {
            amount =  40;
        } else if (goaldCount <   80) {
            amount =  30;
        } else if (goaldCount <   90) {
            amount =  20;
        } else if (goaldCount <  100) {
            amount =  10;
        } else if (goaldCount < 3600) {
            amount =   1;
        }
        
        // We have issued all tokens, so move to the last stage of governance. This will short circuit this function on future calls.
        // This will result in unnecessary gas if the DAO is never initiated and all 3600 token-earning goalds are created. But the
        // DAO should be initiated long before that.
        else if (_governanceStage == STAGE_DAO_INITIATED) {
            _governanceStage = STAGE_ALL_GOVERNANCE_ISSUED;
        }

        if (amount == 0) {
            return 0;
        }

        // Validate the recipient.
        require(_isValidDAO[recipient] == UNTRACKED_DAO, "Can't be DAO");
        require(recipient != address(0), "Can't be zero address");
        require(recipient != address(this), "Can't be Goald token");

        // Validate the amount.
        uint256 totalSupply = totalSupply();
        require(amount + totalSupply > totalSupply, "Overflow error");
        require(amount + totalSupply < MAX_SUPPLY, "Exceeds supply");
        
        // Mint the tokens.
        _mint(recipient, amount);

        return amount;
    }

    /** Sets the base url for Goald metadata. */
    function setBaseTokenURI(string calldata baseTokenURI) external {
        // Reentrancy guard.
        require(_status == RE_NOT_ENTERED || _status == RE_FROZEN);
        require(msg.sender == _manager, "Not manager");

        _baseTokenURI = baseTokenURI;
    }

    /// Governance ///

    /** Claims the initial issuance of the governance token to enable bootstrapping the DAO. */
    function claimIssuance() external {
        // Reentrancy guard.
        require(_status == RE_NOT_ENTERED);
        require(msg.sender == _manager,            "Not manager");
        require(_governanceStage == STAGE_INITIAL, "Already claimed");

        // We are creating a new holder.
        if (balanceOf(_manager) < REWARD_THRESHOLD) {
            uint256 index;
            uint256 count = _daoAddresses.length;
            for (; index < count; index ++) {
                IGoaldDAO(_daoAddresses[index]).issuanceIncreasesHolders();
            }
        }

        // Mint the tokens.
        _mint(_manager, 12000 * REWARD_THRESHOLD);

        // Update the governance stage.
        _governanceStage = STAGE_ISSUANCE_CLAIMED;
    }

    /** Returns the address of the DAO at the given index. */
    function getDAOAddressAt(uint256 index) external view returns (address) {
        return _daoAddresses[index];
    }

    /** Returns the number of historical DAO addresses. */
    function getDAOCount() external view returns (uint256) {
        return _daoAddresses.length;
    }

    /** Returns the status of the DAO with the given address. */
    function getDAOStatus(address daoAddress) external view returns (uint256) {
        return _isValidDAO[daoAddress];
    }

    /** Gets the latest dao address, so long as it's valid. */
    function getLatestDAO() external view returns (address) {
        address daoAddress = _daoAddresses[_daoAddresses.length - 1];
        require(_isValidDAO[daoAddress] == VALID_DAO, "Latest DAO invalid");

        return daoAddress;
    }

    /** Returns the current stage of the DAO's governance. */
    function getGovernanceStage() external view returns (uint256) {
        return _governanceStage;
    }

    /** Releases management to the DAO. */
    function initializeDAO() external {
        // Reentrancy guard.
        require(_status == RE_NOT_ENTERED);
        _status = RE_ENTERED;

        require(msg.sender == _manager,                     "Not manager");
        require(_governanceStage == STAGE_ISSUANCE_CLAIMED, "Issuance unclaimed");

        // Burn the tokens.
        uint256 startingBalance = balanceOf(_manager);
        require(startingBalance >= 11000 * REWARD_THRESHOLD, "Not enough tokens");
        _burn(_manager, 11000 * REWARD_THRESHOLD);

        // Update the stage.
        _governanceStage = STAGE_DAO_INITIATED;

        uint256 count = _daoAddresses.length;

        // If the manager no longer is a holder we need to tell the latest DAO.
        if (count > 0 && startingBalance - (11000 * REWARD_THRESHOLD) < REWARD_THRESHOLD) {
            IGoaldDAO(_daoAddresses[count - 1]).initializeDecreasesHolders();
        }

        // Tell the DAOs so they can create rewards.
        uint256 index;
        for (; index < count; index++) {
            IGoaldDAO(_daoAddresses[index]).updateGovernanceStage();
        }

        // By storing the original amount once again, a refund is triggered (see https://eips.ethereum.org/EIPS/eip-2200).
        _status = RE_NOT_ENTERED;
    }

    /**
     * Executes a function on the DAO. Only the manager can call this function. This guards against reentrancy so any called function
     * cannot execute a call against this contract. This code is duplicated with `unsafeCallDAO()` in place of having an internal
     * `_callDAO()` since reentrancy guarding is not guaranteed.
     *
     * @param daoAddress Which DAO is being called.
     * @param encodedData The non-packed, abi encoded calldata that will be included with the function call.
     */
    function safeCallDAO(address daoAddress, bytes calldata encodedData) external returns (bytes memory) {
        // Reentrancy guard. We check against both normal reentrancy and DAO call reentrancy.
        require(_status    == RE_NOT_ENTERED);
        require(_daoStatus == RE_NOT_ENTERED);
        _status = RE_ENTERED;
        _daoStatus = RE_ENTERED;

        require(msg.sender == _manager, "Not manager");
        // `_isValidDAO` since DAOs can be disabled. Use `unsafeCallDAO()` if a call must be made to an invalid DAO.
        require(_isValidDAO[daoAddress] == VALID_DAO, "Not a valid DAO");

        // Call the function, bubbling on errors.
        (bool success, bytes memory returnData) = daoAddress.call(encodedData);

        // By storing the original amount once again, a refund is triggered (see https://eips.ethereum.org/EIPS/eip-2200).
        _status = RE_NOT_ENTERED;
        _daoStatus = RE_NOT_ENTERED;

        // See @OpenZeppelin.Address._functionCallWithValue()
        if (success) {
            return returnData;
        } else {
            // Look for revert reason and bubble it up if present
            if (returnData.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returnData_size := mload(returnData)
                    revert(add(32, returnData), returnData_size)
                }
            } else {
                revert();
            }
        }
    }

    /**
     * Executes a function on the DAO. Only the manager can call this function. This DOES NOT guard against reentrancy. Do not use
     * this unless reentrancy is needed or the call is made to an invlaid contract. Otherwise use `safeCallDAO()`. This code is
     * duplicated in place of having an internal `_callDAO()` since reentrancy guarding is not guaranteed.
     *
     * @param daoAddress Which DAO is being called.
     * @param encodedData The non-packed, abi encoded calldata that will be included with the function call.
     */
    function unsafeCallDAO(address daoAddress, bytes calldata encodedData) external returns (bytes memory) {
        // Reentrancy guard. We check against both normal reentrancy and DAO call reentrancy.
        require(_daoStatus == RE_NOT_ENTERED);
        _daoStatus = RE_ENTERED;

        require(msg.sender == _manager, "Not manager");
        // `_isValidDAO` since DAOs can be disabled.
        require(_isValidDAO[daoAddress] != UNTRACKED_DAO, "DAO not tracked");

        // Call the function, bubbling on errors.
        (bool success, bytes memory returnData) = daoAddress.call(encodedData);

        // By storing the original amount once again, a refund is triggered (see https://eips.ethereum.org/EIPS/eip-2200).
        _daoStatus = RE_NOT_ENTERED;
        
        // See @OpenZeppelin.Address._functionCallWithValue()
        if (success) {
            return returnData;
        } else {
            // Look for revert reason and bubble it up if present
            if (returnData.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returnData_size := mload(returnData)
                    revert(add(32, returnData), returnData_size)
                }
            } else {
                revert();
            }
        }
    }

    /// ERC20 Overrides ///

    /** This is overridden so we can update the reward balancees prior to the transfer completing. */
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        // Reentrancy guard.
        require(_status == RE_NOT_ENTERED);
        _status = RE_ENTERED;

        // Preserve the original balances so we know if we need to change `_rewardHolders`. We need to call `pre()` and `post()` on
        // every DAO version to make sure that the reward balances are updated correctly.
        uint256 senderBefore = balanceOf(msg.sender);
        uint256 recipientBefore = balanceOf(recipient);

        // Update reward balances.
        uint256 count = _daoAddresses.length;
        uint256 index;
        for (; index < count; index ++) {
            IGoaldDAO(_daoAddresses[index]).preTransfer(msg.sender, recipient);
        }
        
        // Transfer the tokens.
        super.transfer(recipient, amount);
        
        // Update holder counts.
        index = 0;
        for (; index < count; index ++) {
            IGoaldDAO(_daoAddresses[index]).postTransfer(msg.sender, senderBefore, balanceOf(msg.sender), recipientBefore, balanceOf(recipient));
        }

        // By storing the original amount once again, a refund is triggered (see https://eips.ethereum.org/EIPS/eip-2200).
        _status = RE_NOT_ENTERED;

        return true;
    }

    /** This is overridden so we can update the reward balancees prior to the transfer completing. */
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        // Reentrancy guard.
        require(_status == RE_NOT_ENTERED);
        _status = RE_ENTERED;

        // Preserve the original balances so we know if we need to change `_rewardHolders`. We need to call `pre()` and `post()` on
        // every DAO version to make sure that the reward balances are updated correctly.
        uint256 senderBefore = balanceOf(sender);
        uint256 recipientBefore = balanceOf(recipient);

        // Update reward balances.
        uint256 count = _daoAddresses.length;
        uint256 index;
        for (; index < count; index ++) {
            IGoaldDAO(_daoAddresses[index]).preTransfer(sender, recipient);
        }
        
        // Transfer the tokens.
        super.transferFrom(sender, recipient, amount);
        
        // Update holder counts.
        index = 0;
        for (; index < count; index ++) {
            IGoaldDAO(_daoAddresses[index]).postTransfer(sender, senderBefore, balanceOf(sender), recipientBefore, balanceOf(recipient));
        }

        // By storing the original amount once again, a refund is triggered (see https://eips.ethereum.org/EIPS/eip-2200).
        _status = RE_NOT_ENTERED;

        return true;
    }
}