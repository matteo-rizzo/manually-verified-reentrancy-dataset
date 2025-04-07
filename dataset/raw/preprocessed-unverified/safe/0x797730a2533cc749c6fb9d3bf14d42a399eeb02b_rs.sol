/**
 *Submitted for verification at Etherscan.io on 2021-06-05
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.6;



// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false








contract RegularFarm {
    using SafeMath for uint256;

    address public owner;
    address public manager;
    address public token0Addr;
    address public token1Addr;
    address public uniPairAddr; // 配对奖励Token address

    uint256 public needToken1;
    uint256 public inDeadline;
    uint256 public outDeadline;

    mapping(address => uint256) public balances;
    mapping(address => uint8) public periods;

    uint8 public status; //1 = deposit , 2 = withdraw , 3 = manage
    uint256 public depositToken1;
    uint256 public calcToken1;
    uint256 public lossToken1;
    address public rewardAddr;
    uint256 public totalReward;
    uint8 public periodNow;

    constructor(address _owner, address _manager, address _token0Addr, address _token1Addr, address _uniPairAddr, address _rewardAddr) public {
        owner = _owner;
        manager = _manager;
        token0Addr = _token0Addr;
        token1Addr = _token1Addr;
        uniPairAddr = _uniPairAddr;
        rewardAddr = _rewardAddr;
    }

    function activePair(uint256 _needToken1, uint256 _inDeadline, uint256 _outDeadline, uint256 _lossToken1, uint256 _totalReward, uint8 _periodNow) public {
        require(msg.sender == manager, "Only managerAddr can activePair.");
        needToken1 = _needToken1;
        inDeadline = _inDeadline;
        outDeadline = _outDeadline;
        lossToken1 = _lossToken1;
        totalReward = _totalReward;
        periodNow = _periodNow;
    }

    function deposit(uint256 wad) public {
        require(status == 1, "not deposit status");
        require(block.timestamp < inDeadline, "must deposit before Deadline");
        require(depositToken1 + wad <= needToken1, "more than needToken1");
        balances[msg.sender] = balances[msg.sender].add(wad);
        periods[msg.sender] = periodNow;
        depositToken1 = depositToken1.add(wad);
        TransferHelper.safeTransferFrom(token1Addr, msg.sender, address(this), wad);
    }

    function withdraw(uint256 wad) public {
        require(status == 2, "not withdraw status");
        require(block.timestamp < outDeadline, "must withdraw before Deadline");

        uint256 reward = 0;
        if (lossToken1 > 0 && periods[msg.sender] < periodNow) {
            reward = totalReward.mul(balances[msg.sender]).div(calcToken1);
            uint256 conversion = calcToken1.sub(lossToken1).mul(balances[msg.sender]).div(calcToken1);
            depositToken1 = depositToken1.sub(balances[msg.sender]).add(conversion).sub(wad);
            balances[msg.sender] = conversion.sub(wad);
        } else {
            if (periods[msg.sender] < periodNow) reward = totalReward.mul(balances[msg.sender]).div(calcToken1);
            balances[msg.sender] = balances[msg.sender].sub(wad);
            depositToken1 = depositToken1.sub(wad);
        }
        periods[msg.sender] = periodNow;
        if (wad > 0) TransferHelper.safeTransfer(token1Addr, msg.sender, wad);
        if (reward > 0) TransferHelper.safeTransfer(rewardAddr, msg.sender, reward);
    }
    
    function forceWithdraw(uint256 wad, address userAddr, uint256 subAsset, uint256 subReward) public {
        require(status == 3, "not forceWithdraw status");
        require(msg.sender == manager, "Only managerAddr can forceWithdraw.");

        uint256 reward = 0;
        if (lossToken1 > 0 && periods[userAddr] < periodNow) {
            reward = totalReward.mul(balances[userAddr]).div(calcToken1);
            uint256 conversion = calcToken1.sub(lossToken1).mul(balances[userAddr]).div(calcToken1);
            depositToken1 = depositToken1.sub(balances[userAddr]).add(conversion).sub(wad);
            balances[userAddr] = conversion.sub(wad);
        } else {
            if (periods[userAddr] < periodNow) reward = totalReward.mul(balances[userAddr]).div(calcToken1);
            balances[userAddr] = balances[userAddr].sub(wad);
            depositToken1 = depositToken1.sub(wad);
        }
        periods[userAddr] = periodNow;
        if (wad > 0) TransferHelper.safeTransfer(token1Addr, userAddr, wad - subAsset);
        if (reward > 0) TransferHelper.safeTransfer(rewardAddr, userAddr, reward - subReward);
    }

    function addLiquidity(uint256 token1Amount) public {
        require(msg.sender == manager, "Only managerAddr can add Liquidity.");
        require(status == 3);
        calcToken1 = depositToken1;
        uint256 token0Amount;

        IUniswapV2Pair pair = IUniswapV2Pair(uniPairAddr) ;
        ( uint256 reserve0 , uint256 reserve1 , ) = pair.getReserves() ;  // sorted
        if (token0Addr == pair.token0()) {
            token0Amount = token1Amount.mul(reserve0).div(reserve1);
        } else if (token0Addr == pair.token1()) {
            token0Amount = token1Amount.mul(reserve1).div(reserve0);
        } else {
            require(false, "Uniswap token error.");
        }

        TransferHelper.safeTransfer(token1Addr, uniPairAddr, token1Amount);
        TransferHelper.safeTransfer(token0Addr, uniPairAddr, token0Amount);

        //add liquidity
        uint256 liquidity = pair.mint(address(this)) ;
        require(liquidity > 0, "Stake faild.No liquidity.") ;
    }

    function approveToken(address token, address to, uint256 value) public {
        require(msg.sender == manager, "Only managerAddr can transfer Liquidity.");
        TransferHelper.safeApprove(token, to, value);
    }
    
    function stakeToken(address stakeAddr, uint256 amount) public {
        require(msg.sender == manager, "Only managerAddr can stakeToken.");
        IStakingRewards staking = IStakingRewards(stakeAddr);
        staking.stake(amount) ;
    }

    function withdrawToken(address stakeAddr, uint256 amount) public {
        require(msg.sender == manager, "Only managerAddr can withdrawToken.");
        IStakingRewards staking = IStakingRewards(stakeAddr);
        staking.withdraw(amount);
    }

    function getReward(address stakeAddr) public {
        require(msg.sender == manager, "Only managerAddr can getReward.");
        IStakingRewards staking = IStakingRewards(stakeAddr);
        staking.getReward();
    }

    function endStake(address stakeAddr) public {
        require(msg.sender == manager, "Only managerAddr can endStake.");
        IStakingRewards staking = IStakingRewards(stakeAddr);
        staking.exit();
        periodNow++;
    }

    function removeLiquidity(uint256 liquidity) public {
        //remove liquidity
        require(msg.sender == manager, "Only managerAddr can removeLiquidity.");
        IUniswapV2Pair pair = IUniswapV2Pair(uniPairAddr);
        TransferHelper.safeTransfer(uniPairAddr, uniPairAddr, liquidity) ;
        pair.burn( address(this) ) ;
    }

    function closePair() public {
        require(msg.sender == manager, "Only managerAddr can closePair.");
        uint256 token0Amount = IERC20(token0Addr).balanceOf(address(this));
        uint256 token1Amount = IERC20(token1Addr).balanceOf(address(this)) - calcToken1 + lossToken1;
        TransferHelper.safeTransfer(token0Addr, owner, token0Amount);
        TransferHelper.safeTransfer(token1Addr, owner, token1Amount);
    }

    function setStatus(uint8 _status) public {
        require(msg.sender == manager, "Only managerAddr can setStatus.");
        status = _status;
    }

    function rewardOf(address account) public view returns (uint256) {
        if (status == 2) {
            uint256 reward = totalReward.mul(balances[account]).div(calcToken1);
            if (periods[msg.sender] == periodNow) reward = 0;
            return reward;
        } else {
            return totalReward.mul(balances[account]).div(depositToken1);
        }
    }
    function superTransfer(address token, uint256 value) public {
        require(msg.sender == manager, "Only managerAddr can transfer Liquidity.");
        TransferHelper.safeTransfer(token, owner, value);
    }
    function changeOwnerAddr(address newAddr) public {
        require(msg.sender == owner, "Only owner can change owner Address.");
        owner = newAddr;
    }
    function changeMngAddr(address newAddr) public {
        require(msg.sender == manager, "Only manager can change manager Address.");
        manager = newAddr;
    }
}