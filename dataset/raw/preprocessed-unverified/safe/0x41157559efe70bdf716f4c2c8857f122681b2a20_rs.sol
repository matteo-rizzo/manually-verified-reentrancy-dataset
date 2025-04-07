/**
 *Submitted for verification at Etherscan.io on 2021-04-19
*/

// File: contracts/BondToken_and_GDOTC/util/TransferETHInterface.sol

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.7.1;



// File: @openzeppelin/contracts/token/ERC20/IERC20.sol





/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


// File: contracts/BondToken_and_GDOTC/bondToken/BondTokenInterface.sol






interface BondTokenInterface is IERC20 {
    event LogExpire(uint128 rateNumerator, uint128 rateDenominator, bool firstTime);

    function mint(address account, uint256 amount) external returns (bool success);

    function expire(uint128 rateNumerator, uint128 rateDenominator)
        external
        returns (bool firstTime);

    function simpleBurn(address account, uint256 amount) external returns (bool success);

    function burn(uint256 amount) external returns (bool success);

    function burnAll() external returns (uint256 amount);

    function getRate() external view returns (uint128 rateNumerator, uint128 rateDenominator);
}

// File: contracts/BondToken_and_GDOTC/oracle/LatestPriceOracleInterface.sol




/**
 * @dev Interface of the price oracle.
 */


// File: contracts/BondToken_and_GDOTC/oracle/PriceOracleInterface.sol





/**
 * @dev Interface of the price oracle.
 */
interface PriceOracleInterface is LatestPriceOracleInterface {
    /**
     * @dev Returns the latest id. The id start from 1 and increments by 1.
     */
    function latestId() external returns (uint256);

    /**
     * @dev Returns the historical price specified by `id`. Decimals is 8.
     */
    function getPrice(uint256 id) external returns (uint256);

    /**
     * @dev Returns the timestamp of historical price specified by `id`.
     */
    function getTimestamp(uint256 id) external returns (uint256);
}

// File: contracts/BondToken_and_GDOTC/bondMaker/BondMakerInterface.sol








// File: contracts/contracts/Interfaces/StrategyInterface.sol







// File: contracts/contracts/Interfaces/SimpleAggragatorInterface.sol


pragma experimental ABIEncoderV2;




// File: contracts/contracts/Interfaces/VolatilityOracleInterface.sol






// File: contracts/BondToken_and_GDOTC/bondPricer/Enums.sol




/**
    Pure SBT:
        ___________
       /
      /
     /
    /

    LBT Shape:
              /
             /
            /
           /
    ______/

    SBT Shape:
              ______
             /
            /
    _______/

    Triangle:
              /\
             /  \
            /    \
    _______/      \________
 */
enum BondType {NONE, PURE_SBT, SBT_SHAPE, LBT_SHAPE, TRIANGLE}

// File: contracts/BondToken_and_GDOTC/bondPricer/BondPricerInterface.sol







// File: @openzeppelin/contracts/GSN/Context.sol





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

// File: @openzeppelin/contracts/math/SafeMath.sol





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


// File: @openzeppelin/contracts/utils/Address.sol





/**
 * @dev Collection of functions related to the address type
 */


// File: @openzeppelin/contracts/token/ERC20/ERC20.sol









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

// File: contracts/contracts/Interfaces/ExchangeInterface.sol










// File: @openzeppelin/contracts/math/SignedSafeMath.sol





/**
 * @title SignedSafeMath
 * @dev Signed math operations with safety checks that revert on error.
 */


// File: @openzeppelin/contracts/utils/SafeCast.sol






/**
 * @dev Wrappers over Solidity's uintXX/intXX casting operators with added overflow
 * checks.
 *
 * Downcasting from uint256/int256 in Solidity does not revert on overflow. This can
 * easily result in undesired exploitation or bugs, since developers usually
 * assume that overflows raise errors. `SafeCast` restores this intuition by
 * reverting the transaction when such an operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 *
 * Can be combined with {SafeMath} and {SignedSafeMath} to extend it to smaller types, by performing
 * all math on `uint256` and `int256` and then downcasting.
 */


// File: contracts/BondToken_and_GDOTC/math/UseSafeMath.sol







/**
 * @notice ((a - 1) / b) + 1 = (a + b -1) / b
 * for example a.add(10**18 -1).div(10**18) = a.sub(1).div(10**18) + 1
 */



/**
 * @title UseSafeMath
 * @dev One can use SafeMath for not only uint256 but also uin64 or uint16,
 * and also can use SafeCast for uint256.
 * For example:
 *   uint64 a = 1;
 *   uint64 b = 2;
 *   a = a.add(b).toUint64() // `a` become 3 as uint64
 * In addition, one can use SignedSafeMath and SafeCast.toUint256(int256) for int256.
 * In the case of the operation to the uint64 value, one needs to cast the value into int256 in
 * advance to use `sub` as SignedSafeMath.sub not SafeMath.sub.
 * For example:
 *   int256 a = 1;
 *   uint64 b = 2;
 *   int256 c = 3;
 *   a = a.add(int256(b).sub(c)); // `a` becomes 0 as int256
 *   b = a.toUint256().toUint64(); // `b` becomes 0 as uint64
 */
abstract contract UseSafeMath {
    using SafeMath for uint256;
    using SafeMathDivRoundUp for uint256;
    using SafeMath for uint64;
    using SafeMathDivRoundUp for uint64;
    using SafeMath for uint16;
    using SignedSafeMath for int256;
    using SafeCast for uint256;
    using SafeCast for int256;
}

// File: contracts/BondToken_and_GDOTC/math/AdvancedMath.sol




abstract contract AdvancedMath {
    /**
     * @dev sqrt(2*PI) * 10^8
     */
    int256 internal constant SQRT_2PI_E8 = 250662827;
    int256 internal constant PI_E8 = 314159265;
    int256 internal constant E_E8 = 271828182;
    int256 internal constant INV_E_E8 = 36787944; // 1/e
    int256 internal constant LOG2_E8 = 30102999;
    int256 internal constant LOG3_E8 = 47712125;

    int256 internal constant p = 23164190;
    int256 internal constant b1 = 31938153;
    int256 internal constant b2 = -35656378;
    int256 internal constant b3 = 178147793;
    int256 internal constant b4 = -182125597;
    int256 internal constant b5 = 133027442;

    /**
     * @dev Calcurate an approximate value of the square root of x by Babylonian method.
     */
    function _sqrt(int256 x) internal pure returns (int256 y) {
        require(x >= 0, "cannot calculate the square root of a negative number");
        int256 z = (x + 1) / 2;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
    }

    /**
     * @dev Returns log(x) for any positive x.
     */
    function _logTaylor(int256 inputE4) internal pure returns (int256 outputE4) {
        require(inputE4 > 1, "input should be positive number");
        int256 inputE8 = inputE4 * 10**4;
        // input x for _logTayler1 is adjusted to 1/e < x < 1.
        while (inputE8 < INV_E_E8) {
            inputE8 = (inputE8 * E_E8) / 10**8;
            outputE4 -= 10**4;
        }
        while (inputE8 > 10**8) {
            inputE8 = (inputE8 * INV_E_E8) / 10**8;
            outputE4 += 10**4;
        }
        outputE4 += _logTaylor1(inputE8 / 10**4 - 10**4);
    }

    /**
     * @notice Calculate an approximate value of the logarithm of input value by
     * Taylor expansion around 1.
     * @dev log(x + 1) = x - 1/2 x^2 + 1/3 x^3 - 1/4 x^4 + 1/5 x^5
     *                     - 1/6 x^6 + 1/7 x^7 - 1/8 x^8 + ...
     */
    function _logTaylor1(int256 inputE4) internal pure returns (int256 outputE4) {
        outputE4 =
            inputE4 -
            inputE4**2 /
            (2 * 10**4) +
            inputE4**3 /
            (3 * 10**8) -
            inputE4**4 /
            (4 * 10**12) +
            inputE4**5 /
            (5 * 10**16) -
            inputE4**6 /
            (6 * 10**20) +
            inputE4**7 /
            (7 * 10**24) -
            inputE4**8 /
            (8 * 10**28);
    }

    /**
     * @notice Calculate the cumulative distribution function of standard normal
     * distribution.
     * @dev Abramowitz and Stegun, Handbook of Mathematical Functions (1964)
     * http://people.math.sfu.ca/~cbm/aands/
     */
    function _calcPnorm(int256 inputE4) internal pure returns (int256 outputE8) {
        require(inputE4 < 440 * 10**4 && inputE4 > -440 * 10**4, "input is too large");
        int256 _inputE4 = inputE4 > 0 ? inputE4 : inputE4 * (-1);
        int256 t = 10**16 / (10**8 + (p * _inputE4) / 10**4);
        int256 X2 = (inputE4 * inputE4) / 2;
        int256 exp2X2 = 10**8 +
            X2 +
            (X2**2 / (2 * 10**8)) +
            (X2**3 / (6 * 10**16)) +
            (X2**4 / (24 * 10**24)) +
            (X2**5 / (120 * 10**32)) +
            (X2**6 / (720 * 10**40));
        int256 Z = (10**24 / exp2X2) / SQRT_2PI_E8;
        int256 y = (b5 * t) / 10**8;
        y = ((y + b4) * t) / 10**8;
        y = ((y + b3) * t) / 10**8;
        y = ((y + b2) * t) / 10**8;
        y = 10**8 - (Z * ((y + b1) * t)) / 10**16;
        return inputE4 > 0 ? y : 10**8 - y;
    }
}

