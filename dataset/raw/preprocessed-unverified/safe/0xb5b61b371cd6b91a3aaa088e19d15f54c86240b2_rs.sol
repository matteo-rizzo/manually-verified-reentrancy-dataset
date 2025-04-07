/**
 *Submitted for verification at Etherscan.io on 2021-07-17
*/

pragma solidity ^0.6.3;


// SPDX-License-Identifier: MIT
/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


// SPDX-License-Identifier: MIT
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


// SPDX-License-Identifier: MIT
/**
 * @dev Collection of functions related to the address type
 */


// SPDX-License-Identifier: MIT
/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */


// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: MIT
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

contract NightLifeStaking is Context, Ownable {
    using SafeMath for uint256;
    using Address for address;
    using SafeERC20 for IERC20;

    address public lpToken;
    address public rewardToken;
    
	address public NLIFEWallet;

    struct STAKE {
        uint256 amount;
        uint256 lastUpdatedAt;
    }

    mapping(address => STAKE) public _stakeInfo;
    address[] public _stakers;

    event Stake(address _staker, uint256 amount);
    event Unstake(address _staker, uint256 amount);
    event Withdraw(address _staker, uint256 amount);

    constructor(address _rewardToken) public {
        rewardToken = _rewardToken;
        NLIFEWallet = _msgSender();
    }

    /**
     * @dev update NLIFE wallet address
     */

    function updateNLIFEWallet(address _newAddr) public onlyOwner {
        require(_newAddr != address(0), "Avoid Zero Address");
        NLIFEWallet = _newAddr;
    }

    function totalRewards() public view returns (uint256) {
        return IERC20(rewardToken).balanceOf(address(this));
    }

    function isStakeHolder(address _account) public view returns (bool) {
        return _stakeInfo[_account].amount > 0;
    }

    function setLPToken(address _lpToken) public onlyOwner {
        lpToken = _lpToken;
    }

    function setRewardToken(address _rewardToken) public onlyOwner {
        rewardToken = _rewardToken;
    }

    function rewardTokenAddr() public view returns (address) {
        return rewardToken;
    }

    function rewardOf(address _staker) public view returns (uint256) {
        STAKE memory _stakeDetail = _stakeInfo[_staker];

        uint256 _rewards = totalRewards();
        uint256 _singlePart =
            _stakeDetail.amount.mul(
                block.timestamp.sub(_stakeDetail.lastUpdatedAt)
            );

        uint256 _totalPart;

        for (uint256 i = 0; i < _stakers.length; i++) {
            STAKE memory _singleStake = _stakeInfo[_stakers[i]];

            _totalPart = _totalPart.add(
                _singleStake.amount.mul(
                    block.timestamp.sub(_singleStake.lastUpdatedAt)
                )
            );
        }

        if (_totalPart == 0) return 0;

        return _rewards.mul(_singlePart).div(_totalPart);
    }

    function stake(uint256 _amount) public {
        IERC20(lpToken).safeTransferFrom(_msgSender(), address(this), _amount);

        STAKE storage _stake = _stakeInfo[_msgSender()];

        if (_stake.amount > 0) {
            uint256 reward = rewardOf(_msgSender());
            IERC20(rewardToken).safeTransfer(_msgSender(), reward);
            _stake.lastUpdatedAt = block.timestamp;
            _stake.amount = _stake.amount.add(_amount);
            emit Withdraw(_msgSender(), reward);
        } else {
            _stake.lastUpdatedAt = block.timestamp;
            _stake.amount = _amount;
            _stakers.push(_msgSender());
        }

        emit Stake(_msgSender(), _amount);
    }

    function unstake() public {
        require(_stakeInfo[_msgSender()].amount > 0, "Not staking");

        STAKE storage _stake = _stakeInfo[_msgSender()];
        uint256 reward = rewardOf(_msgSender());
        uint256 amount = _stake.amount;

        IERC20(rewardToken).safeTransfer(_msgSender(), reward);

        _stake.amount = 0;
        _stake.lastUpdatedAt = block.timestamp;

        for (uint256 i = 0; i < _stakers.length; i++) {
            if (_stakers[i] == _msgSender()) {
                _stakers[i] = _stakers[_stakers.length - 1];
                _stakers.pop();
                break;
            }
        }

        uint256 fee = amount.div(100);
        uint256 _amount = amount.sub(fee);
        IERC20(lpToken).safeTransfer(_msgSender(), _amount);
        IERC20(lpToken).safeTransfer(NLIFEWallet, fee);
        emit Unstake(_msgSender(), amount);
    }

    function claimReward() public {
        STAKE storage _stake = _stakeInfo[_msgSender()];
        uint256 reward = rewardOf(_msgSender());
        _stake.lastUpdatedAt = block.timestamp;

        IERC20(rewardToken).safeTransfer(_msgSender(), reward);
        emit Withdraw(_msgSender(), reward);
    }
}