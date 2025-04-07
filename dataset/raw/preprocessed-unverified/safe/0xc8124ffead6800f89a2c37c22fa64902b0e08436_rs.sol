/**
 *Submitted for verification at Etherscan.io on 2020-11-05
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.6.6;


// 
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

// 
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

abstract contract PriceProvider is Ownable {

    address public manager;

    string public providerName;

    uint8 public constant decimals = 2; // decimals of ethereum price
    bool public updateRequred;

    /**
     * @dev Constructor.
     * @param _providerName Name of provider.
     * @param _manager Address of price manager.
     */

    constructor(string memory _providerName, address _manager, bool _updateRequred) public Ownable() {
        providerName = _providerName;
        manager = _manager;
        updateRequred = _updateRequred;
    }

    /**
     * @dev Set Price manager.
     * @param _manager Address of price manager.
     */

    function setManager(address _manager) external onlyOwner {
        manager = _manager;
    }

    /**
     * @return Last ethereum price.
     */

    function lastPrice() public virtual view returns (uint32);
}

// 
/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


/**
 * @dev Optional functions from the ERC20 standard.
 */
abstract contract ERC20Detailed is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    /**
     * @dev Sets the values for `name`, `symbol`, and `decimals`. All three of
     * these values are immutable: they can only be set once during
     * construction.
     */
    constructor (string memory name, string memory symbol, uint8 decimals) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
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
     * Ether and Wei.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }
}

// a library for handling binary fixed point numbers (https://en.wikipedia.org/wiki/Q_(number_format))




// library with helper methods for oracles that are concerned with computing average prices


// 
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




contract PriceProviderUniswap is PriceProvider {

    using FixedPoint for *;
    using SafeMath for uint;

    IUniswapV2Pair public immutable pair;

    address immutable weth;
    address public immutable stableToken;

    uint priceCumulativeLast;
    uint price1CumulativeLast;
    uint32 blockTimestampLast;
    bool wethIsToken0;
    FixedPoint.uq112x112 priceAverage;

    /**
     * @dev Constructor.
     * @param _manager Address of price manager.
     */

    constructor(address _manager, address _factory, address _weth, address _stableToken) public PriceProvider("Uniswap", _manager, true) {
        IUniswapV2Pair _pair = IUniswapV2Pair(UniswapV2Library.pairFor(_factory, _weth, _stableToken));
        pair = _pair;
        weth = _weth;
        if (_weth == _pair.token0()) {
            wethIsToken0 = true;
        } else {
            wethIsToken0 = false;
        }
        stableToken = _stableToken;

        if (wethIsToken0 == true) {
            priceCumulativeLast = _pair.price0CumulativeLast();
        } else {
            priceCumulativeLast = _pair.price1CumulativeLast();
        }

        (,,blockTimestampLast) = _pair.getReserves();
    }

    function update() external {
        require(msg.sender == manager, "manager!");
        (uint price0Cumulative, uint price1Cumulative, uint32 blockTimestamp) =
            UniswapV2OracleLibrary.currentCumulativePrices(address(pair));
        uint32 timeElapsed = blockTimestamp - blockTimestampLast; // overflow is desired

        // overflow is desired, casting never truncates
        // cumulative price is in (uq112x112 price * seconds) units so we simply wrap it after division by time elapsed
        if (wethIsToken0 == true) {
            priceAverage = FixedPoint.uq112x112(uint224((price0Cumulative - priceCumulativeLast) / timeElapsed));
            priceCumulativeLast = price0Cumulative;
        } else {
            priceAverage = FixedPoint.uq112x112(uint224((price1Cumulative - priceCumulativeLast) / timeElapsed));
            priceCumulativeLast = price1Cumulative;
        }

        blockTimestampLast = blockTimestamp;
    }

    /**
     * @return price - Last ethereum price.
     */

    function lastPrice() public override view returns (uint32 price) {
        uint amountOut = priceAverage.mul(1 ether).decode144();
        uint8 stableTokenDecimals = ERC20Detailed(stableToken).decimals();
        if (stableTokenDecimals >= decimals) {
            price = uint32(amountOut.div(10 ** uint(stableTokenDecimals - decimals)));
        } else {
            price = uint32(amountOut.mul(10 ** uint(decimals - stableTokenDecimals)));
        }
    }
}