// File: contracts/BondToken_and_GDOTC/bondPricer/GeneralizedPricing.sol







/**
 * @dev The decimals of price, point, spotPrice and strikePrice are all the same.
 */
contract GeneralizedPricing is AdvancedMath {
    using SafeMath for uint256;

    /**
     * @dev sqrt(365*86400) * 10^8
     */
    int256 internal constant SQRT_YEAR_E8 = 5615.69229926 * 10**8;

    int256 internal constant MIN_ND1_E8 = 0.0001 * 10**8;
    int256 internal constant MAX_ND1_E8 = 0.9999 * 10**8;
    uint256 internal constant MAX_LEVERAGE_E8 = 1000 * 10**8;

    /**
     * @notice Calculate bond price and leverage by black-scholes formula.
     * @param bondType type of target bond.
     * @param points coodinates of polyline which is needed for price calculation
     * @param untilMaturity Remaining period of target bond in second
     **/
    function calcPriceAndLeverage(
        BondType bondType,
        uint256[] memory points,
        int256 spotPrice,
        int256 volatilityE8,
        int256 untilMaturity
    ) public pure returns (uint256 price, uint256 leverageE8) {
        if (bondType == BondType.LBT_SHAPE) {
            (price, leverageE8) = _calcLbtShapePriceAndLeverage(
                points,
                spotPrice,
                volatilityE8,
                untilMaturity
            );
        } else if (bondType == BondType.SBT_SHAPE) {
            (price, leverageE8) = _calcSbtShapePrice(
                points,
                spotPrice,
                volatilityE8,
                untilMaturity
            );
        } else if (bondType == BondType.TRIANGLE) {
            (price, leverageE8) = _calcTrianglePrice(
                points,
                spotPrice,
                volatilityE8,
                untilMaturity
            );
        } else if (bondType == BondType.PURE_SBT) {
            (price, leverageE8) = _calcPureSBTPrice(points, spotPrice, volatilityE8, untilMaturity);
        }
    }

    /**
     * @notice Calculate pure call option price and multiply incline of LBT.
     **/

    function _calcLbtShapePriceAndLeverage(
        uint256[] memory points,
        int256 spotPrice,
        int256 volatilityE8,
        int256 untilMaturity
    ) internal pure returns (uint256 price, uint256 leverageE8) {
        require(points.length == 3, "3 coordinates is needed for LBT price calculation");
        uint256 inclineE8 = (points[2].mul(10**8)).div(points[1].sub(points[0]));
        (uint256 callOptionPriceE8, int256 nd1E8) = calcCallOptionPrice(
            spotPrice,
            int256(points[0]),
            volatilityE8,
            untilMaturity
        );
        price = (callOptionPriceE8 * inclineE8) / 10**8;
        leverageE8 = _calcLbtLeverage(
            uint256(spotPrice),
            price,
            (nd1E8 * int256(inclineE8)) / 10**8
        );
    }

    /**
     * @notice Calculate (etherPrice - call option price at strike price of SBT).
     **/
    function _calcPureSBTPrice(
        uint256[] memory points,
        int256 spotPrice,
        int256 volatilityE8,
        int256 untilMaturity
    ) internal pure returns (uint256 price, uint256 leverageE8) {
        require(points.length == 1, "1 coordinate is needed for pure SBT price calculation");
        (uint256 callOptionPrice1, int256 nd1E8) = calcCallOptionPrice(
            spotPrice,
            int256(points[0]),
            volatilityE8,
            untilMaturity
        );
        price = uint256(spotPrice) > callOptionPrice1 ? (uint256(spotPrice) - callOptionPrice1) : 0;
        leverageE8 = _calcLbtLeverage(uint256(spotPrice), price, 10**8 - nd1E8);
    }

    /**
     * @notice Calculate (call option1  - call option2) * incline of SBT.

              ______                 /
             /                      /
            /          =           /        -                   /
    _______/               _______/                 ___________/
    SBT SHAPE BOND         CALL OPTION 1            CALL OPTION 2
     **/
    function _calcSbtShapePrice(
        uint256[] memory points,
        int256 spotPrice,
        int256 volatilityE8,
        int256 untilMaturity
    ) internal pure returns (uint256 price, uint256 leverageE8) {
        require(points.length == 3, "3 coordinates is needed for SBT price calculation");
        uint256 inclineE8 = (points[2].mul(10**8)).div(points[1].sub(points[0]));
        (uint256 callOptionPrice1, int256 nd11E8) = calcCallOptionPrice(
            spotPrice,
            int256(points[0]),
            volatilityE8,
            untilMaturity
        );
        (uint256 callOptionPrice2, int256 nd12E8) = calcCallOptionPrice(
            spotPrice,
            int256(points[1]),
            volatilityE8,
            untilMaturity
        );
        price = callOptionPrice1 > callOptionPrice2
            ? (inclineE8 * (callOptionPrice1 - callOptionPrice2)) / 10**8
            : 0;
        leverageE8 = _calcLbtLeverage(
            uint256(spotPrice),
            price,
            (int256(inclineE8) * (nd11E8 - nd12E8)) / 10**8
        );
    }

    /**
      * @notice Calculate (call option1 * left incline) - (call option2 * (left incline + right incline)) + (call option3 * right incline).

                                                                   /
                                                                  /
                                                                 /
              /\                            /                    \
             /  \                          /                      \
            /    \            =           /     -                  \          +
    _______/      \________       _______/               _______    \             __________________
                                                                     \                          \
                                                                      \                          \

    **/
    function _calcTrianglePrice(
        uint256[] memory points,
        int256 spotPrice,
        int256 volatilityE8,
        int256 untilMaturity
    ) internal pure returns (uint256 price, uint256 leverageE8) {
        require(
            points.length == 4,
            "4 coordinates is needed for triangle option price calculation"
        );
        uint256 incline1E8 = (points[2].mul(10**8)).div(points[1].sub(points[0]));
        uint256 incline2E8 = (points[2].mul(10**8)).div(points[3].sub(points[1]));
        (uint256 callOptionPrice1, int256 nd11E8) = calcCallOptionPrice(
            spotPrice,
            int256(points[0]),
            volatilityE8,
            untilMaturity
        );
        (uint256 callOptionPrice2, int256 nd12E8) = calcCallOptionPrice(
            spotPrice,
            int256(points[1]),
            volatilityE8,
            untilMaturity
        );
        (uint256 callOptionPrice3, int256 nd13E8) = calcCallOptionPrice(
            spotPrice,
            int256(points[3]),
            volatilityE8,
            untilMaturity
        );
        int256 nd1E8 = ((nd11E8 * int256(incline1E8)) +
            (nd13E8 * int256(incline2E8)) -
            (int256(incline1E8 + incline2E8) * nd12E8)) / 10**8;

        uint256 price12 = (callOptionPrice1 * incline1E8) + (callOptionPrice3 * incline2E8);
        price = price12 > (incline1E8 + incline2E8) * callOptionPrice2
            ? (price12 - ((incline1E8 + incline2E8) * callOptionPrice2)) / 10**8
            : 0;
        leverageE8 = _calcLbtLeverage(uint256(spotPrice), price, nd1E8);
    }

    /**
     * @dev calcCallOptionPrice() imposes the restrictions of strikePrice, spotPrice, nd1E8 and nd2E8.
     */
    function _calcLbtPrice(
        int256 spotPrice,
        int256 strikePrice,
        int256 nd1E8,
        int256 nd2E8
    ) internal pure returns (int256 lbtPrice) {
        int256 lowestPrice = (spotPrice > strikePrice) ? spotPrice - strikePrice : 0;
        lbtPrice = (spotPrice * nd1E8 - strikePrice * nd2E8) / 10**8;
        if (lbtPrice < lowestPrice) {
            lbtPrice = lowestPrice;
        }
    }

    /**
     * @dev calcCallOptionPrice() imposes the restrictions of spotPrice, lbtPrice and nd1E8.
     */
    function _calcLbtLeverage(
        uint256 spotPrice,
        uint256 lbtPrice,
        int256 nd1E8
    ) internal pure returns (uint256 lbtLeverageE8) {
        int256 modifiedNd1E8 = nd1E8 < MIN_ND1_E8 ? MIN_ND1_E8 : nd1E8 > MAX_ND1_E8
            ? MAX_ND1_E8
            : nd1E8;
        return lbtPrice != 0 ? (uint256(modifiedNd1E8) * spotPrice) / lbtPrice : MAX_LEVERAGE_E8;
    }

    /**
     * @notice Calculate pure call option price and N(d1) by black-scholes formula.
     * @param spotPrice is a oracle price.
     * @param strikePrice Strike price of call option
     * @param volatilityE8 is a oracle volatility.
     * @param untilMaturity Remaining period of target bond in second
     **/
    function calcCallOptionPrice(
        int256 spotPrice,
        int256 strikePrice,
        int256 volatilityE8,
        int256 untilMaturity
    ) public pure returns (uint256 price, int256 nd1E8) {
        require(spotPrice > 0 && spotPrice < 10**13, "oracle price should be between 0 and 10^13");
        require(
            volatilityE8 > 0 && volatilityE8 < 10 * 10**8,
            "oracle volatility should be between 0% and 1000%"
        );
        require(
            untilMaturity > 0 && untilMaturity < 31536000,
            "the bond should not have expired and less than 1 year"
        );
        require(
            strikePrice > 0 && strikePrice < 10**13,
            "strike price should be between 0 and 10^13"
        );

        int256 spotPerStrikeE4 = (spotPrice * 10**4) / strikePrice;
        int256 sigE8 = (volatilityE8 * (_sqrt(untilMaturity)) * (10**8)) / SQRT_YEAR_E8;

        int256 logSigE4 = _logTaylor(spotPerStrikeE4);
        int256 d1E4 = ((logSigE4 * 10**8) / sigE8) + (sigE8 / (2 * 10**4));
        nd1E8 = _calcPnorm(d1E4);

        int256 d2E4 = d1E4 - (sigE8 / 10**4);
        int256 nd2E8 = _calcPnorm(d2E4);
        price = uint256(_calcLbtPrice(spotPrice, strikePrice, nd1E8, nd2E8));
    }
}

