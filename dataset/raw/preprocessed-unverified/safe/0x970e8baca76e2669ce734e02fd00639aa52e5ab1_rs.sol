/**
 *Submitted for verification at Etherscan.io on 2020-11-27
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;




/**
 * @dev Collection of functions related to the address type
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
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


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
 * @dev Interface of the ERC20 standard as defined in the EIP.
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
    constructor (string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
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
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
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
     * Requirements:
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
     * Requirements:
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



/// @title DIV token rewards buyers from specific addresses (AMMs such as uniswap) by minting purchase rewards immediately, and burns a percentage of all on chain transactions.
/// @author Nijitoki Labs; in collaboration with CommunityToken.io; original ver. by KrippTorofu @ RiotOfTheBlock
///   NOTES: This version includes uniswap router registration, to prevent owner from setting mint addresses that are not UniswapV2Pairs.  
///   No tax/burn limits have been added to this token.
///   Until the Ownership is rescinded, owner can modify the parameters of the contract (tax, interest, whitelisted addresses, uniswap pairs).
///   Minting is disabled, except for the interest generating address, which is now behind a uniswap router check.
contract DIVToken2 is ERC20, Ownable {
    using SafeMath for uint256;
    using SafeMath for uint32;

    uint32 internal _burnRatePerTransferThousandth = 10;    // default of 1%, can go as low as 0.1%, or set to 0 to disable
    uint32 internal _interestRatePerBuyThousandth = 20;         // default of 2%, can go as low as 0.1%, or set to 0 to disable
    
    address internal constant uniswapV2FactoryAddress = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
    
    mapping(address => bool) internal _burnWhitelistTo;
    mapping(address => bool) internal _burnWhitelistFrom;
    mapping(address => bool) internal _UniswapAddresses;
    
    /// @notice Transfers from IUniswapV2Pair at address `addr` now will mint an extra `_interestRatePerBuyThousandth`/1000 DIV tokens per 1 Token for the recipient.
    /// @param addr Address of an IUniswapV2Pair Contract
    event UniswapAddressAdded(address indexed addr);
    /// @notice IUniswapV2Pair at address `addr` now will stop minting
    event UniswapAddressRemoved(address indexed addr);
    /// @notice The address `addr` is now whitelisted, any funds sent to it will not incur a burn. 
    /// @param addr Address of Contract / EOA to whitelist
    event AddedToWhitelistTo(address indexed addr);
    /// @notice The address `addr` is removed from whitelist, any funds sent to it will now incur a burn of `_burnRatePerTransferThousandth`/1000 DIV tokens as normal. 
    /// @param addr Address of Contract / EOA to whitelist
    event RemovedFromWhitelistTo(address indexed addr);
    /// @notice The address `addr` is now whitelisted, any funds sent FROM this address will not incur a burn. 
    /// @param addr Address of Contract / EOA to whitelist
    event AddedToWhitelistFrom(address indexed addr);
    /// @notice The address `addr` is removed from whitelist, any funds sent FROM this address will now incur a burn of `_burnRatePerTransferThousandth`/1000 DIV tokens as normal. 
    /// @param addr Address of Contract / EOA to whitelist
    event RemovedFromWhitelistFrom(address indexed addr);
    /// @notice The Burn rate has been changed to `newRate`/1000 per 1 DIV token on every transaction 
    event BurnRateChanged(uint32 newRate);
    /// @notice The Buy Interest rate has been changed to `newRate`/1000 per 1 DIV token on every transaction
    event InterestRateChanged(uint32 newRate);
    
    constructor(address tokenOwnerWallet) ERC20("DIV Token 2", "DIV2") {
        _mint(tokenOwnerWallet, 500000000000000000000000);
    }
    
    /// @notice Changes the burn rate on transfers in thousandths
    /// @param value Set this value in thousandths. Max of 50.  i.e. 10 = 1%, 1 = 0.1%, 0 = burns are disabled.
    function setBurnRatePerThousandth(uint32 value) external onlyOwner {
        // enforce a Max of 50 = 5%. 
        _burnRatePerTransferThousandth = value;
        validateContractParameters();
        emit BurnRateChanged(value);
    }

    /// @notice Changes the interest rate for purchases in thousandths
    /// @param value Set this value in thousandths. Max of 50. i.e. 10 = 1%, 1 = 0.1%, 0 = interest is disabled.
    function setInterestRatePerThousandth(uint32 value) external onlyOwner {
        _interestRatePerBuyThousandth = value;
        validateContractParameters();
        emit InterestRateChanged(value);
    }

    /// @notice Address `addr` will no longer incur the `_burnRatePerTransferThousandth`/1000 burn on Transfers
    /// @param addr Address to whitelist / dewhitelist 
    /// @param whitelisted True to add to whitelist, false to remove.
    function setBurnWhitelistToAddress (address addr, bool whitelisted) external onlyOwner {
        if(whitelisted) {
            _burnWhitelistTo[addr] = whitelisted;
            emit AddedToWhitelistTo(addr);
        } else {
            delete _burnWhitelistTo[addr];
            emit RemovedFromWhitelistTo(addr);
        }
    }

    /// @notice Address `addr` will no longer incur the `_burnRatePerTransferThousandth`/1000 burn on Transfers from it.
    /// @param addr Address to whitelist / dewhitelist 
    /// @param whitelisted True to add to whitelist, false to remove.
    function setBurnWhitelistFromAddress (address addr, bool whitelisted) external onlyOwner {
        if(whitelisted) {
            _burnWhitelistFrom[addr] = whitelisted;
            emit AddedToWhitelistFrom(addr);
        } else {
            delete _burnWhitelistFrom[addr];
            emit RemovedFromWhitelistFrom(addr);
        }
    }

    /// @notice Will query uniswapV2Factory to find a pair.  Pair now will mint an extra `_interestRatePerBuyThousandth`/1000 DIV tokens per 1 Token for the recipient.
    /// @dev This will only work with the existing uniswapV2Factory and will require a new token overall if UniswapV3 comes out...etc.
    /// @dev Hardcoding the factory pair in contract ensures someone can't create a fake uniswapV2Factory that would return a hardcoded EOA.
    /// @param erc20token address of the ACTUAL ERC20 liquidity token, e.g. to mint on buys against WETH, pass in the WETH ERC20 address, not the uniswap LP Address.
    /// @param generateInterest True to begin generating interest, false to remove.  
    function enableInterestForToken (address erc20token, bool generateInterest) external onlyOwner {
        // returns 0x0 if pair doesn't exist.
        address uniswapV2Pair = IUniswapV2Factory(uniswapV2FactoryAddress).getPair(address(this), erc20token);
        require(uniswapV2Pair != 0x0000000000000000000000000000000000000000, "EnableInterest: No valid pair exists for erc20token");
        
        if(generateInterest) {
            _UniswapAddresses[uniswapV2Pair] = generateInterest;
            emit UniswapAddressAdded(uniswapV2Pair);
        } else {
            delete _UniswapAddresses[uniswapV2Pair];
            emit UniswapAddressRemoved(uniswapV2Pair);
        }
    }

    /// @notice This function can be used by Contract Owner to disperse tokens bypassing incurring penalties or interest.  The tokens will be sent from the Owner Address Balance.
    /// @param dests Array of recipients
    /// @param values Array of values. Ensure the values are in wei. i.e. you must multiply the amount of DIV tokens to be sent by 10**18.
    function airdrop(address[] calldata dests, uint256[] calldata values) external onlyOwner returns (uint256) {
        uint256 i = 0;
        while (i < dests.length) {
            ERC20._transfer(_msgSender(), dests[i], values[i]);
            i += 1;
        }
        return(i);
    }

    /// @notice Returns the burn rate on transfers in thousandths
    function getBurnRatePerThousandth() external view returns (uint32) {  
       return _burnRatePerTransferThousandth;
    }
    
    /// @notice Returns the interest rate for purchases in thousandths
    function getInterestRate() external view returns (uint32) {  
       return _interestRatePerBuyThousandth;
    }
    
    /// @notice If true, Address `addr` will not incur `_burnRatePerTransferThousandth`/1000 burn for any Transfers to it.
    /// @param addr Address to check
    /// @dev it is not trivial to return a mapping without incurring further storage costs
    function isAddressWhitelistedTo(address addr) external view returns (bool) {
        return _burnWhitelistTo[addr];
    }
    
    /// @notice If true, Address `addr` will not incur `_burnRatePerTransferThousandth`/1000 burn for any Transfers from it.
    /// @param addr Address to check
    /// @dev it is not trivial to return a mapping without incurring further storage costs
    function isAddressWhitelistedFrom(address addr) external view returns (bool) {
        return _burnWhitelistFrom[addr];
    }
    
    /// @notice If true, transfers from IUniswapV2Pair at address `addr` will mint an extra `_interestRatePerBuyThousandth`/1000 DIV tokens per 1 Token for the recipient.
    /// @param addr Address to check
    /// @dev it is not trivial to return a mapping without incurring further storage costs
    function checkInterestGenerationForAddress(address addr) external view returns (bool) {
        return _UniswapAddresses[addr];
    }
    
    /**
        @notice ERC20 transfer function overridden to add `_burnRatePerTransferThousandth`/1000 burn on transfers as well as `_interestRatePerBuyThousandth`/1000 interest for AMM purchases. 
        @param amount amount in wei
        
        Burn rate is applied independently of the interest.
        No reentrancy check required, since these functions are not transferring ether and only modifying internal balances.
     */
    function _transfer(address sender, address recipient, uint256 amount) internal virtual override {
        // FROM uniswap address, mint interest tokens
        // Constraint: Anyone in burn whitelist cannot receive interest, to reduce owner abuse possibility.  
        // This means whitelisting uniswap for any reason will also turn off interest.
        if(_UniswapAddresses[sender] && 
            _interestRatePerBuyThousandth > 0 &&
            !_burnWhitelistTo[recipient] && 
            !_burnWhitelistFrom[sender]) {
            super._mint(recipient, amount.mul(_interestRatePerBuyThousandth).div(1000));
            // no need to adjust amount
        }

        // Apply burn
        if(!_burnWhitelistTo[recipient] && !_burnWhitelistFrom[sender] && _burnRatePerTransferThousandth>0) {
            uint256 burnAmount = amount.mul(_burnRatePerTransferThousandth).div(1000);
            super._burn(sender, burnAmount);

            // reduce the amount to be sent
            amount = amount.sub(burnAmount);
        }
        
        // Send the modified amount to recipient
        super._transfer(sender, recipient, amount);
    }

    /// @notice After modifying contract parameters, call this function to run internal consistency checks.
    function validateContractParameters() internal view {
        // These upper bounds have been added per community request
        require(_burnRatePerTransferThousandth <= 50, "Error: Burn cannot be larger than 5%");
        require(_interestRatePerBuyThousandth <= 50, "Error: Interest cannot be larger than 5%");
        
        // This is to avoid an owner accident/misuse, if uniswap can reward a larger amount than a single buy+sell, 
        // that would allow anyone to drain the Uniswap pool with a flash loan.
        // Since Uniswap fees are not considered, all Uniswap transactions are ultimately deflationary.
        require(_interestRatePerBuyThousandth <= _burnRatePerTransferThousandth.mul(2), "Error: Interest cannot exceed 2*Burn");
    }
}