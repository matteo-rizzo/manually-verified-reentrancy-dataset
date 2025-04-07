/**
 *Submitted for verification at Etherscan.io on 2021-03-18
*/

// SPDX-License-Identifier: Unlicense

pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;



// Part: ABDKMath64x64

/**
 * Smart contract library of mathematical functions operating with signed
 * 64.64-bit fixed point numbers.  Signed 64.64-bit fixed point number is
 * basically a simple fraction whose numerator is signed 128-bit integer and
 * denominator is 2^64.  As long as denominator is always the same, there is no
 * need to store it, thus in Solidity signed 64.64-bit fixed point numbers are
 * represented by int128 type holding only the numerator.
 */


// Part: BokkyPooBahsDateTimeLibrary

// ----------------------------------------------------------------------------
// BokkyPooBah's DateTime Library v1.01
//
// A gas-efficient Solidity date and time library
//
// https://github.com/bokkypoobah/BokkyPooBahsDateTimeLibrary
//
// Tested date range 1970/01/01 to 2345/12/31
//
// Conventions:
// Unit      | Range         | Notes
// :-------- |:-------------:|:-----
// timestamp | >= 0          | Unix timestamp, number of seconds since 1970/01/01 00:00:00 UTC
// year      | 1970 ... 2345 |
// month     | 1 ... 12      |
// day       | 1 ... 31      |
// hour      | 0 ... 23      |
// minute    | 0 ... 59      |
// second    | 0 ... 59      |
// dayOfWeek | 1 ... 7       | 1 = Monday, ..., 7 = Sunday
//
//
// Enjoy. (c) BokkyPooBah / Bok Consulting Pty Ltd 2018-2019. The MIT Licence.
// ----------------------------------------------------------------------------



// Part: CloneFactory

/*
The MIT License (MIT)

Copyright (c) 2018 Murray Software, LLC.

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/
//solhint-disable max-line-length
//solhint-disable no-inline-assembly

contract CloneFactory {

  function createClone(address target) internal returns (address result) {
    bytes20 targetBytes = bytes20(target);
    assembly {
      let clone := mload(0x40)
      mstore(clone, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
      mstore(add(clone, 0x14), targetBytes)
      mstore(add(clone, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
      result := create(0, clone, 0x37)
    }
  }

  function isClone(address target, address query) internal view returns (bool result) {
    bytes20 targetBytes = bytes20(target);
    assembly {
      let clone := mload(0x40)
      mstore(clone, 0x363d3d373d3d3d363d7300000000000000000000000000000000000000000000)
      mstore(add(clone, 0xa), targetBytes)
      mstore(add(clone, 0x1e), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)

      let other := add(clone, 0x40)
      extcodecopy(query, other, 0, 0x2d)
      result := and(
        eq(mload(clone), mload(other)),
        eq(mload(add(clone, 0xd)), mload(add(other, 0xd)))
      )
    }
  }
}

// Part: IOracle



// Part: Initializable

/**
 * @title Initializable
 *
 * @dev Helper contract to support initializer functions. To use it, replace
 * the constructor with a function that has the `initializer` modifier.
 * WARNING: Unlike constructors, initializer functions must be manually
 * invoked. This applies both to deploying an Initializable contract, as well
 * as extending an Initializable contract via inheritance.
 * WARNING: When used with inheritance, manual care must be taken to not invoke
 * a parent initializer twice, or ensure that all initializers are idempotent,
 * because this is not dealt with automatically as with constructors.
 */
contract Initializable {

  /**
   * @dev Indicates that the contract has been initialized.
   */
  bool private initialized;

  /**
   * @dev Indicates that the contract is in the process of being initialized.
   */
  bool private initializing;

  /**
   * @dev Modifier to use in the initializer function of a contract.
   */
  modifier initializer() {
    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

    bool isTopLevelCall = !initializing;
    if (isTopLevelCall) {
      initializing = true;
      initialized = true;
    }

    _;

    if (isTopLevelCall) {
      initializing = false;
    }
  }

  /// @dev Returns true if and only if the function is running in the constructor
  function isConstructor() private view returns (bool) {
    // extcodesize checks the size of the code stored in an address, and
    // address returns the current address. Since the code is still not
    // deployed when running a constructor, any checks on its code size will
    // yield zero, making it an effective way to detect if a contract is
    // under construction or not.
    address self = address(this);
    uint256 cs;
    assembly { cs := extcodesize(self) }
    return cs == 0;
  }

  // Reserved storage space to allow for layout changes in the future.
  uint256[50] private ______gap;
}

// Part: OpenZeppelin/[email protected]/Address