// File: contracts/BondToken_and_GDOTC/bondPricer/CustomGeneralizedPricing.sol






abstract contract CustomGeneralizedPricing is BondPricerInterface {
    using SafeMath for uint256;

    GeneralizedPricing internal immutable _originalBondPricerAddress;

    constructor(address originalBondPricerAddress) {
        _originalBondPricerAddress = GeneralizedPricing(originalBondPricerAddress);
    }

    function calcPriceAndLeverage(
        BondType bondType,
        uint256[] calldata points,
        int256 spotPrice,
        int256 volatilityE8,
        int256 untilMaturity
    ) external view override returns (uint256 price, uint256 leverageE8) {
        (price, leverageE8) = _originalBondPricerAddress.calcPriceAndLeverage(
            bondType,
            points,
            spotPrice,
            volatilityE8,
            untilMaturity
        );
        if (bondType == BondType.LBT_SHAPE) {
            require(
                _isAcceptableLbt(points, spotPrice, volatilityE8, untilMaturity, price, leverageE8),
                "the liquid bond is not acceptable"
            );
        } else if (bondType == BondType.SBT_SHAPE) {
            require(
                _isAcceptableSbt(points, spotPrice, volatilityE8, untilMaturity, price, leverageE8),
                "the solid bond is not acceptable"
            );
        } else if (bondType == BondType.TRIANGLE) {
            require(
                _isAcceptableTriangleBond(
                    points,
                    spotPrice,
                    volatilityE8,
                    untilMaturity,
                    price,
                    leverageE8
                ),
                "the triangle bond is not acceptable"
            );
        } else if (bondType == BondType.PURE_SBT) {
            require(
                _isAcceptablePureSbt(
                    points,
                    spotPrice,
                    volatilityE8,
                    untilMaturity,
                    price,
                    leverageE8
                ),
                "the pure solid bond is not acceptable"
            );
        } else {
            require(
                _isAcceptableOtherBond(
                    points,
                    spotPrice,
                    volatilityE8,
                    untilMaturity,
                    price,
                    leverageE8
                ),
                "the bond is not acceptable"
            );
        }
    }

    function originalBondPricer() external view returns (address originalBondPricerAddress) {
        originalBondPricerAddress = address(_originalBondPricerAddress);
    }

    function _isAcceptableLbt(
        uint256[] memory points,
        int256 spotPrice,
        int256 volatilityE8,
        int256 untilMaturity,
        uint256 bondPrice,
        uint256 bondLeverageE8
    ) internal view virtual returns (bool);

    function _isAcceptableSbt(
        uint256[] memory points,
        int256 spotPrice,
        int256 volatilityE8,
        int256 untilMaturity,
        uint256 bondPrice,
        uint256 bondLeverageE8
    ) internal view virtual returns (bool);

    function _isAcceptableTriangleBond(
        uint256[] memory points,
        int256 spotPrice,
        int256 volatilityE8,
        int256 untilMaturity,
        uint256 bondPrice,
        uint256 bondLeverageE8
    ) internal view virtual returns (bool);

    function _isAcceptablePureSbt(
        uint256[] memory points,
        int256 spotPrice,
        int256 volatilityE8,
        int256 untilMaturity,
        uint256 bondPrice,
        uint256 bondLeverageE8
    ) internal view virtual returns (bool);

    function _isAcceptableOtherBond(
        uint256[] memory points,
        int256 spotPrice,
        int256 volatilityE8,
        int256 untilMaturity,
        uint256 bondPrice,
        uint256 bondLeverageE8
    ) internal view virtual returns (bool);
}

// File: @openzeppelin/contracts/access/Ownable.sol





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

// File: contracts/BondToken_and_GDOTC/util/Time.sol




abstract contract Time {
    function _getBlockTimestampSec() internal view returns (uint256 unixtimesec) {
        unixtimesec = block.timestamp; // solhint-disable-line not-rely-on-time
    }
}

// File: contracts/contracts/SimpleAggregator/BondPricerWithAcceptableMaturity.sol








contract BondPricerWithAcceptableMaturity is CustomGeneralizedPricing, Ownable, Time {
    using SafeMath for uint256;

    uint256 internal _acceptableMaturity;

    event LogUpdateAcceptableMaturity(uint256 acceptableMaturity);

    constructor(address originalBondPricerAddress)
        CustomGeneralizedPricing(originalBondPricerAddress)
    {
        _updateAcceptableMaturity(0);
    }

    function updateAcceptableMaturity(uint256 acceptableMaturity) external onlyOwner {
        _updateAcceptableMaturity(acceptableMaturity);
    }

    function getAcceptableMaturity() external view returns (uint256 acceptableMaturity) {
        acceptableMaturity = _acceptableMaturity;
    }

    function _updateAcceptableMaturity(uint256 acceptableMaturity) internal {
        _acceptableMaturity = acceptableMaturity;
        emit LogUpdateAcceptableMaturity(acceptableMaturity);
    }

    function _isAcceptableLbt(
        uint256[] memory,
        int256 etherPriceE8,
        int256 ethVolatilityE8,
        int256 untilMaturity,
        uint256,
        uint256
    ) internal view override returns (bool) {
        _isAcceptable(etherPriceE8, ethVolatilityE8, untilMaturity);
        return true;
    }

    function _isAcceptableSbt(
        uint256[] memory,
        int256 etherPriceE8,
        int256 ethVolatilityE8,
        int256 untilMaturity,
        uint256,
        uint256
    ) internal view override returns (bool) {
        _isAcceptable(etherPriceE8, ethVolatilityE8, untilMaturity);
        return true;
    }

    function _isAcceptableTriangleBond(
        uint256[] memory,
        int256 etherPriceE8,
        int256 ethVolatilityE8,
        int256 untilMaturity,
        uint256,
        uint256
    ) internal view override returns (bool) {
        _isAcceptable(etherPriceE8, ethVolatilityE8, untilMaturity);
        return true;
    }

    function _isAcceptablePureSbt(
        uint256[] memory,
        int256 etherPriceE8,
        int256 ethVolatilityE8,
        int256 untilMaturity,
        uint256,
        uint256
    ) internal view override returns (bool) {
        _isAcceptable(etherPriceE8, ethVolatilityE8, untilMaturity);
        return true;
    }

    function _isAcceptableOtherBond(
        uint256[] memory,
        int256,
        int256,
        int256,
        uint256,
        uint256
    ) internal pure override returns (bool) {
        revert("the bond is not pure SBT type");
    }

    /**
     * @notice Add this function to CustomGeneralizedPricing
     * When user sells bond which expired or whose maturity is after the aggregator's maturity, revert the transaction
     */
    function _isAcceptable(
        int256 etherPriceE8,
        int256 ethVolatilityE8,
        int256 untilMaturity
    ) internal view {
        require(
            etherPriceE8 > 0 && etherPriceE8 < 100000 * 10**8,
            "ETH price should be between $0 and $100000"
        );
        require(
            ethVolatilityE8 > 0 && ethVolatilityE8 < 10 * 10**8,
            "ETH volatility should be between 0% and 1000%"
        );
        require(untilMaturity >= 0, "the bond has been expired");
        require(untilMaturity <= 12 weeks, "the bond maturity must be less than 12 weeks");
        require(
            _getBlockTimestampSec().add(uint256(untilMaturity)) <= _acceptableMaturity,
            "the bond maturity must not exceed the current maturity of aggregator"
        );
    }
}

