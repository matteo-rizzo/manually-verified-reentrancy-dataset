/**
 *Submitted for verification at Etherscan.io on 2021-04-01
*/

// SPDX-License-Identifier: Unlicense

pragma solidity 0.6.12;



// Part: AggregatorV3Interface



// Part: OpenZeppelin/[email protected]/Address

/**
 * @dev Collection of functions related to the address type
 */


// Part: OpenZeppelin/[email protected]/Context

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

// Part: OpenZeppelin/[email protected]/IERC20

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


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


// Part: OpenZeppelin/[email protected]/Ownable

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
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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


// File: ChainlinkFeedsRegistry.sol

/**
 * @title   Chainlink Feeds Registry
 * @notice  Stores Chainlink feed addresses and provides getPrice() method to
 *          get the current price of a given token in USD
 * @dev     If a feed in USD exists, just use that. Otherwise multiply ETH/USD
 *          price with the price in ETH. For the price of USD, just return 1.
 */
contract ChainlinkFeedsRegistry is Ownable {
    using Address for address;
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    event AddFeed(bytes32 indexed currencyKey, string baseSymbol, string quoteSymbol, address feed);

    // stringToBytes32("ETH")
    bytes32 public constant ETH = 0x4554480000000000000000000000000000000000000000000000000000000000;

    // stringToBytes32("USD")
    bytes32 public constant USD = 0x5553440000000000000000000000000000000000000000000000000000000000;

    mapping(bytes32 => address) public usdFeeds;
    mapping(bytes32 => address) public ethFeeds;

    /**
     * @notice Get price in USD multiplied by 1e8. Returns 0 if no feed found.
     * @param currencyKey Token symbol converted to bytes32
     */
    function getPrice(bytes32 currencyKey) public view returns (uint256) {
        address usdFeed = usdFeeds[currencyKey];
        if (usdFeed != address(0)) {
            // USD feeds are already scaled by 1e8 so don't need to scale again
            return _latestPrice(usdFeed);
        }

        address ethFeed = ethFeeds[currencyKey];
        address ethUsdFeed = usdFeeds[ETH];
        if (ethFeed != address(0) && ethUsdFeed != address(0)) {
            uint256 price1 = _latestPrice(ethFeed);
            uint256 price2 = _latestPrice(ethUsdFeed);

            // USD feeds are scaled by 1e8 and ETH feeds by 1e18 so need to
            // divide by 1e18
            return price1.mul(price2).div(1e18);
        } else if (currencyKey == USD) {
            // For USD just return a price of 1
            return 1e8;
        }
    }

    function _latestPrice(address feed) internal view returns (uint256) {
        if (feed == address(0)) {
            return 0;
        }
        (, int256 price, , , ) = AggregatorV3Interface(feed).latestRoundData();
        return uint256(price);
    }

    /**
     * @notice Add `symbol`/USD Chainlink feed to registry. Use a value of 0x0
     * for `feed` to remove it from registry.
     */
    function addUsdFeed(string memory symbol, address feed) external onlyOwner {
        require(_latestPrice(feed) > 0, "Price should be > 0");
        bytes32 currencyKey = stringToBytes32(symbol);
        usdFeeds[currencyKey] = feed;
        emit AddFeed(currencyKey, symbol, "USD", feed);
    }

    /**
     * @notice Add `symbol`/ETH Chainlink feed to registry. Use a value of 0x0
     * for `feed` to remove it from registry.
     */
    function addEthFeed(string memory symbol, address feed) external onlyOwner {
        require(_latestPrice(feed) > 0, "Price should be > 0");
        bytes32 currencyKey = stringToBytes32(symbol);
        ethFeeds[currencyKey] = feed;
        emit AddFeed(currencyKey, symbol, "ETH", feed);
    }

    function getPriceFromSymbol(string memory symbol) external view returns (uint256) {
        return getPrice(stringToBytes32(symbol));
    }

    function stringToBytes32(string memory s) public pure returns (bytes32 result) {
        bytes memory b = bytes(s);
        if (b.length == 0) {
            return 0x0;
        }
        assembly {
            result := mload(add(s, 32))
        }
    }
}