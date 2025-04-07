/**
 *Submitted for verification at Etherscan.io on 2021-08-04
*/

// Dependency file: @openzeppelin/contracts/token/ERC20/IERC20.sol

// SPDX-License-Identifier: MIT

// pragma solidity ^0.6.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */



// Dependency file: @openzeppelin/contracts/math/SafeMath.sol


// pragma solidity ^0.6.0;

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



// Dependency file: @openzeppelin/contracts/utils/Address.sol


// pragma solidity ^0.6.2;

/**
 * @dev Collection of functions related to the address type
 */



// Dependency file: @openzeppelin/contracts/token/ERC20/SafeERC20.sol


// pragma solidity ^0.6.0;

// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import "@openzeppelin/contracts/math/SafeMath.sol";
// import "@openzeppelin/contracts/utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */



// Dependency file: @openzeppelin/contracts/GSN/Context.sol


// pragma solidity ^0.6.0;

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


// Dependency file: @openzeppelin/contracts/access/Ownable.sol


// pragma solidity ^0.6.0;

// import "@openzeppelin/contracts/GSN/Context.sol";
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


// Root file: contracts/others/StakingPRY.sol

pragma solidity ^0.6.10;

// import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
// import { SafeMath } from "@openzeppelin/contracts/math/SafeMath.sol";
// import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title StakingPRY
 * @author Prophecy
 *
 * Stake PRY earn PRY as reward
 */
contract StakingPRY is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    /* ============ Constants ============ */

    uint256 constant public ONE_MONTH = 2592000;

    /* ============ State Variables ============ */

    address public token;
    bool public isAcceptStaking = true;
    mapping(address => uint256) public stakeAmount;
    uint256 public totalStaked;
    uint256 public timePenalty;
    uint256 public timeMature;

    /* ============ Constructor ============ */

    constructor(address _token) public {
        token = _token;
    }

    /* ============ External/Public Functions ============ */

    /**
     * Stake PRY
     *
     * @param _amount               Amount of tokens to stake
     */
    function stake(uint256 _amount) public {
        require(isAcceptStaking == true, "staking is not accepted");
        require(_amount >= 1000e18, "cannot invest less than 1k PRY");
        require(_amount.add(stakeAmount[msg.sender]) <= 200000e18, "cannot invest more than 200k PRY");
        require(_amount.add(totalStaked) <= 5000000000e18, "total invest cannot be more than 5m PRY");
        IERC20(token).transferFrom(msg.sender, address(this), _amount);
        stakeAmount[msg.sender] = stakeAmount[msg.sender].add(_amount);
        totalStaked = totalStaked.add(_amount);
    }

    /**
     * Unstake PRY
     */
    function unstake() public {
        address userAddr = msg.sender;
        require(stakeAmount[userAddr] > 0, "no staking amount");

        // if staking is still accepted, you should only the original stake 
        if (isAcceptStaking == true) {
            IERC20(token).safeTransfer(userAddr, stakeAmount[userAddr]);
            totalStaked = totalStaked.sub(stakeAmount[userAddr]);
            stakeAmount[userAddr] = 0;
            return;
        }
        uint256 currentTime = block.timestamp;
        // if you unstakes after 90 days, you should receive the full reward + original stake
        if (timeMature < currentTime) {
            uint256 reward = stakeAmount[userAddr].mul(7).div(100);
            IERC20(token).safeTransfer(userAddr, stakeAmount[userAddr].add(reward));
            totalStaked = totalStaked.sub(stakeAmount[userAddr]);
            stakeAmount[userAddr] = 0;
            return;
        }
        // if you unstakes from day 31 - 89, you should receive 50% of the reward + original stake
        if (timePenalty < currentTime && currentTime <= timeMature) {
            uint256 reward = stakeAmount[userAddr].mul(7).div(200);
            IERC20(token).safeTransfer(userAddr, stakeAmount[userAddr].add(reward));
            totalStaked = totalStaked.sub(stakeAmount[userAddr]);
            stakeAmount[userAddr] = 0;
            return;
        }
        // if you unstakes from day 0 - 30, you should only the original stake
        if (currentTime <= timePenalty) {
            IERC20(token).safeTransfer(userAddr, stakeAmount[userAddr]);
            totalStaked = totalStaked.sub(stakeAmount[userAddr]);
            stakeAmount[userAddr] = 0;
            return;
        }
    }

    /**
     * Get total amount of PRY in this pool.
     */
    function getTotalBalance() public view returns (uint256) {
        return IERC20(token).balanceOf(address(this));
    }

    /**
     * Get time left to mature
     */
    function getTimeLeft() public view returns (uint256) {
        uint256 currentTime = block.timestamp;
        if (currentTime > timeMature) {
            return 0;
        } else {
            return timeMature.sub(currentTime);
        }
    }

    /* ============ Owner Functions ============ */

    /**
     * Turn on staking. Users can stake PRYs.
     */
    function turnOnStaking() public onlyOwner() {
        uint256 currentTime = block.timestamp;
        require(currentTime > timeMature, "the time of unstaking has not finished");
        isAcceptStaking = true;
        timeMature = 0;
        timePenalty = 0;
    }

    /**
     * Turn off staking and start reward period. Users can't stake
     */
    function turnOffStaking() public onlyOwner() {
        uint256 currentTime = block.timestamp;
        require(currentTime > timeMature, "the time of unstaking has not finished");
        isAcceptStaking = false;
        timeMature = currentTime.add(ONE_MONTH.mul(3)); // 90 days
        timePenalty = currentTime.add(ONE_MONTH); // 30 days
    }

    /**
     * Withdraw tokens emergency.
     *
     * @param _token                Token contract address
     * @param _to                   Address where the token withdraw to
     * @param _amount               Amount of tokens to withdraw
     */
    function emergencyWithdraw(address _token, address _to, uint256 _amount) external onlyOwner {
        IERC20 erc20Token = IERC20(_token);
        require(erc20Token.balanceOf(address(this)) > 0, "Insufficient balane");

        uint256 amountToWithdraw = _amount;
        if (_amount == 0) {
            amountToWithdraw = erc20Token.balanceOf(address(this));
        }
        erc20Token.safeTransfer(_to, amountToWithdraw);
    }
}