/**
 *Submitted for verification at Etherscan.io on 2021-09-12
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.6.5;

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


// File: @openzeppelin/contracts/utils/ReentrancyGuard.sol

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
        this;
        // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
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

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


// File: @openzeppelin/contracts/utils/Address.sol


/**
 * @dev Collection of functions related to the address type
 */



contract GunnerSale is ReentrancyGuard, Ownable {

    using SafeMath for uint256;
    using Address for address payable;

    mapping(address => uint256) participants;

    uint256 public buyPrice;
    uint256 public minimalGoal;
    uint256 public hardCap;

    IERC20 crowdsaleToken;

    uint256 constant tokenDecimals = 18;

    event SellToken(address recepient, uint tokensSold, uint value);

    address payable fundingAddress;
    uint256 public totalCollected;
    uint256 public totalSold;
    uint256 public start;
    bool stopped = false;

    constructor(IERC20 _token, address payable _fundingAddress) public {
        minimalGoal = 10000000000000000000;
        hardCap = 1000000000000000000000;
        buyPrice = 91666666666666;
        // 0,000091666666666666 ETH
        crowdsaleToken = _token;
        fundingAddress = _fundingAddress;
        start = getTime();
    }

    function getToken() external view returns (address)    {
        return address(crowdsaleToken);
    }

    // @notice: By default sells tokens on transfer
    receive() external payable {
        require(msg.value >= 100000000000000000, 'GunnerSale: Min 0.1 ETH');
        require(participants[msg.sender] <= 10000000000000000000, 'GunnerSale: Max 10 ETH');
        sell(msg.sender, msg.value);
    }

    // @notice: Function to sell tokens to buyer for eth
    function sell(address payable _recipient, uint256 _value) internal nonReentrant whenCrowdsaleAlive() {
        uint256 newTotalCollected = totalCollected.add(_value);

        if (hardCap < newTotalCollected) {
            // Refund anything above the hard cap
            uint256 refund = newTotalCollected.sub(hardCap);
            uint256 diff = _value.sub(refund);
            _recipient.sendValue(refund);
            _value = diff;
            newTotalCollected = totalCollected.add(_value);
        }

        // Token amount per price
        uint256 tokensSold = (_value).mul(10 ** tokenDecimals).div(buyPrice);

        // Send user tokens
        require(crowdsaleToken.transfer(_recipient, tokensSold), 'GunnerSale: Error transferring');

        emit SellToken(_recipient, tokensSold, _value);

        // Save participants
        participants[_recipient] = participants[_recipient].add(_value);

        fundingAddress.sendValue(_value);

        // Update total eth
        totalCollected = totalCollected.add(_value);

        // Update tokens sold
        totalSold = totalSold.add(tokensSold);
    }

    // @dev: Use this function to calculate how many tokens need to be deposited to crowdsale so it does not run out of tokens
    function totalTokensNeeded() external view returns (uint256) {
        return hardCap.mul(10 ** tokenDecimals).div(buyPrice);
    }

    // @notice: Hard stop crowdsale
    function stop() external onlyOwner() {
        stopped = true;
    }

    // @notice: Resume crowdsale
    function unstop() external onlyOwner() {
        stopped = false;
    }

    // @notice: Return unsold tokens to funding address
    function returnUnsold() external nonReentrant onlyOwner() {
        crowdsaleToken.transfer(fundingAddress, crowdsaleToken.balanceOf(address(this)));
    }

    function getTime() public view returns (uint256)    {
        return block.timestamp;
    }

    function isActive() public view returns (bool)    {
        return (
        totalCollected < hardCap && !stopped
        );
    }

    function isSuccessful() external view returns (bool)    {
        return (totalCollected >= minimalGoal);
    }

    modifier whenCrowdsaleAlive() {
        require(isActive());
        _;
    }

}