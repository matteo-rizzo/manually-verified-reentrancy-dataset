/**
 *Submitted for verification at Etherscan.io on 2021-01-20
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

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


/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */




interface IFaasPool is IERC20 {
    function getBalance(address token) external view returns (uint256);

    function getUserInfo(uint256 _pid, address _account)
        external
        view
        returns (
            uint256 amount,
            uint256 rewardDebt,
            uint256 accumulatedEarned,
            uint256 lockReward,
            uint256 lockRewardReleased
        );
}

contract BsdVote is IVoteProxy {
    using SafeMath for uint256;

    IFaasPool[10] public faasPools;
    IERC20[10] public stakePools;
    IERC20 bsdsToken;
    address public bsds;
    uint256 public totalFaasPools;
    uint256 public totalStakePools;
    address public governance;

    constructor(
        address _bsds,
        address[] memory _faasPoolAddresses,
        address[] memory _stakePoolAddresses
    ) public {
        _setFaasPools(_faasPoolAddresses);
        _setStakePools(_stakePoolAddresses);
        bsds = _bsds;
        bsdsToken = IERC20(bsds);
        governance = msg.sender;
    }

    function _setFaasPools(address[] memory _faasPoolAddresses) internal {
        totalFaasPools = _faasPoolAddresses.length;
        for (uint256 i = 0; i < totalFaasPools; i++) {
            faasPools[i] = IFaasPool(_faasPoolAddresses[i]);
        }
    }

    function _setStakePools(address[] memory _stakePoolAddresses) internal {
        totalStakePools = _stakePoolAddresses.length;
        for (uint256 i = 0; i < totalStakePools; i++) {
            stakePools[i] = IERC20(_stakePoolAddresses[i]);
        }
    }

    function decimals() public pure virtual override returns (uint8) {
        return uint8(18);
    }

    function totalSupply() public view override returns (uint256) {
        uint256 totalSupplyPool = 0;
        uint256 i;
        for (i = 0; i < totalFaasPools; i++) {
            totalSupplyPool = totalSupplyPool.add(bsdsToken.balanceOf(address(faasPools[i])));
        }
        uint256 totalSupplyStake = 0;
        for (i = 0; i < totalStakePools; i++) {
            totalSupplyStake = totalSupplyStake.add(bsdsToken.balanceOf(address(stakePools[i])));
        }
        return totalSupplyPool.add(totalSupplyStake);
    }

    function totalInFaaSPool() public view returns (uint256) {
        uint256 total = 0;
        uint256 i;
        for (i = 0; i < totalFaasPools; i++) {
            total = total.add(bsdsToken.balanceOf(address(faasPools[i])));
        }
        return total;
    }

    function totalInStakePool() public view returns (uint256) {
        uint256 total = 0;
        uint256 i;
        for (i = 0; i < totalStakePools; i++) {
            total = total.add(bsdsToken.balanceOf(address(stakePools[i])));
        }
        return total;
    }

    function getBsdsAmountInPool(address _voter) internal view returns (uint256) {
        uint256 stakeAmount = 0;
        for (uint256 i = 0; i < totalFaasPools; i++) {
            (uint256 _stakeAmountInPool, , , , ) = faasPools[i].getUserInfo(0, _voter);
            stakeAmount = stakeAmount.add(_stakeAmountInPool.mul(faasPools[i].getBalance(bsds)).div(faasPools[i].totalSupply()));
        }
        return stakeAmount;
    }

    function getBsdsAmountInStakeContracts(address _voter) internal view returns (uint256) {
        uint256 stakeAmount = 0;
        for (uint256 i = 0; i < totalStakePools; i++) {
            stakeAmount = stakeAmount.add(stakePools[i].balanceOf(_voter));
        }
        return stakeAmount;
    }

    function balanceOf(address _voter) public view override returns (uint256) {
        uint256 balanceInPool = getBsdsAmountInPool(_voter);
        uint256 balanceInStakeContract = getBsdsAmountInStakeContracts(_voter);
        return balanceInPool.add(balanceInStakeContract);
    }

    function setFaasPools(address[] memory _faasPoolAddresses) external {
        require(msg.sender == governance, "!governance");
        _setFaasPools(_faasPoolAddresses);
    }

    function setStakePools(address[] memory _stakePoolAddresses) external {
        require(msg.sender == governance, "!governance");
        _setStakePools(_stakePoolAddresses);
    }
}