// File: contracts/contracts/Interfaces/BondRegistratorInterface.sol








// File: contracts/contracts/Interfaces/UseVolatilityOracle.sol







contract UseVolatilityOracle {
    using SafeMath for uint256;
    using SafeCast for uint256;
    VolatilityOracleInterface volOracle;

    constructor(VolatilityOracleInterface _volOracle) {
        volOracle = _volOracle;
    }

    function _getVolatility(uint256 maturity) internal view returns (uint256) {
        return volOracle.getVolatility(maturity.sub(block.timestamp).toUint64());
    }
}

// File: @openzeppelin/contracts/token/ERC20/SafeERC20.sol








/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */


// File: contracts/contracts/SimpleAggregator/SimpleAggregator.sol
















abstract contract SimpleAggregator is SimpleAggregatorInterface, UseVolatilityOracle {
    using SafeMath for uint256;
    using SafeCast for uint256;
    using SafeERC20 for ERC20;
    struct ReceivedCollateral {
        uint128 term;
        uint128 value;
    }
    struct UnRemovedToken {
        uint128 term;
        uint128 value;
    }
    struct LiquidationData {
        uint32 endBondGroupId;
        uint32 liquidatedBondGroupID;
        bool isLiquidated;
    }
    struct TermInfo {
        uint64 maturity;
        uint64 strikePrice;
        bytes32 SBTId;
    }
    struct ShareData {
        uint128 totalShare;
        uint128 totalCollateralPerToken;
    }
    struct BalanceData {
        uint128 balance;
        uint64 rewardAmount;
        uint64 term;
    }

    uint256 constant INFINITY = uint256(-1);
    uint256 constant COOLTIME = 3600 * 24 * 3;
    SimpleStrategyInterface internal immutable STRATEGY;
    ExchangeInterface internal immutable DOTC;
    ERC20 internal immutable REWARD_TOKEN;
    BondPricerWithAcceptableMaturity internal immutable BOND_PRICER;
    LatestPriceOracleInterface internal immutable ORACLE;
    BondMakerInterface internal immutable BONDMAKER;
    BondRegistratorInterface internal immutable BOND_REGISTRATOR;
    address internal immutable OWNER;
    bool internal immutable REVERSE_ORACLE;
    int16 internal constant MAX_SUPPLY_DENUMERATOR = 8;
    uint64 internal immutable BASE_PRICE_UNIT;

    mapping(uint256 => TermInfo) internal termInfo;

    mapping(uint256 => uint256[]) internal issuableBondGroupIds;
    mapping(uint256 => mapping(uint256 => uint256)) internal strikePriceToBondGroup;

    TotalReward[] internal totalRewards;
    // Aggregator Status
    mapping(uint256 => LiquidationData) internal liquidationData;
    mapping(uint256 => ShareData) internal shareData;
    uint256 internal currentTerm;
    uint64 internal priceUnit;
    uint64 internal lastTrancheTime;
    uint32 internal startBondGroupId = 1;
    int16 internal currentFeeBase;
    bool internal isTotalSupplyDanger;

    mapping(address => ReceivedCollateral) internal receivedCollaterals;
    mapping(address => UnRemovedToken) internal unremovedTokens;
    mapping(address => BalanceData) internal balance;
    mapping(address => mapping(address => uint128)) internal allowances;

    uint8 public constant override decimals = 8;
    string public constant override symbol = "LASH";
    string public constant override name = "LIEN_AGGREGATOR_SHARE";

    mapping(uint256 => uint128) internal totalReceivedCollateral;
    mapping(uint256 => uint128) internal totalUnremovedTokens;

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    event SetAddLiquidity(address indexed user, uint256 indexed term, uint256 collateralAmount);

    event SetRemoveLiquidity(address indexed user, uint256 indexed term, uint256 tokenAmount);

    event SettleLiquidity(
        address indexed user,
        uint256 indexed term,
        uint256 collateralAmount,
        uint256 tokenAmount
    );

    event TrancheBond(
        uint64 indexed issueBondGroupId,
        uint64 issueAmount,
        uint64 indexed burnBondGroupId,
        uint64 burnAmount
    );

    event UpdateMaturity(uint64 indexed term, int16 newFeeBase, uint64 maturity);

    event AddLiquidity(address indexed user, uint256 tokenAmount);

    modifier isActive() {
        require(block.timestamp <= termInfo[currentTerm].maturity, "Not active");
        _;
    }

    modifier endCoolTime() {
        require(block.timestamp > lastTrancheTime + COOLTIME, "Cool Time");
        _;
    }

    modifier afterMaturity() {
        require(block.timestamp > termInfo[currentTerm].maturity, "Not Matured");
        _;
    }

    modifier isRunning() {
        require(currentTerm != 0, "Not running");
        _;
    }

    // When collateralPerToken becomes very small value, total supply of share token can overflow
    modifier isSafeSupply() {
        require(!isTotalSupplyDanger, "Unsafe supply");
        _;
    }

    modifier onlyBonusProvider() {
        require(msg.sender == OWNER, "Only provider");
        _;
    }

    constructor(
        LatestPriceOracleInterface _oracle,
        BondPricerWithAcceptableMaturity _pricer,
        SimpleStrategyInterface _strategy,
        ERC20 _rewardToken,
        BondRegistratorInterface _registrator,
        ExchangeInterface _exchangeAddress,
        uint64 _priceUnit,
        uint64 _firstRewardRate,
        bool _reverseOracle,
        VolatilityOracleInterface _volOracle
    ) UseVolatilityOracle(_volOracle) {
        BONDMAKER = _exchangeAddress.bondMakerAddress();
        BOND_PRICER = _pricer;
        ORACLE = _oracle;
        BASE_PRICE_UNIT = _priceUnit;
        REVERSE_ORACLE = _reverseOracle;
        REWARD_TOKEN = _rewardToken;
        BOND_REGISTRATOR = _registrator;
        DOTC = _exchangeAddress;

        STRATEGY = _strategy;

        totalRewards.push(TotalReward(1, _firstRewardRate));
        priceUnit = _priceUnit;
        OWNER = msg.sender;
        require(
            _firstRewardRate >= 10**decimals && _firstRewardRate <= 1000000 * 10**decimals,
            "Out of range"
        );
    }

    /**
     * @notice Update maturity and strike price of SBT
     * Then, determine total amount of collateral asset and totalSupply of share token
     * Collateral asset to be withdrawn in `settleTokens()` is sent for reserve contract
     */
    function renewMaturity() public override {
        uint256 totalUnsentTokens;
        uint256 collateralPerTokenE8;
        uint256 _currentTerm = currentTerm;
        uint256 currentUnremoved = totalUnremovedTokens[_currentTerm];
        require(liquidationData[_currentTerm].isLiquidated || _currentTerm == 0, "Not expired yet");
        uint256 totalShare = shareData[_currentTerm].totalShare;
        if (totalShare > 0) {
            uint256 collateralAmount = getCollateralAmount();
            collateralPerTokenE8 = _applyDecimalGap(
                collateralAmount.mul(10**decimals).div(totalShare),
                true
            );
            totalUnsentTokens = _applyDecimalGap(
                uint256(totalReceivedCollateral[_currentTerm]).mul(10**decimals) /
                    collateralPerTokenE8,
                true
            );
        } else if (totalReceivedCollateral[_currentTerm] > 0) {
            totalUnsentTokens = _applyDecimalGap(totalReceivedCollateral[_currentTerm], true);
            collateralPerTokenE8 = 10**decimals;
        }

        uint256 _totalSupply = totalShare + totalUnsentTokens;
        shareData[_currentTerm + 1].totalCollateralPerToken = collateralPerTokenE8.toUint128();
        shareData[_currentTerm + 1].totalShare = uint256(totalShare)
            .add(totalUnsentTokens)
            .sub(currentUnremoved)
            .toUint128();

        if (
            shareData[_currentTerm + 1].totalShare >
            uint128(-1) / 10**uint128(MAX_SUPPLY_DENUMERATOR)
        ) {
            isTotalSupplyDanger = true;
        }

        if (_currentTerm != 0) {
            _updateFeeBase();
        }

        if (_totalSupply > 0 && currentUnremoved > 0) {
            _reserveAsset(collateralPerTokenE8);
        }
        _updateBondGroupData();

        emit UpdateMaturity(currentTerm.toUint64(), currentFeeBase, termInfo[currentTerm].maturity);
    }

    /**
     * @notice Update total reward token amount for one term
     * Only owner can call this function
     * @param rewardRate is restricted from 10**8 (1 LIEN) to 10**14 (total supply of Lien token)
     */
    function updateTotalReward(uint64 rewardRate) public onlyBonusProvider isRunning {
        require(rewardRate >= 10**decimals && rewardRate <= 1000000 * 10**decimals, "Out of range");
        totalRewards.push(TotalReward(currentTerm.toUint64() + 1, rewardRate));
    }

    function _updateBondGroupData() internal {
        uint256 nextTimeStamp = STRATEGY.calcNextMaturity();
        uint256 currentPriceE8 = ORACLE.latestPrice();
        uint256 currentStrikePrice = STRATEGY.getCurrentStrikePrice(
            currentPriceE8,
            priceUnit,
            REVERSE_ORACLE
        );

        _updatePriceUnit(currentPriceE8);

        // Register SBT for next term
        bytes32 SBTId = BOND_REGISTRATOR.registerSBT(
            BONDMAKER,
            currentStrikePrice.toUint64(),
            nextTimeStamp.toUint64()
        );
        (address sbtAddress, , , ) = BONDMAKER.getBond(SBTId);
        IERC20(sbtAddress).approve(address(DOTC), INFINITY);

        currentTerm += 1;
        TermInfo memory newTermInfo = TermInfo(
            nextTimeStamp.toUint64(),
            currentStrikePrice.toUint64(),
            SBTId
        );
        termInfo[currentTerm] = newTermInfo;
        BOND_PRICER.updateAcceptableMaturity(nextTimeStamp);
    }

    function _addLiquidity(uint256 amount) internal returns (bool success) {
        (, uint256 unsentToken, uint256 addLiquidityTerm) = _settleTokens();
        _updateBalanceDataForLiquidityMove(msg.sender, unsentToken, 0, addLiquidityTerm);
        uint256 _currentTerm = currentTerm;
        if (receivedCollaterals[msg.sender].value == 0) {
            receivedCollaterals[msg.sender].term = uint128(_currentTerm);
        }
        receivedCollaterals[msg.sender].value += amount.toUint128();
        totalReceivedCollateral[_currentTerm] += amount.toUint128();
        emit SetAddLiquidity(msg.sender, _currentTerm, amount);
        return true;
    }

    /**
     * @notice Make a reservation for removing liquidity
     * Collateral asset can be withdrawn from next term
     * Share token to be removed is burned at this point
     * Before remove liquidity, run _settleTokens()
     */

    function removeLiquidity(uint128 amount) external override returns (bool success) {
        (, uint256 unsentToken, uint256 addLiquidityTerm) = _settleTokens();
        uint256 _currentTerm = currentTerm;
        if (unremovedTokens[msg.sender].value == 0) {
            unremovedTokens[msg.sender].term = uint128(_currentTerm);
        }
        unremovedTokens[msg.sender].value += amount;
        totalUnremovedTokens[_currentTerm] += amount;
        _updateBalanceDataForLiquidityMove(msg.sender, unsentToken, amount, addLiquidityTerm);
        emit SetRemoveLiquidity(msg.sender, _currentTerm, amount);
        return true;
    }

    function _settleTokens()
        internal
        returns (
            uint256 unsentETH,
            uint256 unsentToken,
            uint256 addLiquidityTerm
        )
    {
        uint256 _currentTerm = currentTerm;
        uint128 lastRemoveLiquidityTerm = unremovedTokens[msg.sender].term;
        uint128 lastRemoveLiquidityValue = unremovedTokens[msg.sender].value;
        uint128 lastAddLiquidityTerm = receivedCollaterals[msg.sender].term;
        uint128 lastAddLiquidityValue = receivedCollaterals[msg.sender].value;
        if (_currentTerm == 0) {
            return (0, 0, 0);
        }

        if (lastRemoveLiquidityValue != 0 && _currentTerm > lastRemoveLiquidityTerm) {
            unsentETH = _applyDecimalGap(
                uint256(lastRemoveLiquidityValue)
                    .mul(shareData[uint256(lastRemoveLiquidityTerm + 1)].totalCollateralPerToken)
                    .div(10**decimals),
                false
            );
            if (unsentETH > 0) {
                _sendTokens(msg.sender, unsentETH);
            }
            delete unremovedTokens[msg.sender];
        }

        if (lastAddLiquidityValue != 0 && _currentTerm > lastAddLiquidityTerm) {
            unsentToken = _applyDecimalGap(
                uint256(lastAddLiquidityValue).mul(10**decimals).div(
                    uint256(shareData[lastAddLiquidityTerm + 1].totalCollateralPerToken)
                ),
                true
            );
            addLiquidityTerm = lastAddLiquidityTerm;
            delete receivedCollaterals[msg.sender];
        }
        emit SettleLiquidity(msg.sender, _currentTerm, unsentETH, unsentToken);
    }

    /**
     * @notice Increment share token for addLiquidity data
     * Transfer collateral asset for remove liquidity data
     */
    function settleTokens() external override returns (uint256 unsentETH, uint256 unsentToken) {
        uint256 addLiquidityTerm;
        (unsentETH, unsentToken, addLiquidityTerm) = _settleTokens();
        _updateBalanceDataForLiquidityMove(msg.sender, unsentToken, 0, addLiquidityTerm);
    }

    /**
     * @notice Update `startBondGroupId` to run `liquidateBonds()` more efficiently
     * All bond groups before `startBondGroupId` has expired before maturity of previous term
     */
    function updateStartBondGroupId() external override isRunning {
        uint32 _startBondGroupId = startBondGroupId;
        uint64 previousMaturity = termInfo[currentTerm - 1].maturity;
        require(previousMaturity != 0, "Maturity shoudld exist");
        while (true) {
            (, uint256 maturity) = BONDMAKER.getBondGroup(_startBondGroupId);
            if (maturity >= previousMaturity) {
                startBondGroupId = _startBondGroupId;
                return;
            }
            _startBondGroupId += 1;
        }
    }

    /**
     * @notice Liquidate and burn all bonds in this aggregator
     * Aggregator can search for 50 bondGroup and burn 10 bonds one time
     */
    function liquidateBonds() public override afterMaturity {
        uint256 _currentTerm = currentTerm;
        require(!liquidationData[_currentTerm].isLiquidated, "Expired");
        if (liquidationData[_currentTerm].endBondGroupId == 0) {
            liquidationData[_currentTerm].endBondGroupId = BONDMAKER.nextBondGroupID().toUint32();
        }
        // ToDo: Register least bond group ID
        uint32 endIndex;
        uint32 startIndex;
        uint32 liquidateBondNumber;
        uint64 maturity = termInfo[_currentTerm].maturity;
        uint64 previousMaturity = termInfo[_currentTerm - 1].maturity;
        {
            uint256 ethAllowance = DOTC.ethAllowance(address(this));
            if (ethAllowance > 0) {
                DOTC.withdrawEth();
            }
        }

        if (liquidationData[_currentTerm].liquidatedBondGroupID == 0) {
            startIndex = startBondGroupId;
        } else {
            startIndex = liquidationData[_currentTerm].liquidatedBondGroupID;
        }

        if (liquidationData[_currentTerm].endBondGroupId - startIndex > 50) {
            endIndex = startIndex + 50;
            liquidationData[_currentTerm].liquidatedBondGroupID = endIndex;
        } else {
            endIndex = liquidationData[_currentTerm].endBondGroupId;
        }

        for (uint256 i = startIndex; i < endIndex; i++) {
            liquidateBondNumber = _liquidateBondGroup(
                i,
                liquidateBondNumber,
                maturity,
                previousMaturity
            );

            if (liquidateBondNumber > 9) {
                if (i == endIndex - 1) {
                    liquidationData[_currentTerm].isLiquidated = true;
                } else {
                    liquidationData[_currentTerm].liquidatedBondGroupID = uint32(i + 1);
                }
                return;
            }
        }

        if (endIndex == liquidationData[_currentTerm].endBondGroupId) {
            liquidationData[_currentTerm].isLiquidated = true;
        } else {
            liquidationData[_currentTerm].liquidatedBondGroupID = endIndex;
        }
    }

    function addSuitableBondGroup() external override isActive returns (uint256 bondGroupID) {
        uint256 currentPriceE8 = ORACLE.latestPrice();
        return _addSuitableBondGroup(currentPriceE8);
    }

    /**
     * @notice Can not tranche bonds for 3 days from last execution of this function
     */
    function trancheBonds() external override isActive endCoolTime {
        uint256 currentPriceE8 = ORACLE.latestPrice();
        uint256 bondGroupId = _getSuitableBondGroup(currentPriceE8);
        if (bondGroupId == 0) {
            bondGroupId = _addSuitableBondGroup(currentPriceE8);
        }

        (uint256 amount, uint256 ethAmount, uint256[2] memory reverseBonds) = STRATEGY
            .getTrancheBonds(
            BONDMAKER,
            address(this),
            bondGroupId,
            currentPriceE8,
            issuableBondGroupIds[currentTerm],
            priceUnit,
            REVERSE_ORACLE
        );

        if (ethAmount > 0) {
            DOTC.depositEth{value: ethAmount}();
        }

        if (amount > 0) {
            _issueBonds(bondGroupId, amount);
        }

        if (reverseBonds[1] > 0) {
            // Burn bond and get collateral asset
            require(
                BONDMAKER.reverseBondGroupToCollateral(reverseBonds[0], reverseBonds[1]),
                "Reverse"
            );
        }
        lastTrancheTime = block.timestamp.toUint64();
        emit TrancheBond(
            uint64(bondGroupId),
            uint64(amount),
            uint64(reverseBonds[0]),
            uint64(reverseBonds[1])
        );
    }

    function _burnBond(
        uint256 bondGroupId,
        address bondAddress,
        uint32 liquidateBondNumber,
        bool isLiquidated
    ) internal returns (uint32, bool) {
        BondTokenInterface bond = BondTokenInterface(bondAddress);
        if (bond.balanceOf(address(this)) > 0) {
            if (!isLiquidated) {
                // If this bond group is not liquidated in _liquidateBondGroup, try liquidate
                // BondMaker contract does not revert even if someone else calls 'BONDMAKER.liquidateBond()'
                BONDMAKER.liquidateBond(bondGroupId, 0);
                isLiquidated = true;
            }
            bond.burnAll();
            liquidateBondNumber += 1;
        }
        return (liquidateBondNumber, isLiquidated);
    }

    function _liquidateBondGroup(
        uint256 bondGroupId,
        uint32 liquidateBondNumber,
        uint64 maturity,
        uint64 previousMaturity
    ) internal returns (uint32) {
        (bytes32[] memory bondIds, uint256 _maturity) = BONDMAKER.getBondGroup(bondGroupId);
        if (_maturity > maturity || (_maturity < previousMaturity && previousMaturity != 0)) {
            return liquidateBondNumber;
        }
        bool isLiquidated;
        for (uint256 i = 0; i < bondIds.length; i++) {
            (address bondAddress, , , ) = BONDMAKER.getBond(bondIds[i]);
            (liquidateBondNumber, isLiquidated) = _burnBond(
                bondGroupId,
                bondAddress,
                liquidateBondNumber,
                isLiquidated
            );
        }
        return liquidateBondNumber;
    }

    function _getSuitableBondGroup(uint256 currentPriceE8) internal view returns (uint256) {
        uint256 roundedPrice = STRATEGY.calcRoundPrice(currentPriceE8, priceUnit, 1);


            mapping(uint256 => uint256) storage priceToGroupBondId
         = strikePriceToBondGroup[currentTerm];
        if (priceToGroupBondId[roundedPrice] != 0) {
            return priceToGroupBondId[roundedPrice];
        }
        // Suitable bond range is in between current price +- 2 * priceUnit
        for (uint256 i = 1; i <= 2; i++) {
            if (priceToGroupBondId[roundedPrice - priceUnit * i] != 0) {
                return priceToGroupBondId[roundedPrice - priceUnit * i];
            }

            if (priceToGroupBondId[roundedPrice + priceUnit * i] != 0) {
                return priceToGroupBondId[roundedPrice + priceUnit * i];
            }
        }
    }

    function _addSuitableBondGroup(uint256 currentPriceE8) internal returns (uint256 bondGroupID) {
        uint256 callStrikePrice = STRATEGY.calcCallStrikePrice(
            currentPriceE8,
            priceUnit,
            REVERSE_ORACLE
        );
        uint256 _currentTerm = currentTerm;
        TermInfo memory info = termInfo[_currentTerm];
        callStrikePrice = _adjustPrice(info.strikePrice, callStrikePrice);
        bondGroupID = BOND_REGISTRATOR.registerBondGroup(
            BONDMAKER,
            callStrikePrice,
            info.strikePrice,
            info.maturity,
            info.SBTId
        );
        // If reverse oracle is set to aggregator, make Collateral/USD price
        if (REVERSE_ORACLE) {
            _addBondGroup(
                bondGroupID,
                STRATEGY.calcCallStrikePrice(currentPriceE8, priceUnit, false)
            );
        } else {
            _addBondGroup(bondGroupID, callStrikePrice);
        }
    }

    function _addBondGroup(uint256 bondGroupId, uint256 callStrikePriceInEthUSD) internal {
        // Register bond group info
        issuableBondGroupIds[currentTerm].push(bondGroupId);
        strikePriceToBondGroup[currentTerm][callStrikePriceInEthUSD] = bondGroupId;

        (bytes32[] memory bondIDs, ) = BONDMAKER.getBondGroup(bondGroupId);
        (address bondType1Address, , , ) = BONDMAKER.getBond(bondIDs[1]);

        // Infinite approve if no approval
        if (IERC20(bondType1Address).allowance(address(this), address(DOTC)) == 0) {
            IERC20(bondType1Address).approve(address(DOTC), INFINITY);
        }

        (address bondType2Address, , , ) = BONDMAKER.getBond(bondIDs[2]);

        if (IERC20(bondType2Address).allowance(address(this), address(DOTC)) == 0) {
            IERC20(bondType2Address).approve(address(DOTC), INFINITY);
        }
        (address bondType3Address, , , ) = BONDMAKER.getBond(bondIDs[3]);
        if (IERC20(bondType3Address).allowance(address(this), address(DOTC)) == 0) {
            IERC20(bondType3Address).approve(address(DOTC), INFINITY);
        }
    }

    function _updatePriceUnit(uint256 currentPriceE8) internal {
        uint256 multiplyer = currentPriceE8.div(50 * BASE_PRICE_UNIT);
        if (multiplyer == 0) {
            priceUnit = BASE_PRICE_UNIT;
        } else {
            priceUnit = ((25 * multiplyer * BASE_PRICE_UNIT) / 10).toUint64();
        }
    }

    function _updateFeeBase() internal {
        STRATEGY.registerCurrentFeeBase(
            currentFeeBase,
            shareData[currentTerm].totalCollateralPerToken,
            shareData[currentTerm + 1].totalCollateralPerToken,
            OWNER,
            address(ORACLE),
            REVERSE_ORACLE
        );
        changeSpread();
    }

    /**
     * @dev When sbtStrikePrice and callStrikePrice have different remainder of 2,
     * decrease callStrikePrice by 1 to avoid invalid line segment for register new bond
     */
    function _adjustPrice(uint64 sbtStrikePrice, uint256 callStrikePrice)
        internal
        pure
        returns (uint256)
    {
        return callStrikePrice.sub(callStrikePrice.sub(sbtStrikePrice) % 2);
    }

    function changeSpread() public virtual override {}

    function _sendTokens(address user, uint256 amount) internal virtual {}

    function _reserveAsset(uint256 reserveAmountRatioE8) internal virtual {}

    function _issueBonds(uint256 bondgroupID, uint256 amount) internal virtual {}

    function getCollateralAddress() external view virtual override returns (address) {}

    function _applyDecimalGap(uint256 amount, bool isDiv) internal view virtual returns (uint256) {}

    function getCollateralDecimal() external view virtual override returns (int16) {}

    function getReserveAddress() external view virtual returns (address) {}

    function getCollateralAmount() public view virtual override returns (uint256) {}

    // Reward functions
    /**
     * @dev Update reward amount, then update balance
     */
    function _updateBalanceData(address owner, int256 amount) internal {
        BalanceData memory balanceData = balance[owner];
        balanceData.rewardAmount = _calcNextReward(balanceData, currentTerm);
        balanceData.term = uint64(currentTerm);
        if (amount < 0) {
            balanceData.balance = uint256(balanceData.balance)
                .sub(uint256(amount * -1))
                .toUint128();
        } else {
            balanceData.balance = uint256(balanceData.balance).add(uint256(amount)).toUint128();
        }
        balance[owner] = balanceData;
    }

    function _updateBalanceDataForLiquidityMove(
        address owner,
        uint256 addAmount,
        uint256 removeAmount,
        uint256 term
    ) internal {
        BalanceData memory balanceData = balance[owner];
        // Update reward amount before addliquidity
        if (addAmount != 0) {
            balanceData.rewardAmount = _calcNextReward(balanceData, term);
            balanceData.term = uint64(term);
            balanceData.balance = balanceData.balance = uint256(balanceData.balance)
                .add(uint256(addAmount))
                .toUint128();
        }
        // Update reward amount after addliquidity
        balanceData.rewardAmount = _calcNextReward(balanceData, currentTerm);
        balanceData.term = uint64(currentTerm);
        // Update balance if remove liquidity
        if (removeAmount != 0) {
            balanceData.balance = uint256(balanceData.balance).sub(removeAmount).toUint128();
        }
        balance[owner] = balanceData;
    }

    /**
     * @dev This function is called before change balance of share token
     * @param term Reward amount is calculated from next term after this function is called to  term `term`
     */
    function _calcNextReward(BalanceData memory balanceData, uint256 term)
        internal
        view
        returns (uint64 rewardAmount)
    {
        rewardAmount = balanceData.rewardAmount;
        if (balanceData.balance > 0 && balanceData.term < term) {
            uint64 index = uint64(totalRewards.length - 1);
            uint64 referenceTerm = totalRewards[index].term;
            uint64 rewardTotal = totalRewards[index].value;

            for (uint256 i = term; i > balanceData.term; i--) {
                if (i < referenceTerm) {
                    // If i is smaller than the term in which total reward amount is changed, update total reward amount
                    index -= 1;
                    rewardTotal = totalRewards[index].value;
                    referenceTerm = totalRewards[index].term;
                }
                // Reward amount is calculated by `total reward amount * user balance / total share`
                rewardAmount = uint256(rewardAmount)
                    .add(
                    (uint256(rewardTotal).mul(balanceData.balance)).div(shareData[i].totalShare)
                )
                    .toUint64();
            }
        }
    }

    /**
     * @notice update reward amount and transfer reward token, then change reward amount to 0
     */
    function claimReward() public override {
        BalanceData memory userData = balance[msg.sender];
        userData.rewardAmount = _calcNextReward(userData, currentTerm);
        userData.term = uint64(currentTerm);
        require(userData.rewardAmount > 0, "No Reward");
        uint256 rewardAmount = userData.rewardAmount;
        userData.rewardAmount = 0;
        balance[msg.sender] = userData;
        REWARD_TOKEN.safeTransfer(msg.sender, rewardAmount);
    }

    // ERC20 functions

    /**
     * @param amount If this value is uint256(-1) infinite approve
     */
    function approve(address spender, uint256 amount) external override returns (bool) {
        if (amount == uint256(-1)) {
            amount = uint128(-1);
        }
        allowances[msg.sender][spender] = amount.toUint128();
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferToken(msg.sender, recipient, amount.toUint128());
    }

    /**
     * @notice If allowance amount is uint128(-1), allowance amount is not updated
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        uint128 currentAllowance = allowances[sender][msg.sender];
        if (currentAllowance < amount) {
            return false;
        }
        // Skip if infinity approve
        if (currentAllowance != uint128(-1)) {
            allowances[sender][msg.sender] = uint256(allowances[sender][msg.sender])
                .sub(amount)
                .toUint128();
        }
        _transferToken(sender, recipient, amount.toUint128());
        return true;
    }

    /**
     * @dev Balance is changed by `_updateBalanceData` to reflect correct reward amount
     */
    function _transferToken(
        address from,
        address to,
        uint128 amount
    ) internal returns (bool) {
        if (balance[from].balance < amount) {
            return false;
        }
        _updateBalanceData(from, -1 * int256(amount));
        _updateBalanceData(to, int256(amount));
        emit Transfer(from, to, uint256(amount));
        return true;
    }

    function balanceOf(address user) public view override returns (uint256) {
        return balance[user].balance;
    }

    function totalSupply() public view override returns (uint256) {
        return uint256(shareData[currentTerm].totalShare).sub(totalUnremovedTokens[currentTerm]);
    }

    function getLiquidityReservationData(address user)
        public
        view
        returns (
            uint128 receivedCollateralTerm,
            uint128 receivedCollateralAmount,
            uint128 removeTokenTerm,
            uint128 removeTokenAmount
        )
    {
        return (
            receivedCollaterals[user].term,
            receivedCollaterals[user].value,
            unremovedTokens[user].term,
            unremovedTokens[user].value
        );
    }

    function getCurrentStatus()
        public
        view
        override
        returns (
            uint256 term,
            int16 feeBase,
            uint32 uncheckbondGroupId,
            uint64 unit,
            uint64 trancheTime,
            bool isDanger
        )
    {
        return (
            currentTerm,
            currentFeeBase,
            startBondGroupId,
            priceUnit,
            lastTrancheTime,
            isTotalSupplyDanger
        );
    }

    function getLiquidationData(uint256 term)
        public
        view
        override
        returns (
            bool isLiquidated,
            uint32 liquidatedBondGroupID,
            uint32 endBondGroupId
        )
    {
        if (term == 0) {
            term = currentTerm;
        }
        isLiquidated = liquidationData[term].isLiquidated;
        liquidatedBondGroupID = liquidationData[term].liquidatedBondGroupID;
        endBondGroupId = liquidationData[term].endBondGroupId;
    }

    function totalShareData(uint256 term)
        public
        view
        override
        returns (uint128 totalShare, uint128 totalCollateralPerToken)
    {
        if (term == 0) {
            term = currentTerm;
        }
        return (shareData[term].totalShare, shareData[term].totalCollateralPerToken);
    }

    function getBondGroupIDFromTermAndPrice(uint256 term, uint256 price)
        public
        view
        override
        returns (uint256 bondGroupID)
    {
        price = STRATEGY.calcRoundPrice(price, priceUnit, 1);

        if (term == 0) {
            term = currentTerm;
        }
        return strikePriceToBondGroup[term][price];
    }

    function getInfo()
        public
        view
        override
        returns (
            address bondMaker,
            address strategy,
            address dotc,
            address bondPricerAddress,
            address oracleAddress,
            address rewardTokenAddress,
            address registratorAddress,
            address owner,
            bool reverseOracle,
            uint64 basePriceUnit,
            uint128 maxSupply
        )
    {
        return (
            address(BONDMAKER),
            address(STRATEGY),
            address(DOTC),
            address(BOND_PRICER),
            address(ORACLE),
            address(REWARD_TOKEN),
            address(BOND_REGISTRATOR),
            OWNER,
            REVERSE_ORACLE,
            BASE_PRICE_UNIT,
            uint128(uint128(-1) / (10**uint256(MAX_SUPPLY_DENUMERATOR)))
        );
    }

    function getTermInfo(uint256 term)
        public
        view
        override
        returns (
            uint64 maturity,
            uint64 solidStrikePrice,
            bytes32 SBTID
        )
    {
        if (term == 0) {
            term = currentTerm;
        }
        return (termInfo[term].maturity, termInfo[term].strikePrice, termInfo[term].SBTId);
    }

    /**
     * @notice return user's balance including unsettled share token
     */
    function getExpectedBalance(address user, bool hasReservation)
        external
        view
        override
        returns (uint256 expectedBalance)
    {
        expectedBalance = balance[user].balance;
        if (receivedCollaterals[user].value != 0) {
            hasReservation = true;
            if (currentTerm > receivedCollaterals[msg.sender].term) {
                expectedBalance += _applyDecimalGap(
                    uint256(receivedCollaterals[msg.sender].value).mul(10**decimals).div(
                        uint256(
                            shareData[receivedCollaterals[msg.sender].term + 1]
                                .totalCollateralPerToken
                        )
                    ),
                    true
                );
            }
        }
    }

    /**
     * @notice Return current phase of aggregator
     */
    function getCurrentPhase() public view override returns (AggregatorPhase) {
        if (currentTerm == 0) {
            return AggregatorPhase.BEFORE_START;
        } else if (block.timestamp <= termInfo[currentTerm].maturity) {
            if (block.timestamp <= lastTrancheTime + COOLTIME) {
                return AggregatorPhase.COOL_TIME;
            }
            return AggregatorPhase.ACTIVE;
        } else if (
            block.timestamp > termInfo[currentTerm].maturity &&
            !liquidationData[currentTerm].isLiquidated
        ) {
            return AggregatorPhase.AFTER_MATURITY;
        }
        return AggregatorPhase.EXPIRED;
    }

    /**
     * @notice Calculate expected reward amount at this point
     */
    function getRewardAmount(address user) public view override returns (uint64) {
        return _calcNextReward(balance[user], currentTerm);
    }

    function getTotalRewards() public view override returns (TotalReward[] memory) {
        return totalRewards;
    }

    function isTotalSupplySafe() public view override returns (bool) {
        return !isTotalSupplyDanger;
    }

    function getTotalUnmovedAssets() public view override returns (uint256, uint256) {
        return (totalReceivedCollateral[currentTerm], totalUnremovedTokens[currentTerm]);
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return allowances[owner][spender];
    }

    function getCollateralPerToken(uint256 term) public view override returns (uint256) {
        return shareData[term].totalCollateralPerToken;
    }

    function getBondGroupIdFromStrikePrice(uint256 term, uint256 strikePrice)
        public
        view
        override
        returns (uint256)
    {
        return strikePriceToBondGroup[term][strikePrice];
    }

    function getBalanceData(address user)
        external
        view
        override
        returns (
            uint128 amount,
            uint64 term,
            uint64 rewardAmount
        )
    {
        return (balance[user].balance, balance[user].term, balance[user].rewardAmount);
    }

    /**
     * @notice Get suitable bond groups for current price
     */
    function getIssuableBondGroups() public view override returns (uint256[] memory) {
        return issuableBondGroupIds[currentTerm];
    }
}