/**
 * @dev Collection of functions related to the address type
 */


// Part: OpenZeppelin/[email protected]/IERC20

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


// Part: OpenZeppelin/[email protected]/Math

/**
 * @dev Standard math utilities missing in the Solidity language.
 */


// Part: OpenZeppelin/[email protected]/ReentrancyGuard

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () internal {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// Part: OpenZeppelin/[email protected]/SafeMath

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


// Part: OpenZeppelin/[email protected]/Strings

/**
 * @dev String operations.
 */


// Part: ContextUpgradeSafe

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
contract ContextUpgradeSafe is Initializable {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.

    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {


    }


    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }

    uint256[50] private __gap;
}

// Part: OpenZeppelin/[email protected]/SafeERC20

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */


// Part: OptionMath



// Part: OptionSymbol

contract OptionSymbol {
    using SafeMath for uint256;

    uint256 private constant STRIKE_PRICE_SCALE = 1e18;
    uint256 private constant STRIKE_PRICE_DIGITS = 18;

    // example symbol: Charm LP ETH 04DEC2020 C
    function getMarketSymbol(
        string memory underlying,
        uint256 expiryTime,
        bool isPut
    ) public pure returns (string memory) {
        (uint256 year, uint256 month, uint256 day) = BokkyPooBahsDateTimeLibrary.timestampToDate(expiryTime);
        (string memory monthSymbol, ) = _getMonth(month);

        string memory suffix = isPut ? "P" : "C";

        return
            string(
                abi.encodePacked(
                    "Charm LP ",
                    underlying,
                    " ",
                    _uintTo2Chars(day),
                    monthSymbol,
                    Strings.toString(year),
                    " ",
                    suffix
                )
            );
    }

    // example symbol: Charm ETH 04DEC2020 500 C
    function getOptionSymbol(
        string memory underlying,
        uint256 strikePrice,
        uint256 expiryTime,
        bool isPut,
        bool isLong
    ) public pure returns (string memory) {
        string memory displayStrikePrice = _getDisplayedStrikePrice(strikePrice);

        (uint256 year, uint256 month, uint256 day) = BokkyPooBahsDateTimeLibrary.timestampToDate(expiryTime);
        (string memory monthSymbol, ) = _getMonth(month);

        string memory suffix = isPut ? (isLong ? "P" : "SP") : (isLong ? "C" : "SC");

        return
            string(
                abi.encodePacked(
                    "Charm ",
                    underlying,
                    " ",
                    _uintTo2Chars(day),
                    monthSymbol,
                    Strings.toString(year),
                    " ",
                    displayStrikePrice,
                    " ",
                    suffix
                )
            );
    }

    /**
     * @dev convert strike price scaled by 1e8 to human readable number string
     * @param _strikePrice strike price scaled by 1e8
     * @return strike price string
     */
    function _getDisplayedStrikePrice(uint256 _strikePrice) internal pure returns (string memory) {
        uint256 remainder = _strikePrice.mod(STRIKE_PRICE_SCALE);
        uint256 quotient = _strikePrice.div(STRIKE_PRICE_SCALE);
        string memory quotientStr = Strings.toString(quotient);

        if (remainder == 0) return quotientStr;

        uint256 trailingZeroes = 0;
        while (remainder.mod(10) == 0) {
            remainder = remainder / 10;
            trailingZeroes += 1;
        }

        // pad the number with "1 + starting zeroes"
        remainder += 10**(STRIKE_PRICE_DIGITS - trailingZeroes);

        string memory tmpStr = Strings.toString(remainder);
        tmpStr = _slice(tmpStr, 1, 1 + STRIKE_PRICE_DIGITS - trailingZeroes);

        string memory completeStr = string(abi.encodePacked(quotientStr, ".", tmpStr));
        return completeStr;
    }

    /**
     * @dev return a representation of a number using 2 characters, adds a leading 0 if one digit, uses two trailing digits if a 3 digit number
     * @return 2 characters that corresponds to a number
     */
    function _uintTo2Chars(uint256 number) internal pure returns (string memory) {
        if (number > 99) number = number % 100;
        string memory str = Strings.toString(number);
        if (number < 10) {
            return string(abi.encodePacked("0", str));
        }
        return str;
    }

    /**
     * @dev cut string s into s[start:end]
     * @param _s the string to cut
     * @param _start the starting index
     * @param _end the ending index (excluded in the substring)
     */
    function _slice(
        string memory _s,
        uint256 _start,
        uint256 _end
    ) internal pure returns (string memory) {
        bytes memory a = new bytes(_end - _start);
        for (uint256 i = 0; i < _end - _start; i++) {
            a[i] = bytes(_s)[_start + i];
        }
        return string(a);
    }

    /**
     * @dev return string representation of a month
     * @return shortString a 3 character representation of a month (ex: SEP, DEC, etc)
     * @return longString a full length string of a month (ex: September, December, etc)
     */
    function _getMonth(uint256 _month) internal pure returns (string memory shortString, string memory longString) {
        if (_month == 1) {
            return ("JAN", "January");
        } else if (_month == 2) {
            return ("FEB", "February");
        } else if (_month == 3) {
            return ("MAR", "March");
        } else if (_month == 4) {
            return ("APR", "April");
        } else if (_month == 5) {
            return ("MAY", "May");
        } else if (_month == 6) {
            return ("JUN", "June");
        } else if (_month == 7) {
            return ("JUL", "July");
        } else if (_month == 8) {
            return ("AUG", "August");
        } else if (_month == 9) {
            return ("SEP", "September");
        } else if (_month == 10) {
            return ("OCT", "October");
        } else if (_month == 11) {
            return ("NOV", "November");
        } else {
            return ("DEC", "December");
        }
    }
}

