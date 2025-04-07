/**
 *Submitted for verification at Etherscan.io on 2021-10-01
*/

// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.8.0;

// Sources flattened with hardhat v2.6.4 https://hardhat.org

// File contracts/Math/Math.sol


/**
 * @dev Standard math utilities missing in the Solidity language.
 */



// File contracts/Frax/IFrax.sol





// File contracts/FXS/IFxs.sol





// File contracts/Frax/IFraxAMOMinter.sol


// MAY need to be updated



// File contracts/Common/Context.sol


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
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


// File contracts/Math/SafeMath.sol


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



// File contracts/ERC20/IERC20.sol



/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
 */



// File contracts/Utils/Address.sol


/**
 * @dev Collection of functions related to the address type
 */



// File contracts/ERC20/ERC20.sol





/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20Mintable}.
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
    constructor (string memory __name, string memory __symbol) public {
        _name = __name;
        _symbol = __symbol;
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
     * - `spender` cannot be the zero address.approve(address spender, uint256 amount)
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
     * - the caller must have allowance for `sender`'s tokens of at least
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
     * @dev Destroys `amount` tokens from the caller.
     *
     * See {ERC20-_burn}.
     */
    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, deducting from the caller's
     * allowance.
     *
     * See {ERC20-_burn} and {ERC20-allowance}.
     *
     * Requirements:
     *
     * - the caller must have allowance for `accounts`'s tokens of at least
     * `amount`.
     */
    function burnFrom(address account, uint256 amount) public virtual {
        uint256 decreasedAllowance = allowance(account, _msgSender()).sub(amount, "ERC20: burn amount exceeds allowance");

        _approve(account, _msgSender(), decreasedAllowance);
        _burn(account, amount);
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
     * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
     *
     * This is internal function is equivalent to `approve`, and can be used to
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
     * @dev Destroys `amount` tokens from `account`.`amount` is then deducted
     * from the caller's allowance.
     *
     * See {_burn} and {_approve}.
     */
    function _burnFrom(address account, uint256 amount) internal virtual {
        _burn(account, amount);
        _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "ERC20: burn amount exceeds allowance"));
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of `from`'s tokens
     * will be to transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of `from`'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:using-hooks.adoc[Using Hooks].
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}


// File contracts/ERC20/SafeERC20.sol




/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */



// File contracts/Uniswap/TransferHelper.sol


// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false



// File contracts/Staking/Owned.sol


// https://docs.synthetix.io/contracts/Owned



// File contracts/Bridges/FraxLiquidityBridger.sol


// ====================================================================
// |     ______                   _______                             |
// |    / _____________ __  __   / ____(_____  ____ _____  ________   |
// |   / /_  / ___/ __ `| |/_/  / /_  / / __ \/ __ `/ __ \/ ___/ _ \  |
// |  / __/ / /  / /_/ _>  <   / __/ / / / / / /_/ / / / / /__/  __/  |
// | /_/   /_/   \__,_/_/|_|  /_/   /_/_/ /_/\__,_/_/ /_/\___/\___/   |
// |                                                                  |
// ====================================================================
// ======================= FraxLiquidityBridger =======================
// ====================================================================
// Takes FRAX, FXS, and collateral and bridges it to other chains for the purposes of seeding liquidity pools
// and other possible AMOs
// An AMO Minter will need to give tokens to this contract first

// Frax Finance: https://github.com/FraxFinance

// Primary Author(s)
// Travis Moore: https://github.com/FortisFortuna

// Reviewer(s) / Contributor(s)
// Jason Huan: https://github.com/jasonhuan
// Sam Kazemian: https://github.com/samkazemian