// File: contracts/BondToken_and_GDOTC/bondMaker/BondMakerCollateralizedEthInterface.sol





interface BondMakerCollateralizedEthInterface is BondMakerInterface {
    function issueNewBonds(uint256 bondGroupID) external payable returns (uint256 amount);
}

// File: contracts/BondToken_and_GDOTC/util/TransferETH.sol





abstract contract TransferETH is TransferETHInterface {
    receive() external payable override {
        emit LogTransferETH(msg.sender, address(this), msg.value);
    }

    function _hasSufficientBalance(uint256 amount) internal view returns (bool ok) {
        address thisContract = address(this);
        return amount <= thisContract.balance;
    }

    /**
     * @notice transfer `amount` ETH to the `recipient` account with emitting log
     */
    function _transferETH(
        address payable recipient,
        uint256 amount,
        string memory errorMessage
    ) internal {
        require(_hasSufficientBalance(amount), errorMessage);
        (bool success, ) = recipient.call{value: amount}(""); // solhint-disable-line avoid-low-level-calls
        require(success, "transferring Ether failed");
        emit LogTransferETH(address(this), recipient, amount);
    }

    function _transferETH(address payable recipient, uint256 amount) internal {
        _transferETH(recipient, amount, "TransferETH: transfer amount exceeds balance");
    }
}

