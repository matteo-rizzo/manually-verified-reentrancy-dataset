/**
 *Submitted for verification at Etherscan.io on 2021-05-25
*/

// SPDX-License-Identifier:  AGPL-3.0-or-later // hevm: flattened sources of contracts/Loan.sol
pragma solidity =0.6.11 >=0.6.0 <0.8.0 >=0.6.2 <0.8.0;

////// contracts/interfaces/ICollateralLocker.sol
/* pragma solidity 0.6.11; */



////// contracts/interfaces/ICollateralLockerFactory.sol
/* pragma solidity 0.6.11; */



////// lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol
/* pragma solidity >=0.6.0 <0.8.0; */

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


////// contracts/interfaces/IERC20Details.sol
/* pragma solidity 0.6.11; */

/* import "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol"; */

interface IERC20Details is IERC20 {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint256);

}

////// contracts/interfaces/IFundingLocker.sol
/* pragma solidity 0.6.11; */



////// contracts/interfaces/IFundingLockerFactory.sol
/* pragma solidity 0.6.11; */



////// contracts/interfaces/ILateFeeCalc.sol
/* pragma solidity 0.6.11; */

 

////// contracts/interfaces/ILiquidityLocker.sol
/* pragma solidity 0.6.11; */



////// contracts/interfaces/ILoanFactory.sol
/* pragma solidity 0.6.11; */



////// contracts/interfaces/IMapleGlobals.sol
/* pragma solidity 0.6.11; */



////// contracts/token/interfaces/IBaseFDT.sol
/* pragma solidity 0.6.11; */



////// contracts/token/interfaces/IBasicFDT.sol
/* pragma solidity 0.6.11; */

/* import "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol"; */

/* import "./IBaseFDT.sol"; */

interface IBasicFDT is IBaseFDT, IERC20 {

    event PointsPerShareUpdated(uint256);

    event PointsCorrectionUpdated(address indexed, int256);

    function withdrawnFundsOf(address) external view returns (uint256);

    function accumulativeFundsOf(address) external view returns (uint256);

    function updateFundsReceived() external;

}

////// contracts/token/interfaces/IExtendedFDT.sol
/* pragma solidity 0.6.11; */

/* import "./IBasicFDT.sol"; */

interface IExtendedFDT is IBasicFDT {

    event LossesPerShareUpdated(uint256);

    event LossesCorrectionUpdated(address indexed, int256);

    event LossesDistributed(address indexed, uint256);

    event LossesRecognized(address indexed, uint256, uint256);

    function lossesPerShare() external view returns (uint256);

    function recognizableLossesOf(address) external view returns (uint256);

    function recognizedLossesOf(address) external view returns (uint256);

    function accumulativeLossesOf(address) external view returns (uint256);

    function updateLossesReceived() external;

}

////// contracts/token/interfaces/IPoolFDT.sol
/* pragma solidity 0.6.11; */

/* import "./IExtendedFDT.sol"; */

interface IPoolFDT is IExtendedFDT {

    function interestSum() external view returns (uint256);

    function poolLosses() external view returns (uint256);

    function interestBalance() external view returns (uint256);

    function lossesBalance() external view returns (uint256);

}

////// contracts/interfaces/IPool.sol
/* pragma solidity 0.6.11; */

/* import "../token/interfaces/IPoolFDT.sol"; */

interface IPool is IPoolFDT {

    function poolDelegate() external view returns (address);

    function poolAdmins(address) external view returns (bool);

    function deposit(uint256) external;

    function increaseCustodyAllowance(address, uint256) external;

    function transferByCustodian(address, address, uint256) external;

    function poolState() external view returns (uint256);

    function deactivate() external;

    function finalize() external;

    function claim(address, address) external returns (uint256[7] memory);

    function setLockupPeriod(uint256) external;
    
    function setStakingFee(uint256) external;

    function setPoolAdmin(address, bool) external;

    function fundLoan(address, address, uint256) external;

    function withdraw(uint256) external;

    function superFactory() external view returns (address);

    function triggerDefault(address, address) external;

    function isPoolFinalized() external view returns (bool);

    function setOpenToPublic(bool) external;

    function setAllowList(address, bool) external;

    function allowedLiquidityProviders(address) external view returns (bool);

    function openToPublic() external view returns (bool);

    function intendToWithdraw() external;

    function DL_FACTORY() external view returns (uint8);

    function liquidityAsset() external view returns (address);

    function liquidityLocker() external view returns (address);

    function stakeAsset() external view returns (address);

    function stakeLocker() external view returns (address);

    function stakingFee() external view returns (uint256);

    function delegateFee() external view returns (uint256);

    function principalOut() external view returns (uint256);

    function liquidityCap() external view returns (uint256);

    function lockupPeriod() external view returns (uint256);

    function depositDate(address) external view returns (uint256);

    function debtLockers(address, address) external view returns (address);

    function withdrawCooldown(address) external view returns (uint256);

    function setLiquidityCap(uint256) external;

    function cancelWithdraw() external;

    function reclaimERC20(address) external;

    function BPTVal(address, address, address, address) external view returns (uint256);

    function isDepositAllowed(uint256) external view returns (bool);

    function getInitialStakeRequirements() external view returns (uint256, uint256, bool, uint256, uint256);

}

////// contracts/interfaces/IPoolFactory.sol
/* pragma solidity 0.6.11; */



////// contracts/interfaces/IPremiumCalc.sol
/* pragma solidity 0.6.11; */

 