// Part: ReentrancyGuardUpgradeSafe

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
contract ReentrancyGuardUpgradeSafe is Initializable {
    bool private _notEntered;


    function __ReentrancyGuard_init() internal initializer {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal initializer {


        // Storing an initial non-zero value makes deployment a bit more
        // expensive, but in exchange the refund on every call to nonReentrant
        // will be lower in amount. Since refunds are capped to a percetange of
        // the total transaction's gas, it is best to keep them low in cases
        // like this one, to increase the likelihood of the full refund coming
        // into effect.
        _notEntered = true;

    }


    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_notEntered, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _notEntered = false;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _notEntered = true;
    }

    uint256[49] private __gap;
}

// Part: ERC20UpgradeSafe

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20MinterPauser}.
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
contract ERC20UpgradeSafe is Initializable, ContextUpgradeSafe, IERC20 {
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

    function __ERC20_init(string memory name, string memory symbol) internal initializer {
        __Context_init_unchained();
        __ERC20_init_unchained(name, symbol);
    }

    function __ERC20_init_unchained(string memory name, string memory symbol) internal initializer {


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

    uint256[44] private __gap;
}

// Part: OwnableUpgradeSafe

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
contract OwnableUpgradeSafe is Initializable, ContextUpgradeSafe {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */

    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {


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

    uint256[49] private __gap;
}

// Part: UniERC20



// Part: OptionToken

/**
 * ERC20 token representing a long or short option position. It is intended to be
 * used by `OptionMarket`, which mints/burns these tokens when users buy/sell options
 *
 * Note that `decimals` should match the decimals of the `baseToken` in `OptionMarket`
 */
contract OptionToken is ERC20UpgradeSafe {
    using Address for address;
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    address public market;

    function initialize(
        address _market,
        string memory name,
        string memory symbol,
        uint8 decimals
    ) public initializer {
        __ERC20_init(name, symbol);
        _setupDecimals(decimals);
        market = _market;
    }

    function mint(address account, uint256 amount) external {
        require(msg.sender == market, "!market");
        _mint(account, amount);
    }

    function burn(address account, uint256 amount) external {
        require(msg.sender == market, "!market");
        _burn(account, amount);
    }
}

// Part: OptionMarket

/**
 * Automated market-maker for options
 *
 * This contract allows an asset to be split up into tokenized payoffs such that
 * different combinations of payoffs sum up to different call/put option payoffs.
 * An LMSR (Hanson's market-maker) is used to provide liquidity for the tokenized
 * payoffs.
 *
 * The parameter `b` in the LMSR represents the market depth. `b` is increased when
 * users provide liquidity by depositing funds and it is decreased when they withdraw
 * liquidity. Trading fees are distributed proportionally to liquidity providers
 * at the time of the trade.
 *
 * Call and put option with any of the supported strikes are provided. Short options
 * (equivalent to owning 1 underlying + sell 1 option) are provided, which let users
 * take on short option exposure
 *
 * `buy`, `sell`, `deposit` and `withdraw` are the main methods used to interact with
 * this contract.
 *
 * After expiration, `settle` can be called to fetch the expiry price from a
 * price oracle. `buy` and `deposit` cannot be called after expiration, but `sell`
 * can be called to redeem options for their corresponding payouts and `withdraw`
 * can be called to redeem LP tokens for a stake of the remaining funds left
 * in the contract.
 *
 * Methods to calculate the LMSR cost and option payoffs can be found in `OptionMath`.
 * `OptionToken` is an ERC20 token representing a long or short option position
 * that's minted or burned when users buy or sell options.
 *
 * This contract is also an ERC20 token itself representing shares in the liquidity
 * pool.
 *
 * The intended way to deploy this contract is to call `createMarket` in `OptionFactory`
 * Then liquidity has to be provided using `deposit` before trades can occur.
 *
 * Please note that the deployer of this contract is highly privileged and has
 * permissions such as withdrawing all funds from the contract, being able to pause
 * trading, modify the market parameters and override the settlement price. These
 * permissions will be removed in future versions.
 */
contract OptionMarket is ERC20UpgradeSafe, ReentrancyGuardUpgradeSafe, OwnableUpgradeSafe {
    using Address for address;
    using SafeERC20 for IERC20;
    using UniERC20 for IERC20;
    using SafeMath for uint256;

    event Buy(
        address indexed account,
        bool isLongToken,
        uint256 strikeIndex,
        uint256 optionsOut,
        uint256 amountIn,
        uint256 newSupply
    );

    event Sell(
        address indexed account,
        bool isLongToken,
        uint256 strikeIndex,
        uint256 optionsIn,
        uint256 amountOut,
        uint256 newSupply,
        bool isSettled
    );

    event Deposit(address indexed account, uint256 sharesOut, uint256 amountIn, uint256 newSupply);
    event Withdraw(address indexed account, uint256 sharesIn, uint256 amountOut, uint256 newSupply, bool isSettled);
    event Settle(uint256 expiryPrice);

    uint256 public constant SCALE = 1e18;
    uint256 public constant SCALE_SCALE = 1e36;

    IERC20 public baseToken;
    IOracle public oracle;
    OptionToken[] public longTokens;
    OptionToken[] public shortTokens;
    uint256[] public strikePrices;
    uint256 public expiryTime;
    bool public isPut;
    uint256 public tradingFee;
    uint256 public balanceCap;
    uint256 public totalSupplyCap;
    uint256 public disputePeriod;

    bool public isPaused;
    bool public isSettled;
    uint256 public expiryPrice;

    // cache getCurrentCost and getCurrentPayoff between trades to save gas
    uint256 public lastCost;
    uint256 public lastPayoff;

    // total value of fees owed to LPs
    uint256 public poolValue;

    /**
     * @param _baseToken        Underlying asset if call. Strike currency if put
     *                          Represents ETH if equal to 0x0
     * @param _oracle           Oracle from which settlement price is obtained
     * @param _longTokens       Tokens representing long calls/puts
     * @param _shortTokens      Tokens representing short calls/puts
     * @param _strikePrices     Strike prices expressed in wei. Must be in increasing order
     * @param _expiryTime       Expiration time as a unix timestamp
     * @param _isPut            Whether this market provides calls or puts
     * @param _tradingFee       Trading fee as fraction of underlying expressed in wei
     * @param _symbol           Name and symbol of LP tokens
     */
    function initialize(
        address _baseToken,
        address _oracle,
        address[] memory _longTokens,
        address[] memory _shortTokens,
        uint256[] memory _strikePrices,
        uint256 _expiryTime,
        bool _isPut,
        uint256 _tradingFee,
        string memory _symbol
    ) public payable initializer {
        // this contract is also an ERC20 token, representing shares in the liquidity pool
        __ERC20_init(_symbol, _symbol);
        __ReentrancyGuard_init();
        __Ownable_init();

        // use same decimals as base token
        uint8 decimals = IERC20(_baseToken).isETH() ? 18 : ERC20UpgradeSafe(_baseToken).decimals();
        _setupDecimals(decimals);

        require(_longTokens.length == _strikePrices.length, "Lengths do not match");
        require(_shortTokens.length == _strikePrices.length, "Lengths do not match");

        require(_strikePrices.length > 0, "Strike prices must not be empty");
        require(_strikePrices[0] > 0, "Strike prices must be > 0");

        // check strike prices are increasing
        for (uint256 i = 0; i < _strikePrices.length - 1; i++) {
            require(_strikePrices[i] < _strikePrices[i + 1], "Strike prices must be increasing");
        }

        // check trading fee is less than 100%
        // note trading fee can be 0
        require(_tradingFee < SCALE, "Trading fee must be < 1");

        baseToken = IERC20(_baseToken);
        oracle = IOracle(_oracle);
        strikePrices = _strikePrices;
        expiryTime = _expiryTime;
        isPut = _isPut;
        tradingFee = _tradingFee;

        for (uint256 i = 0; i < _strikePrices.length; i++) {
            longTokens.push(OptionToken(_longTokens[i]));
            shortTokens.push(OptionToken(_shortTokens[i]));
        }

        require(!isExpired(), "Already expired");
    }

    /**
     * Buy options
     *
     * The option bought is specified by `isLongToken` and `strikeIndex` and the
     * amount by `optionsOut`
     *
     * This method reverts if the resulting cost is greater than `maxAmountIn`
     */
    function buy(
        bool isLongToken,
        uint256 strikeIndex,
        uint256 optionsOut,
        uint256 maxAmountIn
    ) external payable nonReentrant returns (uint256 amountIn) {
        require(totalSupply() > 0, "No liquidity");
        require(!isExpired(), "Already expired");
        require(msg.sender == owner() || !isPaused, "Paused");
        require(strikeIndex < strikePrices.length, "Index too large");
        require(optionsOut > 0, "Options out must be > 0");

        // mint options to user
        OptionToken option = isLongToken ? longTokens[strikeIndex] : shortTokens[strikeIndex];
        option.mint(msg.sender, optionsOut);

        // calculate trading fee and allocate it to the LP pool
        // like LMSR cost, fees have to be multiplied by strike price
        uint256 fee = optionsOut.mul(tradingFee);
        fee = isPut ? fee.mul(strikePrices[strikeIndex]).div(SCALE_SCALE) : fee.div(SCALE);
        poolValue = poolValue.add(fee);

        // calculate amount that needs to be paid by user to buy these options
        // it's equal to the increase in LMSR cost after minting the options
        uint256 costAfter = getCurrentCost();
        amountIn = costAfter.sub(lastCost).add(fee); // do sub first as a check since should not fail
        lastCost = costAfter;
        require(amountIn > 0, "Amount in must be > 0");
        require(amountIn <= maxAmountIn, "Max slippage exceeded");

        // transfer in amount from user
        _transferIn(amountIn);
        emit Buy(msg.sender, isLongToken, strikeIndex, optionsOut, amountIn, option.totalSupply());
    }

    /**
     * Sell options
     *
     * The option sold is specified by `isLongToken` and `strikeIndex` and the
     * amount by `optionsIn`
     *
     * This method reverts if the resulting amount returned is less than `minAmountOut`
     */
    function sell(
        bool isLongToken,
        uint256 strikeIndex,
        uint256 optionsIn,
        uint256 minAmountOut
    ) external nonReentrant returns (uint256 amountOut) {
        require(!isExpired() || isSettled, "Must be called before expiry or after settlement");
        require(!isDisputePeriod(), "Dispute period");
        require(msg.sender == owner() || !isPaused, "Paused");
        require(strikeIndex < strikePrices.length, "Index too large");
        require(optionsIn > 0, "Options in must be > 0");

        // burn user's options
        OptionToken option = isLongToken ? longTokens[strikeIndex] : shortTokens[strikeIndex];
        option.burn(msg.sender, optionsIn);

        // calculate amount that needs to be returned to user
        if (isSettled) {
            // if after settlement, amount is the option payoff
            uint256 payoffAfter = getCurrentPayoff();
            amountOut = lastPayoff.sub(payoffAfter);
            lastPayoff = payoffAfter;
        } else {
            // if before expiry, amount is the decrease in LMSR cost after burning the options
            uint256 costAfter = getCurrentCost();
            amountOut = lastCost.sub(costAfter);
            lastCost = costAfter;
        }
        require(amountOut > 0, "Amount out must be > 0");
        require(amountOut >= minAmountOut, "Max slippage exceeded");

        // transfer amount to user
        baseToken.uniTransfer(msg.sender, amountOut);
        emit Sell(msg.sender, isLongToken, strikeIndex, optionsIn, amountOut, option.totalSupply(), isSettled);
    }

    /**
     * Deposit liquidity
     *
     * `sharesOut` is the intended increase in the parameter `b`
     *
     * This method reverts if the resulting cost is greater than `maxAmountIn`
     */
    function deposit(uint256 sharesOut, uint256 maxAmountIn) external payable nonReentrant returns (uint256 amountIn) {
        require(!isExpired(), "Already expired");
        require(msg.sender == owner() || !isPaused, "Paused");
        require(sharesOut > 0, "Shares out must be > 0");

        // user needs to contribute proportional amount of fees to pool, which
        // ensures they are only earning fees generated after they have deposited
        if (totalSupply() > 0) {
            // add 1 to round up
            amountIn = poolValue.mul(sharesOut).div(totalSupply()).add(1);
            poolValue = poolValue.add(amountIn);
        }
        _mint(msg.sender, sharesOut);
        require(totalSupplyCap == 0 || totalSupply() <= totalSupplyCap, "Total supply cap exceeded");

        // need to add increase in LMSR cost after increasing b
        uint256 costAfter = getCurrentCost();
        amountIn = costAfter.sub(lastCost).add(amountIn); // do sub first as a check since should not fail
        lastCost = costAfter;
        require(amountIn > 0, "Amount in must be > 0");
        require(amountIn <= maxAmountIn, "Max slippage exceeded");

        // transfer in amount from user
        _transferIn(amountIn);
        emit Deposit(msg.sender, sharesOut, amountIn, totalSupply());
    }

    /**
     * Withdraw liquidity
     *
     * `sharesIn` is the intended decrease in the parameter `b`
     *
     * This method reverts if the resulting amount returned is less than `minAmountOut`
     */
    function withdraw(uint256 sharesIn, uint256 minAmountOut) external nonReentrant returns (uint256 amountOut) {
        require(!isExpired() || isSettled, "Must be called before expiry or after settlement");
        require(!isDisputePeriod(), "Dispute period");
        require(msg.sender == owner() || !isPaused, "Paused");
        require(sharesIn > 0, "Shares in must be > 0");

        // calculate cut of fees earned by user
        amountOut = poolValue.mul(sharesIn).div(totalSupply());
        poolValue = poolValue.sub(amountOut);
        _burn(msg.sender, sharesIn);

        // if before expiry, add decrease in LMSR cost after decreasing b
        if (!isSettled) {
            uint256 costAfter = getCurrentCost();
            amountOut = lastCost.sub(costAfter).add(amountOut); // do sub first as a check since should not fail
            lastCost = costAfter;
        }
        require(amountOut > 0, "Amount out must be > 0");
        require(amountOut >= minAmountOut, "Max slippage exceeded");

        // return amount to user
        baseToken.uniTransfer(msg.sender, amountOut);
        emit Withdraw(msg.sender, sharesIn, amountOut, totalSupply(), isSettled);
    }

    /**
     * Retrieve and store the underlying price from the oracle
     *
     * This method can be called by anyone after expiration but cannot be called
     * more than once. In practice it should be called as soon as possible after the
     * expiration time.
     */
    function settle() external nonReentrant {
        require(isExpired(), "Cannot be called before expiry");
        require(!isSettled, "Already settled");

        // fetch expiry price from oracle
        isSettled = true;
        expiryPrice = oracle.getPrice();
        require(expiryPrice > 0, "Price from oracle must be > 0");

        // update cached payoff and pool value
        lastPayoff = getCurrentPayoff();
        poolValue = baseToken.uniBalanceOf(address(this)).sub(lastPayoff);
        emit Settle(expiryPrice);
    }

    /**
     * Calculate LMSR cost
     *
     * Represents total amount locked in the LMSR
     *
     * This value will increase as options are bought and decrease as options
     * are sold. The change in value corresponds to the total cost of a purchase
     * or the amount returned from a sale.
     *
     * This method is only used before expiry. Before expiry, the `baseToken`
     * balance of this contract is always at least current cost + pool value.
     * Current cost is maximum possible amount that needs to be paid out to
     * option holders. Pool value is the fees earned by LPs.
     */
    function getCurrentCost() public view returns (uint256) {
        uint256[] memory longSupplies = getTotalSupplies(longTokens);
        uint256[] memory shortSupplies = getTotalSupplies(shortTokens);
        uint256[] memory quantities = OptionMath.calcQuantities(strikePrices, isPut, longSupplies, shortSupplies);
        return OptionMath.calcLmsrCost(quantities, totalSupply());
    }

    /**
     * Calculate option payoff
     *
     * Represents total payoff to option holders
     *
     * This value will decrease as options are redeemed. The change in value
     * corresponds to the payoff returned from a redemption.
     *
     * This method is only used after expiry. After expiry, the `baseToken` balance
     * of this contract is always at least current payoff + pool value. Current
     * payoff is the amount owed to option holders and pool value is the amount
     * owed to LPs.
     */
    function getCurrentPayoff() public view returns (uint256) {
        uint256[] memory longSupplies = getTotalSupplies(longTokens);
        uint256[] memory shortSupplies = getTotalSupplies(shortTokens);
        return OptionMath.calcPayoff(strikePrices, expiryPrice, isPut, longSupplies, shortSupplies);
    }

    function getTotalSupplies(OptionToken[] memory optionTokens) public view returns (uint256[] memory totalSupplies) {
        totalSupplies = new uint256[](optionTokens.length);
        for (uint256 i = 0; i < optionTokens.length; i++) {
            totalSupplies[i] = optionTokens[i].totalSupply();
        }
    }

    function isExpired() public view returns (bool) {
        return block.timestamp >= expiryTime;
    }

    function isDisputePeriod() public view returns (bool) {
        return block.timestamp >= expiryTime && block.timestamp < expiryTime.add(disputePeriod);
    }

    function numStrikes() external view returns (uint256) {
        return strikePrices.length;
    }

    /**
     * Transfer amount from sender and do additional checks
     */
    function _transferIn(uint256 amountIn) private {
        // save gas
        IERC20 _baseToken = baseToken;
        uint256 balanceBefore = _baseToken.uniBalanceOf(address(this));
        _baseToken.uniTransferFromSenderToThis(amountIn);
        uint256 balanceAfter = _baseToken.uniBalanceOf(address(this));
        require(_baseToken.isETH() || balanceAfter.sub(balanceBefore) == amountIn, "Deflationary tokens not supported");
        require(balanceCap == 0 || _baseToken.uniBalanceOf(address(this)) <= balanceCap, "Balance cap exceeded");
    }

    // used for guarded launch
    function setBalanceCap(uint256 _balanceCap) external onlyOwner {
        balanceCap = _balanceCap;
    }

    // used for guarded launch
    function setTotalSupplyCap(uint256 _totalSupplyCap) external onlyOwner {
        totalSupplyCap = _totalSupplyCap;
    }

    // emergency use only. to be removed in future versions
    function pause() external onlyOwner {
        isPaused = true;
    }

    // emergency use only. to be removed in future versions
    function unpause() external onlyOwner {
        isPaused = false;
    }

    // emergency use only. to be removed in future versions
    function setOracle(IOracle _oracle) external onlyOwner {
        oracle = _oracle;
    }

    // emergency use only. to be removed in future versions
    function setExpiryTime(uint256 _expiryTime) external onlyOwner {
        expiryTime = _expiryTime;
    }

    // emergency use only. to be removed in future versions
    function setDisputePeriod(uint256 _disputePeriod) external onlyOwner {
        disputePeriod = _disputePeriod;
    }

    // emergency use only. to be removed in future versions
    function disputeExpiryPrice(uint256 _expiryPrice) external onlyOwner {
        require(isDisputePeriod(), "Not dispute period");
        require(isSettled, "Cannot be called before settlement");
        expiryPrice = _expiryPrice;

        // update cached payoff and pool value
        lastPayoff = getCurrentPayoff();
        poolValue = baseToken.uniBalanceOf(address(this)).sub(lastPayoff);
        emit Settle(_expiryPrice);
    }

    // emergency use only. to be removed in future versions
    function emergencyWithdraw() external onlyOwner {
        baseToken.uniTransfer(msg.sender, baseToken.uniBalanceOf(address(this)));
    }
}

// Part: OptionFactory

contract OptionFactory is CloneFactory, OptionSymbol, ReentrancyGuard {
    using Address for address;
    using SafeERC20 for IERC20;
    using UniERC20 for IERC20;
    using SafeMath for uint256;

    address public optionMarketLibrary;
    address public optionTokenLibrary;
    address[] public markets;

    constructor(address _optionMarketLibrary, address _optionTokenLibrary) public {
        require(_optionMarketLibrary != address(0), "optionMarketLibrary should not be address 0");
        require(_optionTokenLibrary != address(0), "optionTokenLibrary should not be address 0");
        optionMarketLibrary = _optionMarketLibrary;
        optionTokenLibrary = _optionTokenLibrary;
    }

    function createMarket(
        address baseAsset,
        address quoteAsset,
        address oracle,
        uint256[] memory strikePrices,
        uint256 expiryTime,
        bool isPut,
        uint256 tradingFee
    ) external nonReentrant returns (address marketAddress) {
        marketAddress = createClone(optionMarketLibrary);
        markets.push(marketAddress);

        string memory underlyingSymbol = IERC20(baseAsset).uniSymbol();
        string memory lpSymbol = getMarketSymbol(underlyingSymbol, expiryTime, isPut);
        address baseToken = isPut ? quoteAsset : baseAsset;

        address[] memory longTokens = new address[](strikePrices.length);
        address[] memory shortTokens = new address[](strikePrices.length);

        // use scoping to avoid stack too deep error
        {
            uint8 decimals = IERC20(baseToken).isETH() ? 18 : ERC20UpgradeSafe(baseToken).decimals();

            for (uint256 i = 0; i < strikePrices.length; i++) {
                longTokens[i] = createClone(optionTokenLibrary);
                string memory optionSymbol = getOptionSymbol(
                    underlyingSymbol,
                    strikePrices[i],
                    expiryTime,
                    isPut,
                    true
                );
                OptionToken(longTokens[i]).initialize(marketAddress, optionSymbol, optionSymbol, decimals);
            }

            for (uint256 i = 0; i < strikePrices.length; i++) {
                shortTokens[i] = createClone(optionTokenLibrary);
                string memory optionSymbol = getOptionSymbol(
                    underlyingSymbol,
                    strikePrices[i],
                    expiryTime,
                    isPut,
                    false
                );
                OptionToken(shortTokens[i]).initialize(marketAddress, optionSymbol, optionSymbol, decimals);
            }
        }

        OptionMarket(marketAddress).initialize(
            baseToken,
            oracle,
            longTokens,
            shortTokens,
            strikePrices,
            expiryTime,
            isPut,
            tradingFee,
            lpSymbol
        );

        // transfer ownership to sender
        OptionMarket(marketAddress).transferOwnership(msg.sender);
    }

    function numMarkets() external view returns (uint256) {
        return markets.length;
    }
}

// File: OptionRegistry.sol

contract OptionRegistry {
    using Address for address;
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    struct OptionDetails {
        bool isLongToken;
        uint256 strikeIndex;
        uint256 strikePrice;
    }

    OptionFactory public immutable factory;
    uint256 public lastIndex;

    mapping(IERC20 => mapping(uint256 => mapping(bool => OptionMarket))) internal markets; // baseToken => expiryTime => isPut => market
    mapping(OptionMarket => mapping(uint256 => mapping(bool => OptionToken))) internal options; // market => strikePrice => isLongToken
    mapping(OptionToken => OptionDetails) internal optionDetails;

    /**
     * @param _factory {OptionFactory} instance from which markets are retrieved
     * @param _lastIndex Don't add markets with this index or smaller. This saves
     * gas when `populateMarkets()` is initially called
     */
    constructor(address _factory, uint256 _lastIndex) public {
        factory = OptionFactory(_factory);
        lastIndex = _lastIndex;
    }

    /**
     * @dev Fetch option market
     * @param baseToken Address of base token. Same as underlying for calls and
     * strike currency for puts. Equal to 0x0 for ETH
     * @param expiryTime Expiry time as timestamp
     * @param isPut True if put, false if call
     */
    function getMarket(IERC20 baseToken, uint256 expiryTime, bool isPut) external view returns (OptionMarket) {
        return markets[baseToken][expiryTime][isPut];
    }

    /**
     * @dev Fetch option token
     * @param market Parent market
     * @param strikePrice Strike price in USDC multiplied by 1e18
     * @param isLongToken True if long position, false if short position
     */
    function getOption(OptionMarket market, uint256 strikePrice, bool isLongToken) external view returns (OptionToken) {
        return options[market][strikePrice][isLongToken];
    }

    /**
     * @dev Fetch option details
     * @param optionToken Option token
     */
    function getOptionDetails(OptionToken optionToken) external view returns (OptionDetails memory) {
        return optionDetails[optionToken];
    }

    /**
     * @dev Add mappings for any new markets that have been added to factory
     * since the last time this method was called
     */
    function populateMarkets() external {
        populateMarketsUntil(factory.numMarkets());
    }

    /**
     * @dev Same as {populateMarkets} but only adds markets up to a given index
     */
    function populateMarketsUntil(uint256 index) public {
        require(index > lastIndex, "OptionRegistry: No new markets to add");
        require(index <= factory.numMarkets(), "OptionRegistry: index out of bounds");

        while (lastIndex < index) {
            OptionMarket market = OptionMarket(factory.markets(lastIndex));
            _populateMarket(market);
            lastIndex = lastIndex.add(1);
        }
    }

    function _populateMarket(OptionMarket market) internal {
        markets[market.baseToken()][market.expiryTime()][market.isPut()] = market;

        uint256 numStrikes = market.numStrikes();
        for (uint256 i = 0; i < numStrikes; i = i.add(1)) {
            OptionToken longToken = market.longTokens(i);
            OptionToken shortToken = market.shortTokens(i);
            uint256 strikePrice = market.strikePrices(i);

            options[market][strikePrice][true] = longToken;
            options[market][strikePrice][false] = shortToken;
            optionDetails[longToken] = OptionDetails(true, i, strikePrice);
            optionDetails[shortToken] = OptionDetails(false, i, strikePrice);
        }
    }
}