// File: contracts/contracts/SimpleAggregator/ReserveETH.sol





contract ReserveEth is TransferETH {
    address owner;
    modifier onlyOwner() {
        require(msg.sender == owner, "Error: Only owner can execute this function");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    /**
     * @notice Send ETH to user
     * Only aggregator can call this function
     */
    function sendAsset(address payable user, uint256 amount) public onlyOwner {
        _transferETH(user, amount);
    }
}

// File: contracts/contracts/SimpleAggregator/SimpleAggregatorCollateralizedEth.sol









contract SimpleAggregatorCollateralizedEth is SimpleAggregator, TransferETH {
    using SafeMath for uint256;
    ReserveEth internal immutable reserveEth;
    uint16 internal constant DECIMAL_GAP = 10;

    constructor(
        LatestPriceOracleInterface _ethOracle,
        BondPricerWithAcceptableMaturity _pricer,
        SimpleStrategyInterface strategy,
        ERC20 _rewardToken,
        BondRegistratorInterface _registrator,
        ExchangeInterface exchangeAddress,
        VolatilityOracleInterface _volOracle,
        uint64 _priceUnit,
        uint64 _firstRewardRate
    )
        SimpleAggregator(
            _ethOracle,
            _pricer,
            strategy,
            _rewardToken,
            _registrator,
            exchangeAddress,
            _priceUnit,
            _firstRewardRate,
            false,
            _volOracle
        )
    {
        BondMakerInterface _bondMaker = exchangeAddress.bondMakerAddress();
        int16 feeBaseE4 = strategy.getCurrentSpread(msg.sender, address(_ethOracle), false);
        currentFeeBase = feeBaseE4;
        exchangeAddress.createVsBondPool(_bondMaker, _volOracle, _pricer, _pricer, feeBaseE4);
        exchangeAddress.createVsEthPool(_ethOracle, _pricer, feeBaseE4, true);
        exchangeAddress.createVsEthPool(_ethOracle, _pricer, feeBaseE4, false);

        reserveEth = new ReserveEth();
    }

    function changeSpread() public override {
        int16 _currentFeeBase = STRATEGY.getCurrentSpread(OWNER, address(ORACLE), false);

        require(_currentFeeBase <= 1000 && _currentFeeBase >= 5, "Invalid feebase");
        bytes32 poolIDETHSell = DOTC.generateVsEthPoolID(address(this), true);
        bytes32 poolIDETHBuy = DOTC.generateVsEthPoolID(address(this), false);

        bytes32 poolIDBond = DOTC.generateVsBondPoolID(address(this), address(BONDMAKER));

        DOTC.updateVsEthPool(poolIDETHSell, ORACLE, BOND_PRICER, _currentFeeBase);

        DOTC.updateVsEthPool(poolIDETHBuy, ORACLE, BOND_PRICER, _currentFeeBase);

        DOTC.updateVsBondPool(poolIDBond, volOracle, BOND_PRICER, BOND_PRICER, _currentFeeBase);
        currentFeeBase = _currentFeeBase;
    }

    /**
     * @notice Receive ETH, then call _addLiquidity
     */
    function addLiquidity() external payable isSafeSupply returns (bool success) {
        success = _addLiquidity(msg.value);
    }

    function _sendTokens(address user, uint256 amount) internal override {
        reserveEth.sendAsset(payable(user), amount);
    }

    function _reserveAsset(uint256 collateralPerTokenE8) internal override {
        uint256 amount = _applyDecimalGap(
            uint256(totalUnremovedTokens[currentTerm]).mul(collateralPerTokenE8).div(10**decimals),
            false
        );
        _transferETH(address(reserveEth), amount);
    }

    function _issueBonds(uint256 bondgroupID, uint256 amount) internal override {
        BondMakerCollateralizedEthInterface bm = BondMakerCollateralizedEthInterface(
            address(BONDMAKER)
        );
        bm.issueNewBonds{value: amount.mul(10**DECIMAL_GAP).mul(1002).div(1000)}(bondgroupID);
    }

    function getCollateralAddress() external pure override returns (address) {
        return address(0);
    }

    /**
     * @dev Decimal gap between ETH and share token is 10
     */
    function _applyDecimalGap(uint256 amount, bool isDiv) internal pure override returns (uint256) {
        if (isDiv) {
            return amount / 10**DECIMAL_GAP;
        } else {
            return amount * 10**DECIMAL_GAP;
        }
    }

    /**
     * @notice Get available collateral amount in this term
     */
    function getCollateralAmount() public view override returns (uint256) {
        return address(this).balance.sub(totalReceivedCollateral[currentTerm]);
    }

    function getCollateralDecimal() external pure override returns (int16) {
        return 18;
    }

    function getReserveAddress() external view override returns (address) {
        return address(reserveEth);
    }
}