////// contracts/interfaces/IRepaymentCalc.sol
/* pragma solidity 0.6.11; */

 

////// contracts/interfaces/IUniswapRouter.sol
/* pragma solidity 0.6.11; */



////// lib/openzeppelin-contracts/contracts/math/SafeMath.sol
/* pragma solidity >=0.6.0 <0.8.0; */

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


////// contracts/library/Util.sol
/* pragma solidity 0.6.11; */

/* import "../interfaces/IERC20Details.sol"; */
/* import "../interfaces/IMapleGlobals.sol"; */
/* import "lib/openzeppelin-contracts/contracts/math/SafeMath.sol"; */

/// @title Util is a library that contains utility functions.


////// lib/openzeppelin-contracts/contracts/utils/Address.sol
/* pragma solidity >=0.6.2 <0.8.0; */

/**
 * @dev Collection of functions related to the address type
 */


////// lib/openzeppelin-contracts/contracts/token/ERC20/SafeERC20.sol
/* pragma solidity >=0.6.0 <0.8.0; */

/* import "./IERC20.sol"; */
/* import "../../math/SafeMath.sol"; */
/* import "../../utils/Address.sol"; */

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */


////// contracts/library/LoanLib.sol
/* pragma solidity 0.6.11; */

/* import "../interfaces/ICollateralLocker.sol"; */
/* import "../interfaces/ICollateralLockerFactory.sol"; */
/* import "../interfaces/IERC20Details.sol"; */
/* import "../interfaces/IFundingLocker.sol"; */
/* import "../interfaces/IFundingLockerFactory.sol"; */
/* import "../interfaces/IMapleGlobals.sol"; */
/* import "../interfaces/ILateFeeCalc.sol"; */
/* import "../interfaces/ILoanFactory.sol"; */
/* import "../interfaces/IPremiumCalc.sol"; */
/* import "../interfaces/IRepaymentCalc.sol"; */
/* import "../interfaces/IUniswapRouter.sol"; */

/* import "../library/Util.sol"; */

/* import "lib/openzeppelin-contracts/contracts/token/ERC20/SafeERC20.sol"; */
/* import "lib/openzeppelin-contracts/contracts/math/SafeMath.sol"; */

/// @title LoanLib is a library of utility functions used by Loan.


////// contracts/math/SafeMathInt.sol
/* pragma solidity 0.6.11; */



////// contracts/math/SafeMathUint.sol
/* pragma solidity 0.6.11; */



////// lib/openzeppelin-contracts/contracts/math/SignedSafeMath.sol
/* pragma solidity >=0.6.0 <0.8.0; */

/**
 * @title SignedSafeMath
 * @dev Signed math operations with safety checks that revert on error.
 */


////// lib/openzeppelin-contracts/contracts/GSN/Context.sol
/* pragma solidity >=0.6.0 <0.8.0; */

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

////// lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol
/* pragma solidity >=0.6.0 <0.8.0; */