contract FraxLiquidityBridger is Owned {
    // SafeMath automatically included in Solidity >= 8.0.0
    using SafeERC20 for ERC20;

    /* ========== STATE VARIABLES ========== */

    // Instances and addresses
    IFrax public FRAX = IFrax(0x853d955aCEf822Db058eb8505911ED77F175b99e);
    IFxs public FXS = IFxs(0x3432B6A60D23Ca0dFCa7761B7ab56459D9C964D0);
    ERC20 public collateral_token;
    IFraxAMOMinter public amo_minter;
    
    // Informational
    string public name;

    // Price constants
    uint256 private constant PRICE_PRECISION = 1e6;

    // AMO Minter related
    address private amo_minter_address;

    // Collateral related
    address public collateral_address;
    uint256 public col_idx;

    // Admin addresses
    address public timelock_address;

    // Bridge related
    address[3] public bridge_addresses;
    address public destination_address_override;
    string public non_evm_destination_address;

    // Balance tracking
    uint256 public frax_bridged;
    uint256 public fxs_bridged;
    uint256 public collat_bridged;

    // Collateral balance related
    uint256 public missing_decimals;

    /* ========== MODIFIERS ========== */

    modifier onlyByOwnGov() {
        require(msg.sender == owner || msg.sender == timelock_address, "Not owner or timelock");
        _;
    }

    /* ========== CONSTRUCTOR ========== */

    constructor (
        address _owner,
        address _timelock_address,
        address _amo_minter_address,
        address[3] memory _bridge_addresses,
        address _destination_address_override,
        string memory _non_evm_destination_address,
        string memory _name
    ) Owned(_owner) {
        // Core
        timelock_address = _timelock_address;

        // Bridge related
        bridge_addresses = _bridge_addresses;
        destination_address_override = _destination_address_override;
        non_evm_destination_address = _non_evm_destination_address;

        // Informational
        name = _name;

        // AMO Minter related
        amo_minter_address = _amo_minter_address;
        amo_minter = IFraxAMOMinter(_amo_minter_address);

        // Collateral related
        collateral_address = amo_minter.collateral_address();
        col_idx = amo_minter.col_idx();
        collateral_token = ERC20(collateral_address);
        missing_decimals = amo_minter.missing_decimals();
    }

    /* ========== VIEWS ========== */

    function getTokenType(address token_address) public view returns (uint256) {
        // 0 = FRAX, 1 = FXS, 2 = Collateral
        if (token_address == address(FRAX)) return 0;
        else if (token_address == address(FXS)) return 1;
        else if (token_address == address(collateral_token)) return 2;

        // Revert on invalid tokens
        revert("getTokenType: Invalid token");
    }

    function showTokenBalances() public view returns (uint256[3] memory tkn_bals) {
        tkn_bals[0] = FRAX.balanceOf(address(this)); // FRAX
        tkn_bals[1] = FXS.balanceOf(address(this)); // FXS
        tkn_bals[2] = collateral_token.balanceOf(address(this)); // Collateral
    }

    function showAllocations() public view returns (uint256[10] memory allocations) {
        // All numbers given are in FRAX unless otherwise stated

        // Get some token balances
        uint256[3] memory tkn_bals = showTokenBalances();

        // FRAX
        allocations[0] = tkn_bals[0]; // Unbridged FRAX
        allocations[1] = frax_bridged; // Bridged FRAX
        allocations[2] = allocations[0] + allocations[1]; // Total FRAX

        // FXS
        allocations[3] = tkn_bals[1]; // Unbridged FXS
        allocations[4] = fxs_bridged; // Bridged FXS
        allocations[5] = allocations[3] + allocations[4]; // Total FXS

        // Collateral
        allocations[6] = tkn_bals[2] * (10 ** missing_decimals); // Unbridged Collateral, in E18
        allocations[7] = collat_bridged * (10 ** missing_decimals); // Bridged Collateral, in E18
        allocations[8] = allocations[6] + allocations[7]; // Total Collateral, in E18
    
        // Total USD value, in E18
        // Ignores FXS
        allocations[9] = allocations[2] + allocations[8];
    }

    // Needed for the Frax contract to function 
    function collatDollarBalance() public view returns (uint256) {
        (, uint256 col_bal) = dollarBalances();
        return col_bal;
    }

    function dollarBalances() public view returns (uint256 frax_val_e18, uint256 collat_val_e18) {
        // Get the allocations
        uint256[10] memory allocations = showAllocations();

        // FRAX portion is Frax * CR
        uint256 frax_portion_with_cr = (allocations[2] * FRAX.global_collateral_ratio()) / PRICE_PRECISION;

        // Collateral portion
        uint256 collat_portion = allocations[8];

        // Total value, not including CR, ignoring FXS
        frax_val_e18 = allocations[2] + allocations[8];

        // Collat value, accounting for CR on the FRAX portion
        collat_val_e18 = collat_portion + frax_portion_with_cr;
    }

    /* ========== MUTATIVE FUNCTIONS ========== */

    function bridge(address token_address, uint256 token_amount) external onlyByOwnGov {
        // Get the token type
        uint256 token_type = getTokenType(token_address); 

        // Defaults to sending to this contract's address on the other side
        address address_to_send_to = address(this);

        if (destination_address_override != address(0)) address_to_send_to = destination_address_override;

        // Can be overridden
        _bridgingLogic(token_type, address_to_send_to, token_amount);
        
        // Account for the bridged balances
        if (token_type == 0){
            frax_bridged += token_amount;
        }
        else if (token_type == 1){
            fxs_bridged += token_amount;
        }
        else {
            collat_bridged += token_amount;
        }
    }

    // Meant to be overriden
    function _bridgingLogic(uint256 token_type, address address_to_send_to, uint256 token_amount) internal virtual {
        revert("Need bridging logic");
    }

    /* ========== Burns and givebacks ========== */
    // Burn unneeded or excess FRAX. Goes through the minter
    function burnFRAX(uint256 frax_amount) public onlyByOwnGov {
        FRAX.approve(amo_minter_address, frax_amount);
        amo_minter.burnFraxFromAMO(frax_amount);

        // Update the balance after the transfer goes through
        if (frax_amount >= frax_bridged) frax_bridged = 0;
        else {
            frax_bridged -= frax_amount;
        }
    }

    // Burn unneeded or excess FXS. Goes through the minter
    function burnFXS(uint256 fxs_amount) public onlyByOwnGov {
        FXS.approve(amo_minter_address, fxs_amount);
        amo_minter.burnFxsFromAMO(fxs_amount);

        // Update the balance after the transfer goes through
        if (fxs_amount >= fxs_bridged) fxs_bridged = 0;
        else {
            fxs_bridged -= fxs_amount;
        }
    }

    // Give collat profits back. Goes through the minter
    function giveCollatBack(uint256 collat_amount) external onlyByOwnGov {
        collateral_token.approve(amo_minter_address, collat_amount);
        amo_minter.receiveCollatFromAMO(collat_amount);

        // Update the balance after the transfer goes through
        if (collat_amount >= collat_bridged) collat_bridged = 0;
        else {
            collat_bridged -= collat_amount;
        }
    }

    /* ========== RESTRICTED FUNCTIONS - Owner or timelock only ========== */
    
    function setTimelock(address _new_timelock) external onlyByOwnGov {
        timelock_address = _new_timelock;
    }

    function setBridgeInfo(
        address _frax_bridge_address, 
        address _fxs_bridge_address, 
        address _collateral_bridge_address, 
        address _destination_address_override, 
        string memory _non_evm_destination_address
    ) external onlyByOwnGov {
        // Make sure there are valid bridges
        require(
            _frax_bridge_address != address(0) && 
            _fxs_bridge_address != address(0) &&
            _collateral_bridge_address != address(0)
        , "Invalid bridge address");

        // Set bridge addresses
        bridge_addresses = [_frax_bridge_address, _fxs_bridge_address, _collateral_bridge_address];
        
        // Overridden cross-chain destination address
        destination_address_override = _destination_address_override;

        // Set bytes32 / non-EVM address on the other chain, if applicable
        non_evm_destination_address = _non_evm_destination_address;
        
        emit BridgeInfoChanged(_frax_bridge_address, _fxs_bridge_address, _collateral_bridge_address, _destination_address_override, _non_evm_destination_address);
    }

    function recoverERC20(address tokenAddress, uint256 tokenAmount) external onlyByOwnGov {
        // Only the owner address can ever receive the recovery withdrawal
        TransferHelper.safeTransfer(tokenAddress, owner, tokenAmount);
        emit RecoveredERC20(tokenAddress, tokenAmount);
    }

    // Generic proxy
    function execute(
        address _to,
        uint256 _value,
        bytes calldata _data
    ) external onlyByOwnGov returns (bool, bytes memory) {
        (bool success, bytes memory result) = _to.call{value:_value}(_data);
        return (success, result);
    }

    /* ========== EVENTS ========== */

    event RecoveredERC20(address token, uint256 amount);
    event BridgeInfoChanged(address frax_bridge_address, address fxs_bridge_address, address collateral_bridge_address, address destination_address_override, string non_evm_destination_address);
}


