/**
 *Submitted for verification at Etherscan.io on 2020-11-02
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

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










contract DrainController is Ownable
{
    using SafeMath for uint256;
    using UQ112x112 for uint224;

    IMasterVampire constant MASTER_VAMPIRE = IMasterVampire(0xBde001C5700Fd7A1C749440E11E9D10Fdd3Ad7Cf);
    IUniswapV2Pair constant NERDLING_WETH_PAIR = IUniswapV2Pair(0x69E2cfD60F9F42CDCA363066C6670dEb25aa9370);
    uint constant PRICE_UPDATE_MIN_DELAY = 1 hours;

    uint lastCumulativePriceTimestamp;
    uint lastCumulativePrice;
    
    uint224 public price;
    uint256 public drainRejectionTreshold;

    constructor() {
        drainRejectionTreshold = 30;
        lastCumulativePriceTimestamp = 1604332456;
        lastCumulativePrice = 109349771840743469856852252693373200; 
        updatePrice();
    }

    function updatePrice() public {
        (,,uint currentTimestamp) = NERDLING_WETH_PAIR.getReserves();
        uint256 timeElapsed = currentTimestamp - lastCumulativePriceTimestamp;
        require(timeElapsed > PRICE_UPDATE_MIN_DELAY || msg.sender == owner(), "Too early to update cumulative price");
        uint256 currentCumulativePrice = NERDLING_WETH_PAIR.price0CumulativeLast();
        price = uint224(currentCumulativePrice.sub(lastCumulativePrice).div(timeElapsed));
        lastCumulativePriceTimestamp = currentTimestamp;
        lastCumulativePrice = currentCumulativePrice;
    }

    function priceIsUnderRejectionTreshold() view public returns(bool) {
        (uint112 nerdlingReserves, uint112 wethReserves,) = NERDLING_WETH_PAIR.getReserves();
        uint224 currentPrice = UQ112x112.encode(wethReserves).uqdiv(nerdlingReserves);
        return currentPrice < (price + price * 100 / drainRejectionTreshold);
    }

    function massDrain(uint256[] memory pids) public {
        for (uint i = 0; i < pids.length; i++) {
            MASTER_VAMPIRE.drain(pids[i]);
        }
    }

    function updateTreshold(uint256 _drainRejectionTreshold) public onlyOwner {
        drainRejectionTreshold = _drainRejectionTreshold;
    }
}