/* import "../../GSN/Context.sol"; */
/* import "./IERC20.sol"; */
/* import "../../math/SafeMath.sol"; */

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
    constructor (string memory name_, string memory symbol_) public {
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

////// contracts/token/BasicFDT.sol
/* pragma solidity 0.6.11; */

/* import "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol"; */
/* import "lib/openzeppelin-contracts/contracts/math/SafeMath.sol"; */
/* import "lib/openzeppelin-contracts/contracts/math/SignedSafeMath.sol"; */
/* import "./interfaces/IBaseFDT.sol"; */
/* import "../math/SafeMathUint.sol"; */
/* import "../math/SafeMathInt.sol"; */

/// @title BasicFDT implements base level FDT functionality for accounting for revenues.
abstract contract BasicFDT is IBaseFDT, ERC20 {
    using SafeMath       for uint256;
    using SafeMathUint   for uint256;
    using SignedSafeMath for  int256;
    using SafeMathInt    for  int256;

    uint256 internal constant pointsMultiplier = 2 ** 128;
    uint256 internal pointsPerShare;

    mapping(address => int256)  internal pointsCorrection;
    mapping(address => uint256) internal withdrawnFunds;

    event   PointsPerShareUpdated(uint256 pointsPerShare);
    event PointsCorrectionUpdated(address indexed account, int256 pointsCorrection);

    constructor(string memory name, string memory symbol) ERC20(name, symbol) public { }

    /**
        @dev Distributes funds to token holders.
        @dev It reverts if the total supply of tokens is 0.
        @dev It emits a `FundsDistributed` event if the amount of received funds is greater than 0.
        @dev It emits a `PointsPerShareUpdated` event if the amount of received funds is greater than 0.
             About undistributed funds:
                In each distribution, there is a small amount of funds which do not get distributed,
                   which is `(value  pointsMultiplier) % totalSupply()`.
                With a well-chosen `pointsMultiplier`, the amount funds that are not getting distributed
                   in a distribution can be less than 1 (base unit).
                We can actually keep track of the undistributed funds in a distribution
                   and try to distribute it in the next distribution.
    */
    function _distributeFunds(uint256 value) internal {
        require(totalSupply() > 0, "FDT:ZERO_SUPPLY");

        if (value == 0) return;

        pointsPerShare = pointsPerShare.add(value.mul(pointsMultiplier) / totalSupply());
        emit FundsDistributed(msg.sender, value);
        emit PointsPerShareUpdated(pointsPerShare);
    }

    /**
        @dev    Prepares the withdrawal of funds.
        @dev    It emits a `FundsWithdrawn` event if the amount of withdrawn funds is greater than 0.
        @return withdrawableDividend The amount of dividend funds that can be withdrawn.
    */
    function _prepareWithdraw() internal returns (uint256 withdrawableDividend) {
        withdrawableDividend       = withdrawableFundsOf(msg.sender);
        uint256 _withdrawnFunds    = withdrawnFunds[msg.sender].add(withdrawableDividend);
        withdrawnFunds[msg.sender] = _withdrawnFunds;

        emit FundsWithdrawn(msg.sender, withdrawableDividend, _withdrawnFunds);
    }

    /**
        @dev    Returns the amount of funds that an account can withdraw.
        @param  _owner The address of a token holder.
        @return The amount funds that `_owner` can withdraw.
    */
    function withdrawableFundsOf(address _owner) public view override returns (uint256) {
        return accumulativeFundsOf(_owner).sub(withdrawnFunds[_owner]);
    }

    /**
        @dev    Returns the amount of funds that an account has withdrawn.
        @param  _owner The address of a token holder.
        @return The amount of funds that `_owner` has withdrawn.
    */
    function withdrawnFundsOf(address _owner) external view returns (uint256) {
        return withdrawnFunds[_owner];
    }

    /**
        @dev    Returns the amount of funds that an account has earned in total.
        @dev    accumulativeFundsOf(_owner) = withdrawableFundsOf(_owner) + withdrawnFundsOf(_owner)
                                         = (pointsPerShare * balanceOf(_owner) + pointsCorrection[_owner]) / pointsMultiplier
        @param  _owner The address of a token holder.
        @return The amount of funds that `_owner` has earned in total.
    */
    function accumulativeFundsOf(address _owner) public view returns (uint256) {
        return
            pointsPerShare
                .mul(balanceOf(_owner))
                .toInt256Safe()
                .add(pointsCorrection[_owner])
                .toUint256Safe() / pointsMultiplier;
    }

    /**
        @dev   Transfers tokens from one account to another. Updates pointsCorrection to keep funds unchanged.
        @dev   It emits two `PointsCorrectionUpdated` events, one for the sender and one for the receiver.
        @param from  The address to transfer from.
        @param to    The address to transfer to.
        @param value The amount to be transferred.
    */
    function _transfer(
        address from,
        address to,
        uint256 value
    ) internal virtual override {
        super._transfer(from, to, value);

        int256 _magCorrection       = pointsPerShare.mul(value).toInt256Safe();
        int256 pointsCorrectionFrom = pointsCorrection[from].add(_magCorrection);
        pointsCorrection[from]      = pointsCorrectionFrom;
        int256 pointsCorrectionTo   = pointsCorrection[to].sub(_magCorrection);
        pointsCorrection[to]        = pointsCorrectionTo;

        emit PointsCorrectionUpdated(from, pointsCorrectionFrom);
        emit PointsCorrectionUpdated(to,   pointsCorrectionTo);
    }

    /**
        @dev   Mints tokens to an account. Updates pointsCorrection to keep funds unchanged.
        @param account The account that will receive the created tokens.
        @param value   The amount that will be created.
    */
    function _mint(address account, uint256 value) internal virtual override {
        super._mint(account, value);

        int256 _pointsCorrection = pointsCorrection[account].sub(
            (pointsPerShare.mul(value)).toInt256Safe()
        );

        pointsCorrection[account] = _pointsCorrection;

        emit PointsCorrectionUpdated(account, _pointsCorrection);
    }

    /**
        @dev   Burns an amount of the token of a given account. Updates pointsCorrection to keep funds unchanged.
        @dev   It emits a `PointsCorrectionUpdated` event.
        @param account The account whose tokens will be burnt.
        @param value   The amount that will be burnt.
    */
    function _burn(address account, uint256 value) internal virtual override {
        super._burn(account, value);

        int256 _pointsCorrection = pointsCorrection[account].add(
            (pointsPerShare.mul(value)).toInt256Safe()
        );

        pointsCorrection[account] = _pointsCorrection;

        emit PointsCorrectionUpdated(account, _pointsCorrection);
    }

    /**
        @dev Withdraws all available funds for a token holder.
    */
    function withdrawFunds() public virtual override {}

    /**
        @dev    Updates the current `fundsToken` balance and returns the difference of the new and previous `fundsToken` balance.
        @return A int256 representing the difference of the new and previous `fundsToken` balance.
    */
    function _updateFundsTokenBalance() internal virtual returns (int256) {}

    /**
        @dev Registers a payment of funds in tokens. May be called directly after a deposit is made.
        @dev Calls _updateFundsTokenBalance(), whereby the contract computes the delta of the new and previous
             `fundsToken` balance and increments the total received funds (cumulative), by delta, by calling _distributeFunds().
    */
    function updateFundsReceived() public virtual {
        int256 newFunds = _updateFundsTokenBalance();

        if (newFunds <= 0) return;

        _distributeFunds(newFunds.toUint256Safe());
    }
}

////// contracts/token/LoanFDT.sol
/* pragma solidity 0.6.11; */

/* import "lib/openzeppelin-contracts/contracts/token/ERC20/SafeERC20.sol"; */

/* import "./BasicFDT.sol"; */

/// @title LoanFDT inherits BasicFDT and uses the original ERC-2222 logic.
abstract contract LoanFDT is BasicFDT {
    using SafeMath       for uint256;
    using SafeMathUint   for uint256;
    using SignedSafeMath for  int256;
    using SafeMathInt    for  int256;
    using SafeERC20      for  IERC20;

    IERC20 public immutable fundsToken; // The `fundsToken` (dividends).

    uint256 public fundsTokenBalance;   // The amount of `fundsToken` (Liquidity Asset) currently present and accounted for in this contract.

    constructor(string memory name, string memory symbol, address _fundsToken) BasicFDT(name, symbol) public {
        fundsToken = IERC20(_fundsToken);
    }

    /**
        @dev Withdraws all available funds for a token holder.
    */
    function withdrawFunds() public virtual override {
        uint256 withdrawableFunds = _prepareWithdraw();

        if (withdrawableFunds > uint256(0)) {
            fundsToken.safeTransfer(msg.sender, withdrawableFunds);

            _updateFundsTokenBalance();
        }
    }

    /**
        @dev    Updates the current `fundsToken` balance and returns the difference of the new and previous `fundsToken` balance.
        @return A int256 representing the difference of the new and previous `fundsToken` balance.
    */
    function _updateFundsTokenBalance() internal virtual override returns (int256) {
        uint256 _prevFundsTokenBalance = fundsTokenBalance;

        fundsTokenBalance = fundsToken.balanceOf(address(this));

        return int256(fundsTokenBalance).sub(int256(_prevFundsTokenBalance));
    }
}

////// lib/openzeppelin-contracts/contracts/utils/Pausable.sol
/* pragma solidity >=0.6.0 <0.8.0; */

/* import "../GSN/Context.sol"; */

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor () internal {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!_paused, "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(_paused, "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

////// contracts/Loan.sol
/* pragma solidity 0.6.11; */

/* import "lib/openzeppelin-contracts/contracts/utils/Pausable.sol"; */
/* import "lib/openzeppelin-contracts/contracts/token/ERC20/SafeERC20.sol"; */

/* import "./interfaces/ICollateralLocker.sol"; */
/* import "./interfaces/ICollateralLockerFactory.sol"; */
/* import "./interfaces/IERC20Details.sol"; */
/* import "./interfaces/IFundingLocker.sol"; */
/* import "./interfaces/IFundingLockerFactory.sol"; */
/* import "./interfaces/IMapleGlobals.sol"; */
/* import "./interfaces/ILateFeeCalc.sol"; */
/* import "./interfaces/ILiquidityLocker.sol"; */
/* import "./interfaces/ILoanFactory.sol"; */
/* import "./interfaces/IPool.sol"; */
/* import "./interfaces/IPoolFactory.sol"; */
/* import "./interfaces/IPremiumCalc.sol"; */
/* import "./interfaces/IRepaymentCalc.sol"; */
/* import "./interfaces/IUniswapRouter.sol"; */

/* import "./library/Util.sol"; */
/* import "./library/LoanLib.sol"; */

/* import "./token/LoanFDT.sol"; */

/// @title Loan maintains all accounting and functionality related to Loans.
contract Loan is LoanFDT, Pausable {

    using SafeMathInt     for int256;
    using SignedSafeMath  for int256;
    using SafeMath        for uint256;
    using SafeERC20       for IERC20;

    /**
        Ready      = The Loan has been initialized and is ready for funding (assuming funding period hasn't ended)
        Active     = The Loan has been drawdown and the Borrower is making payments
        Matured    = The Loan is fully paid off and has "matured"
        Expired    = The Loan did not initiate, and all funding was returned to Lenders
        Liquidated = The Loan has been liquidated
    */
    enum State { Ready, Active, Matured, Expired, Liquidated }

    State public loanState;  // The current state of this Loan, as defined in the State enum below.

    IERC20 public immutable liquidityAsset;      // The asset deposited by Lenders into the FundingLocker, when funding this Loan.
    IERC20 public immutable collateralAsset;     // The asset deposited by Borrower into the CollateralLocker, for collateralizing this Loan.

    address public immutable fundingLocker;      // The FundingLocker that holds custody of Loan funds before drawdown.
    address public immutable flFactory;          // The FundingLockerFactory.
    address public immutable collateralLocker;   // The CollateralLocker that holds custody of Loan collateral.
    address public immutable clFactory;          // The CollateralLockerFactory.
    address public immutable borrower;           // The Borrower of this Loan, responsible for repayments.
    address public immutable repaymentCalc;      // The RepaymentCalc for this Loan.
    address public immutable lateFeeCalc;        // The LateFeeCalc for this Loan.
    address public immutable premiumCalc;        // The PremiumCalc for this Loan.
    address public immutable superFactory;       // The LoanFactory that deployed this Loan.

    mapping(address => bool) public loanAdmins;  // Admin addresses that have permission to do certain operations in case of disaster management.

    uint256 public nextPaymentDue;  // The unix timestamp due date of the next payment.

    // Loan specifications
    uint256 public immutable apr;                     // The APR in basis points.
    uint256 public           paymentsRemaining;       // The number of payments remaining on the Loan.
    uint256 public immutable termDays;                // The total length of the Loan term in days.
    uint256 public immutable paymentIntervalSeconds;  // The time between Loan payments in seconds.
    uint256 public immutable requestAmount;           // The total requested amount for Loan.
    uint256 public immutable collateralRatio;         // The percentage of value of the drawdown amount to post as collateral in basis points.
    uint256 public immutable createdAt;               // The timestamp of when Loan was instantiated.
    uint256 public immutable fundingPeriod;           // The time for a Loan to be funded in seconds.
    uint256 public immutable defaultGracePeriod;      // The time a Borrower has, after a payment is due, to make a payment before a liquidation can occur.

    // Accounting variables
    uint256 public principalOwed;   // The amount of principal owed (initially the drawdown amount).
    uint256 public principalPaid;   // The amount of principal that has  been paid     by the Borrower since the Loan instantiation.
    uint256 public interestPaid;    // The amount of interest  that has  been paid     by the Borrower since the Loan instantiation.
    uint256 public feePaid;         // The amount of fees      that have been paid     by the Borrower since the Loan instantiation.
    uint256 public excessReturned;  // The amount of excess    that has  been returned to the Lenders  after the Loan drawdown.

    // Liquidation variables
    uint256 public amountLiquidated;   // The amount of Collateral Asset that has been liquidated after default.
    uint256 public amountRecovered;    // The amount of Liquidity Asset  that has been recovered  after default.
    uint256 public defaultSuffered;    // The difference between `amountRecovered` and `principalOwed` after liquidation.
    uint256 public liquidationExcess;  // If `amountRecovered > principalOwed`, this is the amount of Liquidity Asset that is to be returned to the Borrower.

    event       LoanFunded(address indexed fundedBy, uint256 amountFunded);
    event   BalanceUpdated(address indexed account, address indexed token, uint256 balance);
    event         Drawdown(uint256 drawdownAmount);
    event LoanStateChanged(State state);
    event     LoanAdminSet(address indexed loanAdmin, bool allowed);
    
    event PaymentMade(
        uint256 totalPaid,
        uint256 principalPaid,
        uint256 interestPaid,
        uint256 paymentsRemaining,
        uint256 principalOwed,
        uint256 nextPaymentDue,
        bool latePayment
    );
    
    event Liquidation(
        uint256 collateralSwapped,
        uint256 liquidityAssetReturned,
        uint256 liquidationExcess,
        uint256 defaultSuffered
    );

    /**
        @dev    Constructor for a Loan.
        @dev    It emits a `LoanStateChanged` event.
        @param  _borrower        Will receive the funding when calling `drawdown()`. Is also responsible for repayments.
        @param  _liquidityAsset  The asset the Borrower is requesting funding in.
        @param  _collateralAsset The asset provided as collateral by the Borrower.
        @param  _flFactory       Factory to instantiate FundingLocker with.
        @param  _clFactory       Factory to instantiate CollateralLocker with.
        @param  specs            Contains specifications for this Loan.
                                     specs[0] = apr
                                     specs[1] = termDays
                                     specs[2] = paymentIntervalDays (aka PID)
                                     specs[3] = requestAmount
                                     specs[4] = collateralRatio
        @param  calcs            The calculators used for this Loan.
                                     calcs[0] = repaymentCalc
                                     calcs[1] = lateFeeCalc
                                     calcs[2] = premiumCalc
    */
    constructor(
        address _borrower,
        address _liquidityAsset,
        address _collateralAsset,
        address _flFactory,
        address _clFactory,
        uint256[5] memory specs,
        address[3] memory calcs
    ) LoanFDT("Maple Loan Token", "MPL-LOAN", _liquidityAsset) public {
        IMapleGlobals globals = _globals(msg.sender);

        // Perform validity cross-checks.
        LoanLib.loanSanityChecks(globals, _liquidityAsset, _collateralAsset, specs);

        borrower        = _borrower;
        liquidityAsset  = IERC20(_liquidityAsset);
        collateralAsset = IERC20(_collateralAsset);
        flFactory       = _flFactory;
        clFactory       = _clFactory;
        createdAt       = block.timestamp;

        // Update state variables.
        apr                    = specs[0];
        termDays               = specs[1];
        paymentsRemaining      = specs[1].div(specs[2]);
        paymentIntervalSeconds = specs[2].mul(1 days);
        requestAmount          = specs[3];
        collateralRatio        = specs[4];
        fundingPeriod          = globals.fundingPeriod();
        defaultGracePeriod     = globals.defaultGracePeriod();
        repaymentCalc          = calcs[0];
        lateFeeCalc            = calcs[1];
        premiumCalc            = calcs[2];
        superFactory           = msg.sender;

        // Deploy lockers.
        collateralLocker = ICollateralLockerFactory(_clFactory).newLocker(_collateralAsset);
        fundingLocker    = IFundingLockerFactory(_flFactory).newLocker(_liquidityAsset);
        emit LoanStateChanged(State.Ready);
    }

    /**************************/
    /*** Borrower Functions ***/
    /**************************/

    /**
        @dev   Draws down funding from FundingLocker, posts collateral, and transitions the Loan state from `Ready` to `Active`. Only the Borrower can call this function.
        @dev   It emits four `BalanceUpdated` events.
        @dev   It emits a `LoanStateChanged` event.
        @dev   It emits a `Drawdown` event.
        @param amt Amount of Liquidity Asset the Borrower draws down. Remainder is returned to the Loan where it can be claimed back by LoanFDT holders.
    */
    function drawdown(uint256 amt) external {
        _whenProtocolNotPaused();
        _isValidBorrower();
        _isValidState(State.Ready);
        IMapleGlobals globals = _globals(superFactory);

        IFundingLocker _fundingLocker = IFundingLocker(fundingLocker);

        require(amt >= requestAmount,              "L:AMT_LT_REQUEST_AMT");
        require(amt <= _getFundingLockerBalance(), "L:AMT_GT_FUNDED_AMT");

        // Update accounting variables for the Loan.
        principalOwed  = amt;
        nextPaymentDue = block.timestamp.add(paymentIntervalSeconds);

        loanState = State.Active;

        // Transfer the required amount of collateral for drawdown from the Borrower to the CollateralLocker.
        collateralAsset.safeTransferFrom(borrower, collateralLocker, collateralRequiredForDrawdown(amt));

        // Transfer funding amount from the FundingLocker to the Borrower, then drain remaining funds to the Loan.
        uint256 treasuryFee = globals.treasuryFee();
        uint256 investorFee = globals.investorFee();

        address treasury = globals.mapleTreasury();

        uint256 _feePaid = feePaid = amt.mul(investorFee).div(10_000);  // Update fees paid for `claim()`.
        uint256 treasuryAmt        = amt.mul(treasuryFee).div(10_000);  // Calculate amount to send to the MapleTreasury.

        _transferFunds(_fundingLocker, treasury, treasuryAmt);                         // Send the treasury fee directly to the MapleTreasury.
        _transferFunds(_fundingLocker, borrower, amt.sub(treasuryAmt).sub(_feePaid));  // Transfer drawdown amount to the Borrower.

        // Update excessReturned for `claim()`. 
        excessReturned = _getFundingLockerBalance().sub(_feePaid);

        // Drain remaining funds from the FundingLocker (amount equal to `excessReturned` plus `feePaid`)
        _fundingLocker.drain();

        // Call `updateFundsReceived()` update LoanFDT accounting with funds received from fees and excess returned.
        updateFundsReceived();

        _emitBalanceUpdateEventForCollateralLocker();
        _emitBalanceUpdateEventForFundingLocker();
        _emitBalanceUpdateEventForLoan();

        emit BalanceUpdated(treasury, address(liquidityAsset), liquidityAsset.balanceOf(treasury));
        emit LoanStateChanged(State.Active);
        emit Drawdown(amt);
    }

    /**
        @dev Makes a payment for this Loan. Amounts are calculated for the Borrower.
    */
    function makePayment() external {
        _whenProtocolNotPaused();
        _isValidState(State.Active);
        (uint256 total, uint256 principal, uint256 interest,, bool paymentLate) = getNextPayment();
        --paymentsRemaining;
        _makePayment(total, principal, interest, paymentLate);
    }

    /**
        @dev Makes the full payment for this Loan (a.k.a. "calling" the Loan). This requires the Borrower to pay a premium fee.
    */
    function makeFullPayment() external {
        _whenProtocolNotPaused();
        _isValidState(State.Active);
        (uint256 total, uint256 principal, uint256 interest) = getFullPayment();
        paymentsRemaining = uint256(0);
        _makePayment(total, principal, interest, false);
    }

    /**
        @dev Updates the payment variables and transfers funds from the Borrower into the Loan.
        @dev It emits one or two `BalanceUpdated` events (depending if payments remaining).
        @dev It emits a `LoanStateChanged` event if no payments remaining.
        @dev It emits a `PaymentMade` event.
    */
    function _makePayment(uint256 total, uint256 principal, uint256 interest, bool paymentLate) internal {

        // Caching to reduce `SLOADs`.
        uint256 _paymentsRemaining = paymentsRemaining;

        // Update internal accounting variables.
        interestPaid = interestPaid.add(interest);
        if (principal > uint256(0)) principalPaid = principalPaid.add(principal);

        if (_paymentsRemaining > uint256(0)) {
            // Update info related to next payment and, if needed, decrement principalOwed.
            nextPaymentDue = nextPaymentDue.add(paymentIntervalSeconds);
            if (principal > uint256(0)) principalOwed = principalOwed.sub(principal);
        } else {
            // Update info to close loan.
            principalOwed  = uint256(0);
            loanState      = State.Matured;
            nextPaymentDue = uint256(0);

            // Transfer all collateral back to the Borrower.
            ICollateralLocker(collateralLocker).pull(borrower, _getCollateralLockerBalance());
            _emitBalanceUpdateEventForCollateralLocker();
            emit LoanStateChanged(State.Matured);
        }

        // Loan payer sends funds to the Loan.
        liquidityAsset.safeTransferFrom(msg.sender, address(this), total);

        // Update FDT accounting with funds received from interest payment.
        updateFundsReceived();

        emit PaymentMade(
            total,
            principal,
            interest,
            _paymentsRemaining,
            principalOwed,
            _paymentsRemaining > 0 ? nextPaymentDue : 0,
            paymentLate
        );

        _emitBalanceUpdateEventForLoan();
    }

    /************************/
    /*** Lender Functions ***/
    /************************/

    /**
        @dev   Funds this Loan and mints LoanFDTs for `mintTo` (DebtLocker in the case of Pool funding).
               Only LiquidityLocker using valid/approved Pool can call this function.
        @dev   It emits a `LoanFunded` event.
        @dev   It emits a `BalanceUpdated` event.
        @param amt    Amount to fund the Loan.
        @param mintTo Address that LoanFDTs are minted to.
    */
    function fundLoan(address mintTo, uint256 amt) whenNotPaused external {
        _whenProtocolNotPaused();
        _isValidState(State.Ready);
        _isValidPool();
        _isWithinFundingPeriod();
        liquidityAsset.safeTransferFrom(msg.sender, fundingLocker, amt);

        uint256 wad = _toWad(amt);  // Convert to WAD precision.
        _mint(mintTo, wad);         // Mint LoanFDTs to `mintTo` (i.e DebtLocker contract).

        emit LoanFunded(mintTo, amt);
        _emitBalanceUpdateEventForFundingLocker();
    }

    /**
        @dev Handles returning capital to the Loan, where it can be claimed back by LoanFDT holders,
             if the Borrower has not drawn down on the Loan past the drawdown grace period.
        @dev It emits a `LoanStateChanged` event.
    */
    function unwind() external {
        _whenProtocolNotPaused();
        _isValidState(State.Ready);

        // Update accounting for `claim()` and transfer funds from FundingLocker to Loan.
        excessReturned = LoanLib.unwind(liquidityAsset, fundingLocker, createdAt, fundingPeriod);

        updateFundsReceived();

        // Transition state to `Expired`.
        loanState = State.Expired;
        emit LoanStateChanged(State.Expired);
    }

    /**
        @dev Triggers a default if the Loan meets certain default conditions, liquidating all collateral and updating accounting.
             Only the an account with sufficient LoanFDTs of this Loan can call this function.
        @dev It emits a `BalanceUpdated` event.
        @dev It emits a `Liquidation` event.
        @dev It emits a `LoanStateChanged` event.
    */
    function triggerDefault() external {
        _whenProtocolNotPaused();
        _isValidState(State.Active);
        require(LoanLib.canTriggerDefault(nextPaymentDue, defaultGracePeriod, superFactory, balanceOf(msg.sender), totalSupply()), "L:FAILED_TO_LIQ");

        // Pull the Collateral Asset from the CollateralLocker, swap to the Liquidity Asset, and hold custody of the resulting Liquidity Asset in the Loan.
        (amountLiquidated, amountRecovered) = LoanLib.liquidateCollateral(collateralAsset, address(liquidityAsset), superFactory, collateralLocker);
        _emitBalanceUpdateEventForCollateralLocker();

        // Decrement `principalOwed` by `amountRecovered`, set `defaultSuffered` to the difference (shortfall from the liquidation).
        if (amountRecovered <= principalOwed) {
            principalOwed   = principalOwed.sub(amountRecovered);
            defaultSuffered = principalOwed;
        }
        // Set `principalOwed` to zero and return excess value from the liquidation back to the Borrower.
        else {
            liquidationExcess = amountRecovered.sub(principalOwed);
            principalOwed = 0;
            liquidityAsset.safeTransfer(borrower, liquidationExcess);  // Send excess to the Borrower.
        }

        // Update LoanFDT accounting with funds received from the liquidation.
        updateFundsReceived();

        // Transition `loanState` to `Liquidated`
        loanState = State.Liquidated;

        emit Liquidation(
            amountLiquidated,  // Amount of Collateral Asset swapped.
            amountRecovered,   // Amount of Liquidity Asset recovered from swap.
            liquidationExcess, // Amount of Liquidity Asset returned to borrower.
            defaultSuffered    // Remaining losses after the liquidation.
        );
        emit LoanStateChanged(State.Liquidated);
    }

    /***********************/
    /*** Admin Functions ***/
    /***********************/

    /**
        @dev Triggers paused state. Halts functionality for certain functions. Only the Borrower or a Loan Admin can call this function.
    */
    function pause() external {
        _isValidBorrowerOrLoanAdmin();
        super._pause();
    }

    /**
        @dev Triggers unpaused state. Restores functionality for certain functions. Only the Borrower or a Loan Admin can call this function.
    */
    function unpause() external {
        _isValidBorrowerOrLoanAdmin();
        super._unpause();
    }

    /**
        @dev   Sets a Loan Admin. Only the Borrower can call this function.
        @dev   It emits a `LoanAdminSet` event.
        @param loanAdmin An address being allowed or disallowed as a Loan Admin.
        @param allowed   Status of a Loan Admin.
    */
    function setLoanAdmin(address loanAdmin, bool allowed) external {
        _whenProtocolNotPaused();
        _isValidBorrower();
        loanAdmins[loanAdmin] = allowed;
        emit LoanAdminSet(loanAdmin, allowed);
    }

    /**************************/
    /*** Governor Functions ***/
    /**************************/

    /**
        @dev   Transfers any locked funds to the Governor. Only the Governor can call this function.
        @param token Address of the token to be reclaimed.
    */
    function reclaimERC20(address token) external {
        LoanLib.reclaimERC20(token, address(liquidityAsset), _globals(superFactory));
    }

    /*********************/
    /*** FDT Functions ***/
    /*********************/

    /**
        @dev Withdraws all available funds earned through LoanFDT for a token holder.
        @dev It emits a `BalanceUpdated` event.
    */
    function withdrawFunds() public override {
        _whenProtocolNotPaused();
        super.withdrawFunds();
        emit BalanceUpdated(address(this), address(fundsToken), fundsToken.balanceOf(address(this)));
    }

    /************************/
    /*** Getter Functions ***/
    /************************/

    /**
        @dev    Returns the expected amount of Liquidity Asset to be recovered from a liquidation based on current oracle prices.
        @return The minimum amount of Liquidity Asset that can be expected by swapping Collateral Asset.
    */
    function getExpectedAmountRecovered() external view returns (uint256) {
        uint256 liquidationAmt = _getCollateralLockerBalance();
        return Util.calcMinAmount(_globals(superFactory), address(collateralAsset), address(liquidityAsset), liquidationAmt);
    }

    /**
        @dev    Returns information of the next payment amount.
        @return [0] = Entitled interest of the next payment (Principal + Interest only when the next payment is last payment of the Loan)
                [1] = Entitled principal amount needed to be paid in the next payment
                [2] = Entitled interest amount needed to be paid in the next payment
                [3] = Payment Due Date
                [4] = Is Payment Late
    */
    function getNextPayment() public view returns (uint256, uint256, uint256, uint256, bool) {
        return LoanLib.getNextPayment(repaymentCalc, nextPaymentDue, lateFeeCalc);
    }

    /**
        @dev    Returns the information of a full payment amount.
        @return total     Principal and interest owed, combined.
        @return principal Principal owed.
        @return interest  Interest owed.
    */
    function getFullPayment() public view returns (uint256 total, uint256 principal, uint256 interest) {
        (total, principal, interest) = LoanLib.getFullPayment(repaymentCalc, nextPaymentDue, lateFeeCalc, premiumCalc);
    }

    /**
        @dev    Calculates the collateral required to draw down amount.
        @param  amt The amount of the Liquidity Asset to draw down from the FundingLocker.
        @return The amount of the Collateral Asset required to post in the CollateralLocker for a given drawdown amount.
    */
    function collateralRequiredForDrawdown(uint256 amt) public view returns (uint256) {
        return LoanLib.collateralRequiredForDrawdown(
            IERC20Details(address(collateralAsset)),
            IERC20Details(address(liquidityAsset)),
            collateralRatio,
            superFactory,
            amt
        );
    }

    /************************/
    /*** Helper Functions ***/
    /************************/

    /**
        @dev Checks that the protocol is not in a paused state.
    */
    function _whenProtocolNotPaused() internal view {
        require(!_globals(superFactory).protocolPaused(), "L:PROTO_PAUSED");
    }

    /**
        @dev Checks that `msg.sender` is the Borrower or a Loan Admin.
    */
    function _isValidBorrowerOrLoanAdmin() internal view {
        require(msg.sender == borrower || loanAdmins[msg.sender], "L:NOT_BORROWER_OR_ADMIN");
    }

    /**
        @dev Converts to WAD precision.
    */
    function _toWad(uint256 amt) internal view returns (uint256) {
        return amt.mul(10 ** 18).div(10 ** IERC20Details(address(liquidityAsset)).decimals());
    }

    /**
        @dev Returns the MapleGlobals instance.
    */
    function _globals(address loanFactory) internal view returns (IMapleGlobals) {
        return IMapleGlobals(ILoanFactory(loanFactory).globals());
    }

    /**
        @dev Returns the CollateralLocker balance.
    */
    function _getCollateralLockerBalance() internal view returns (uint256) {
        return collateralAsset.balanceOf(collateralLocker);
    }

    /**
        @dev Returns the FundingLocker balance.
    */
    function _getFundingLockerBalance() internal view returns (uint256) {
        return liquidityAsset.balanceOf(fundingLocker);
    }

    /**
        @dev   Checks that the current state of the Loan matches the provided state.
        @param _state Enum of desired Loan state.
    */
    function _isValidState(State _state) internal view {
        require(loanState == _state, "L:INVALID_STATE");
    }

    /**
        @dev Checks that `msg.sender` is the Borrower.
    */
    function _isValidBorrower() internal view {
        require(msg.sender == borrower, "L:NOT_BORROWER");
    }

    /**
        @dev Checks that `msg.sender` is a Lender (LiquidityLocker) that is using an approved Pool to fund the Loan.
    */
    function _isValidPool() internal view {
        address pool        = ILiquidityLocker(msg.sender).pool();
        address poolFactory = IPool(pool).superFactory();
        require(
            _globals(superFactory).isValidPoolFactory(poolFactory) &&
            IPoolFactory(poolFactory).isPool(pool),
            "L:INVALID_LENDER"
        );
    }

    /**
        @dev Checks that "now" is currently within the funding period.
    */
    function _isWithinFundingPeriod() internal view {
        require(block.timestamp <= createdAt.add(fundingPeriod), "L:PAST_FUNDING_PERIOD");
    }

    /**
        @dev   Transfers funds from the FundingLocker.
        @param from  Instance of the FundingLocker.
        @param to    Address to send funds to.
        @param value Amount to send.
    */
    function _transferFunds(IFundingLocker from, address to, uint256 value) internal {
        from.pull(to, value);
    }

    /**
        @dev Emits a `BalanceUpdated` event for the Loan.
        @dev It emits a `BalanceUpdated` event.
    */
    function _emitBalanceUpdateEventForLoan() internal {
        emit BalanceUpdated(address(this), address(liquidityAsset), liquidityAsset.balanceOf(address(this)));
    }

    /**
        @dev Emits a `BalanceUpdated` event for the FundingLocker.
        @dev It emits a `BalanceUpdated` event.
    */
    function _emitBalanceUpdateEventForFundingLocker() internal {
        emit BalanceUpdated(fundingLocker, address(liquidityAsset), _getFundingLockerBalance());
    }

    /**
        @dev Emits a `BalanceUpdated` event for the CollateralLocker.
        @dev It emits a `BalanceUpdated` event.
    */
    function _emitBalanceUpdateEventForCollateralLocker() internal {
        emit BalanceUpdated(collateralLocker, address(collateralAsset), _getCollateralLockerBalance());
    }

}