/**
 *Submitted for verification at Etherscan.io on 2020-10-13
*/

// SPDX-License-Identifier: GPL-3.0-or-later

/**

Author: CoFiX Core, https://cofix.io
Commit hash: v0.9.5-1-g7141c43
Repository: https://github.com/Computable-Finance/CoFiX
Issues: https://github.com/Computable-Finance/CoFiX/issues

*/

pragma solidity 0.6.12;


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


// 
// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false


// 
/**
 * @dev Standard math utilities missing in the Solidity language.
 */


// 
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

// 


// 


// 
/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


// 


// 


// 
// Stake XToken to earn CoFi Token
contract CoFiXStakingRewards is ICoFiXStakingRewards, ReentrancyGuard {
    using SafeMath for uint256;

    /* ========== STATE VARIABLES ========== */

    address public override immutable rewardsToken; // CoFi
    address public override immutable stakingToken; // XToken or CNode

    address public immutable factory;

    uint256 public lastUpdateBlock;
    uint256 public rewardPerTokenStored;

    mapping(address => uint256) public userRewardPerTokenPaid;
    mapping(address => uint256) public rewards;

    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;

    /* ========== CONSTRUCTOR ========== */

    constructor(
        address _rewardsToken,
        address _stakingToken,
        address _factory
    ) public {
        rewardsToken = _rewardsToken;
        stakingToken = _stakingToken;
        require(ICoFiXFactory(_factory).getVaultForLP() != address(0), "VaultForLP not set yet"); // check
        factory = _factory;
        lastUpdateBlock = 11040688; // https://etherscan.io/block/countdown/11040688    
    }

    /* ========== VIEWS ========== */

    // replace cofixVault with rewardsVault, this could introduce more calls, but clear is more important 
    function rewardsVault() public virtual override view returns (address) {
        return ICoFiXFactory(factory).getVaultForLP();
    }

    function totalSupply() external override view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external override view returns (uint256) {
        return _balances[account];
    }

    function lastBlockRewardApplicable() public override view returns (uint256) {
        return block.number;
    }

    function rewardPerToken() public override view returns (uint256) {
        if (_totalSupply == 0) {
            return rewardPerTokenStored;
        }
        return
            rewardPerTokenStored.add(
                accrued().mul(1e18).div(_totalSupply)
            );
    }

    function _rewardPerTokenAndAccrued() internal view returns (uint256, uint256) {
        if (_totalSupply == 0) {
            // use the old rewardPerTokenStored, and accrued should be zero here
            // if not the new accrued amount will never be distributed to anyone
            return (rewardPerTokenStored, 0);
        }
        uint256 _accrued = accrued();
        uint256 _rewardPerToken = rewardPerTokenStored.add(
                _accrued.mul(1e18).div(_totalSupply)
            );
        return (_rewardPerToken, _accrued);
    }

    function rewardRate() public virtual override view returns (uint256) {
        return ICoFiXVaultForLP(rewardsVault()).currentPoolRate(address(this));
    }

    function accrued() public virtual override view returns (uint256) {
        // calc block rewards
        uint256 blockReward = lastBlockRewardApplicable().sub(lastUpdateBlock).mul(rewardRate());
        // query pair trading rewards
        uint256 tradingReward = ICoFiXVaultForLP(rewardsVault()).getPendingRewardOfLP(stakingToken);
        return blockReward.add(tradingReward);
    }

    function earned(address account) public override view returns (uint256) {
        return _balances[account].mul(rewardPerToken().sub(userRewardPerTokenPaid[account])).div(1e18).add(rewards[account]);
    }

    /* ========== MUTATIVE FUNCTIONS ========== */

    function stake(uint256 amount) external override nonReentrant updateReward(msg.sender) {
        require(amount > 0, "Cannot stake 0");
        _totalSupply = _totalSupply.add(amount);
        _balances[msg.sender] = _balances[msg.sender].add(amount);
        TransferHelper.safeTransferFrom(stakingToken, msg.sender, address(this), amount);
        emit Staked(msg.sender, amount);
    }

    function stakeForOther(address other, uint256 amount) external override nonReentrant updateReward(other) {
        require(amount > 0, "Cannot stake 0");
        _totalSupply = _totalSupply.add(amount);
        _balances[other] = _balances[other].add(amount);
        TransferHelper.safeTransferFrom(stakingToken, msg.sender, address(this), amount);
        emit StakedForOther(msg.sender, other, amount);
    }

    function withdraw(uint256 amount) public override nonReentrant updateReward(msg.sender) {
        require(amount > 0, "Cannot withdraw 0");
        _totalSupply = _totalSupply.sub(amount);
        _balances[msg.sender] = _balances[msg.sender].sub(amount);
        TransferHelper.safeTransfer(stakingToken, msg.sender, amount);
        emit Withdrawn(msg.sender, amount);
    }

    // Withdraw without caring about rewards. EMERGENCY ONLY.
    function emergencyWithdraw() external override nonReentrant {
        uint256 amount = _balances[msg.sender];
        require(amount > 0, "Cannot withdraw 0");
        _totalSupply = _totalSupply.sub(amount);
        _balances[msg.sender] = 0;
        rewards[msg.sender] = 0;
        TransferHelper.safeTransfer(stakingToken, msg.sender, amount);
        emit EmergencyWithdraw(msg.sender, amount);
    }

    function getReward() public override nonReentrant updateReward(msg.sender) {
        uint256 reward = rewards[msg.sender];
        if (reward > 0) {
            rewards[msg.sender] = 0;
            // TransferHelper.safeTransfer(rewardsToken, msg.sender, reward);
            uint256 transferred = _safeCoFiTransfer(msg.sender, reward);
            emit RewardPaid(msg.sender, transferred);
        }
    }

    // get CoFi rewards and staking into CoFiStakingRewards pool
    function getRewardAndStake() external override nonReentrant updateReward(msg.sender) {
        uint256 reward = rewards[msg.sender];
        if (reward > 0) {
            rewards[msg.sender] = 0;
            address cofiStakingPool = ICoFiXVaultForLP(rewardsVault()).getCoFiStakingPool(); // also work for VaultForCNode
            require(cofiStakingPool != address(0), "cofiStakingPool not set");
            // approve to staking pool
            address _rewardsToken = rewardsToken;
            IERC20(_rewardsToken).approve(cofiStakingPool, reward);
            ICoFiStakingRewards(cofiStakingPool).stakeForOther(msg.sender, reward);
            IERC20(_rewardsToken).approve(cofiStakingPool, 0); // ensure
            emit RewardPaid(msg.sender, reward);
        }
    }

    function exit() external override {
        withdraw(_balances[msg.sender]);
        getReward();
    }

    // add reward from trading pool or anyone else
    function addReward(uint256 amount) public override nonReentrant updateReward(address(0)) {
        // transfer from caller (router contract)
        TransferHelper.safeTransferFrom(rewardsToken, msg.sender, address(this), amount);
        // update rewardPerTokenStored
        rewardPerTokenStored = rewardPerTokenStored.add(amount.mul(1e18).div(_totalSupply));
        emit RewardAdded(msg.sender, amount);
    }

    // Safe CoFi transfer function, just in case if rounding error or ending of mining causes pool to not have enough CoFis.
    function _safeCoFiTransfer(address _to, uint256 _amount) internal returns (uint256) {
        uint256 cofiBal = IERC20(rewardsToken).balanceOf(address(this));
        if (_amount > cofiBal) {
            _amount = cofiBal;
        }
        TransferHelper.safeTransfer(rewardsToken, _to, _amount); // allow zero amount
        return _amount;
    }

    /* ========== MODIFIERS ========== */

    modifier updateReward(address account) virtual {
        // rewardPerTokenStored = rewardPerToken();
        // uint256 newAccrued = accrued();
        (uint256 newRewardPerToken, uint256 newAccrued) = _rewardPerTokenAndAccrued();
        rewardPerTokenStored = newRewardPerToken;
        if (newAccrued > 0) {
            // distributeReward could fail if CoFiXVaultForLP is not minter of CoFi anymore
            // Should set reward rate to zero first, and then do a settlement of pool reward by call getReward
            ICoFiXVaultForLP(rewardsVault()).distributeReward(address(this), newAccrued);
        } 
        lastUpdateBlock = lastBlockRewardApplicable();
        if (account != address(0)) {
            rewards[account] = earned(account);
            userRewardPerTokenPaid[account] = rewardPerTokenStored;
        }
        _;
    }

    /* ========== EVENTS ========== */

    event RewardAdded(address sender, uint256 reward);
    event Staked(address indexed user, uint256 amount);
    event StakedForOther(address indexed user, address indexed other, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);
}