// File contracts/Bridges/Arbitrum/IL1CustomGateway.sol





// File contracts/Bridges/Arbitrum/FraxLiquidityBridger_ARBI_AnySwap.sol



contract FraxLiquidityBridger_ARBI_AnySwap is FraxLiquidityBridger {
    constructor (
        address _owner,
        address _timelock_address,
        address _amo_minter_address,
        address[3] memory _bridge_addresses,
        address _destination_address_override,
        string memory _non_evm_destination_address,
        string memory _name
    ) 
    FraxLiquidityBridger(_owner, _timelock_address, _amo_minter_address, _bridge_addresses, _destination_address_override, _non_evm_destination_address, _name)
    {}

    // The Arbitrum One Bridge needs _maxGas and _gasPriceBid parameters
    uint256 public maxGas = 275000;
    uint256 public gasPriceBid = 1632346222;

    function setGasVariables(uint256 _maxGas, uint256 _gasPriceBid) external onlyByOwnGov {
        maxGas = _maxGas;
        gasPriceBid = _gasPriceBid;
    }

    // Override with logic specific to this chain
    function _bridgingLogic(uint256 token_type, address address_to_send_to, uint256 token_amount) internal override {
        // [Arbitrum]
        if (token_type == 0){
            // L1 FRAX -> anyFRAX
            // Simple dump in / CREATE2
            // AnySwap Bridge
            TransferHelper.safeTransfer(address(FRAX), bridge_addresses[token_type], token_amount);
        }
        else if (token_type == 1) {
            // L1 FXS -> anyFXS
            // Simple dump in / CREATE2
            // AnySwap Bridge
            TransferHelper.safeTransfer(address(FXS), bridge_addresses[token_type], token_amount);
        }
        else {
            revert("COLLATERAL TRANSFERS ARE DISABLED FOR NOW");
            // // L1 USDC -> arbiUSDC
            // // outboundTransfer
            // // Arbitrum One Bridge
            // // https://etherscan.io/tx/0x00835e1352b991ad9bfdb214628d58a9f1efe3af0436feaac31a404cfc402be5

            // // INPUT
            // // https://github.com/OffchainLabs/arbitrum/blob/3340b1919c2b0ed26f2b4c0298fb31dcbc075919/packages/arb-bridge-peripherals/test/customGateway.e2e.ts

            // revert("MAKE SURE TO TEST THIS CAREFULLY BEFORE DEPLOYING");

            // // Approve
            // collateral_token.approve(bridge_addresses[token_type], token_amount);

            // // Get the calldata
            // uint256 maxSubmissionCost = 1;
            // bytes memory the_calldata = abi.encode(['uint256', 'bytes'], maxSubmissionCost, '0x');

            // // Transfer
            // IL1CustomGateway(bridge_addresses[token_type]).outboundTransfer{ value: maxSubmissionCost + (maxGas * gasPriceBid) }(
            //     collateral_address,
            //     address_to_send_to,
            //     token_amount,
            //     maxGas,
            //     gasPriceBid,
            //     the_calldata
            // );
            
            // revert("finalizeInboundTransfer needs to be called somewhere too");
        }
    }

}