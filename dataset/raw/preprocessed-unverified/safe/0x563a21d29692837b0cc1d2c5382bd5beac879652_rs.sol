/**
 *Submitted for verification at Etherscan.io on 2021-05-28
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

// File: @openzeppelin/contracts/utils/Context.sol

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

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


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

// File: contracts/TokenClaimer.sol
contract TokenClaimer is Ownable {

    using SafeMath for uint256;
    
    address public blesToken;

    uint256 public fromBlock;
    uint256 public toBlock;
    uint256 public rewardPerBlock;

    uint256 public totalShares;
    mapping(address => uint256) public userShares;
    mapping(address => uint256) public userClaimed;

    constructor() public {}

    function setUp(address blesToken_, uint256 fromBlock_, uint256 toBlock_, uint256 rewardPerBlock_) external onlyOwner {
        blesToken = blesToken_;
        fromBlock = fromBlock_;
        toBlock = toBlock_;
        rewardPerBlock = rewardPerBlock_;
    }

    function setUserShares(address who_, uint256 amount_) external onlyOwner {
        if (amount_ >= userShares[who_]) {
            totalShares = totalShares.add(amount_.sub(userShares[who_]));
        } else {
            totalShares = totalShares.sub(userShares[who_].sub(amount_));
        }

        userShares[who_] = amount_;
    }

    function setUserSharesBatch(address[] calldata whoArray_, uint256[] calldata amountArray_) external onlyOwner {
        require(whoArray_.length == amountArray_.length);

        uint256 totalTemp = totalShares;
        for (uint256 i = 0; i < whoArray_.length; ++i) {
            address who = whoArray_[i];
            uint256 amount = amountArray_[i];

            if (amount >= userShares[who]) {
                totalTemp = totalTemp.add(amount.sub(userShares[who]));
            } else {
                totalTemp = totalTemp.sub(userShares[who].sub(amount));
            }

            userShares[who] = amount;
        }

        totalShares = totalTemp;
    }

    function getTotalAmount(address who_) public view returns(uint256) {
        if (block.number <= fromBlock) {
            return 0;
        }

        uint256 count = block.number > toBlock ? toBlock.sub(fromBlock) : block.number.sub(fromBlock);
        return rewardPerBlock.mul(count).mul(userShares[who_]).div(totalShares);
    }

    function getRemainingAmount(address who_) public view returns(uint256) {
        return getTotalAmount(who_).sub(userClaimed[who_]);
    }

    function claim() external {
        uint256 amount = getRemainingAmount(msg.sender);
        IERC20(blesToken).transfer(msg.sender, amount);
        userClaimed[msg.sender] = userClaimed[msg.sender].add(amount);
    }
}