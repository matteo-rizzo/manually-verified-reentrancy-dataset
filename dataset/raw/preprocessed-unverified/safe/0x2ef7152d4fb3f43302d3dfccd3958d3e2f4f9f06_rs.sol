/**
 *Submitted for verification at Etherscan.io on 2021-07-13
*/

pragma solidity ^0.6.12;
pragma experimental ABIEncoderV2;

/// SPDX-License-Identifier: MIT


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
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
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
 * @dev Collection of functions related to the address type
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
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */


/// @title A proxy interface for The Protocol
/// @author bZeroX
/// @notice This is just an interface, not to be deployed itself.
/// @dev This interface is to be used for the protocol interactions.














contract BzxLiquidateV2 is Ownable, KeeperCompatibleInterface {
    using SafeERC20 for IERC20;
    IBZx public constant BZX = IBZx(0xD8Ee69652E4e4838f2531732a46d1f7F584F0b7f);

    IKyber public constant KYBER_PROXY =
        IKyber(0x9AAb3f75489902f3a48495025729a0AF77d4b11e);

    IKeep3rV1 public constant KP3R =
        IKeep3rV1(0x1cEB5cB57C4D4E2b2433641b95Dd330A33185A44);

    IWeth public constant WETH =
        IWeth(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);

    modifier upkeep() {
        require(
            KP3R.isKeeper(msg.sender),
            "::isKeeper: keeper is not registered"
        );
        _;
        KP3R.worked(msg.sender);
    }

    fallback() external payable {}

    receive() external payable {}

    function liquidateInternal(
        bytes32 loanId,
        address loanToken,
        address collateralToken,
        uint256 maxLiquidatable,
        address flashLoanToken,
        bool allowLoss,
        bool checkBeforeExecuting
    ) internal returns (address, uint256) {
        if (checkBeforeExecuting) {
            IBZx.LoanReturnData memory loan = BZX.getLoan(loanId);
            require(
                loan.maxLiquidatable > 0 && loan.maxSeizable > 0,
                "healty loan"
            );
        }

        bytes memory b = IToken(flashLoanToken).flashBorrow(
            maxLiquidatable,
            address(this),
            address(this),
            "",
            abi.encodeWithSelector(
                this.executeOperation.selector, //"executeOperation(bytes32,address,address,uint256,address,bool,address)",
                loanId,
                loanToken,
                collateralToken,
                maxLiquidatable,
                flashLoanToken,
                allowLoss,
                msg.sender
            )
        );

        (, , , uint256 profitAmount) = abi.decode(
            b,
            (uint256, uint256, address, uint256)
        );
        return (loanToken, profitAmount);
    }

    function liquidate(
        bytes32 loanId,
        address loanToken,
        address collateralToken,
        uint256 maxLiquidatable,
        address flashLoanToken
    ) external upkeep returns (address, uint256) {
        return
            liquidateInternal(
                loanId,
                loanToken,
                collateralToken,
                maxLiquidatable,
                flashLoanToken,
                false,
                false
            );
    }

    function liquidateCheckBeforeExecuting(
        bytes32 loanId,
        address loanToken,
        address collateralToken,
        uint256 maxLiquidatable,
        address flashLoanToken
    ) external upkeep returns (address, uint256) {
        return
            liquidateInternal(
                loanId,
                loanToken,
                collateralToken,
                maxLiquidatable,
                flashLoanToken,
                false,
                true
            );
    }

    function liquidatePublic(
        bytes32 loanId,
        address loanToken,
        address collateralToken,
        uint256 maxLiquidatable,
        address flashLoanToken
    ) external returns (address, uint256) {
        return
            liquidateInternal(
                loanId,
                loanToken,
                collateralToken,
                maxLiquidatable,
                flashLoanToken,
                false,
                false
            );
    }

    function liquidateAllowLoss(
        bytes32 loanId,
        address loanToken,
        address collateralToken,
        uint256 maxLiquidatable,
        address flashLoanToken,
        bool checkBeforeExecuting
    ) external onlyOwner returns (address, uint256) {
        return
            liquidateInternal(
                loanId,
                loanToken,
                collateralToken,
                maxLiquidatable,
                flashLoanToken,
                true,
                checkBeforeExecuting
            );
    }

    function executeOperation(
        bytes32 loanId,
        address loanToken,
        address collateralToken,
        uint256 maxLiquidatable,
        address iToken,
        bool allowLoss,
        address gasTokenUser
    ) external returns (bytes memory) {
        (uint256 _liquidatedLoanAmount, uint256 _liquidatedCollateral, ) = BZX
        .liquidate(loanId, address(this), uint256(-1));

        if (collateralToken == address(WETH) && address(this).balance != 0) {
            WETH.deposit{value: address(this).balance}();
        }
        // his is testnet
        // (uint256 _realLiquidatedLoanAmount,) = ISwapsImpl(BZX.swapsImpl()).dexSwap(
        //     collateralToken,
        //     loanToken,
        //     address(this),
        //     address(this),
        //     _liquidatedCollateral,
        //     _liquidatedCollateral,
        //     0
        // );
        uint256 _realLiquidatedLoanAmount = KYBER_PROXY.swapTokenToToken(
            IERC20(collateralToken),
            _liquidatedCollateral,
            IERC20(loanToken),
            0
        );

        if (!allowLoss) {
            require(
                _realLiquidatedLoanAmount > _liquidatedLoanAmount,
                "no profit"
            );
        }

        // repay flash loan
        IERC20(loanToken).safeTransfer(iToken, maxLiquidatable);

        return
            abi.encode(
                loanToken,
                uint256(_realLiquidatedLoanAmount - _liquidatedLoanAmount)
            );
    }

    function wrapEther() public onlyOwner {
        if (address(this).balance != 0) {
            WETH.deposit{value: address(this).balance}();
        }
    }

    function withdrawIERC20(IERC20 token) public onlyOwner {
        token.safeTransfer(msg.sender, token.balanceOf(address(this)));
    }

    function infiniteApproveIERC20(IERC20[] calldata tokens) public onlyOwner {
        for (uint256 i = 0; i < tokens.length; i++) {
            if (tokens[i].allowance(address(this), address(BZX)) != 0) {
                tokens[i].safeApprove(address(BZX), 0);
            }
            tokens[i].safeApprove(address(BZX), uint256(-1));

            if (tokens[i].allowance(address(this), address(KYBER_PROXY)) != 0) {
                tokens[i].safeApprove(address(KYBER_PROXY), 0);
            }
            tokens[i].safeApprove(address(KYBER_PROXY), uint256(-1));
        }
    }

    // chainlink registry mainnet 0x109A81F1E0A35D4c1D0cae8aCc6597cd54b47Bc6
    // chainlink registry kovan 0xAaaD7966EBE0663b8C9C6f683FB9c3e66E03467F
    // link token mainnet 0x514910771AF9Ca656af840dff83E8264EcF986CA
    // link token kovan 0xa36085F69e2889c224210F603D836748e7dC0088
    function infiniteApproveLinkRegistry(address registry, IERC20 token)
        public
        onlyOwner
    {
        if (token.allowance(address(this), registry) != 0) {
            token.safeApprove(registry, 0);
        }
        token.safeApprove(registry, uint256(-1));
    }

    // event Logger(string name, uint256 value);
    // event LoggerAddress(string name, address value);
    // event LoggerBytes32(string name, bytes32 value);

    struct LoanReturnDataMinimal {
        bytes32 loanId; // id of the loan
        address loanToken; // loan token address
        address collateralToken; // collateral token address
        uint256 maxLiquidatable; // is the collateral you can get liquidating
        uint256 maxSeizable; // is the loan you available for liquidation
        address iToken; // iToken for liquidation
    }

    function getLiquidatableLoans(uint256 start, uint256 count)
        public
        view
        returns (LoanReturnDataMinimal[] memory liquidatableLoans)
    {
        IBZx.LoanReturnData[] memory loans;
        loans = BZX.getActiveLoansAdvanced(start, count, true, true);
        liquidatableLoans = new LoanReturnDataMinimal[](loans.length);

        for (uint256 i = 0; i < loans.length; i++) {
            liquidatableLoans[i] = LoanReturnDataMinimal(
                loans[i].loanId,
                loans[i].loanToken,
                loans[i].collateralToken,
                loans[i].maxLiquidatable,
                loans[i].maxSeizable,
                BZX.underlyingToLoanPool(loans[i].loanToken)
            );
        }
        // assembly {
        //     mstore(liquidatableLoans, counter)
        // }
    }

    // function isProfitalbe(IBZx.LoanReturnData memory loan)
    //     public
    //     pure
    //     returns (bool)
    // {
    //     return
    //         loan.currentMargin > 0 &&
    //         loan.principal > 0 &&
    //         loan.collateral > 0 &&
    //         loan.maxLiquidatable > 0 &&
    //         loan.maxSeizable > 0;
    // }

    function checkUpkeep(bytes calldata checkData)
        external
        override
        returns (bool upkeepNeeded, bytes memory performData)
    {
        (uint256 start, uint256 count) = abi.decode(
            checkData,
            (uint256, uint256)
        );
        LoanReturnDataMinimal[] memory liquidatableLoans = getLiquidatableLoans(
            start,
            count
        );

        return (liquidatableLoans.length > 0, abi.encode(liquidatableLoans));
    }

    function encode(uint256 start, uint256 count)
        external
        pure
        returns (bytes memory checkData)
    {
        return abi.encode(start, count);
    }

    function performUpkeep(bytes calldata performData) external override {
        LoanReturnDataMinimal[] memory loans = abi.decode(
            performData,
            (LoanReturnDataMinimal[])
        );
        require(loans.length > 0, "Cannot execute");

        // liquidation uses approximately 1.6m gas lets round to 2m. current ethereum gasLimit ~12.5m
        // we agreed to liquidate just one in single performUpkeep call
        address(this).call(
            abi.encodeWithSelector(
                this.liquidatePublic.selector,
                loans[1].loanId,
                loans[1].loanToken,
                loans[1].collateralToken,
                loans[1].maxLiquidatable,
                loans[1].iToken
            )
        );
        
    }
}