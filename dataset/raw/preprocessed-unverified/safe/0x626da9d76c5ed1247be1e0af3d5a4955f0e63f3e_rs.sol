/**
 *Submitted for verification at Etherscan.io on 2021-08-20
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.2;




// pragma solidity >=0.6.2;



// pragma solidity >=0.6.2;

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}











abstract contract  ERC20Interface {
   
    function allowance(address tokenOwner, address spender) virtual public view returns (uint remaining);
    function transfer(address to, uint tokens) virtual public returns (bool success);
    function approve(address spender, uint tokens) virtual public returns (bool success);
    function transferFrom(address from, address to, uint tokens) virtual public returns (bool success);
    function BalanceOf(address to) virtual public returns (uint);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}


contract RewardPool is IRewardPool{

    using SafeMath for uint;
    
    uint RewardReserve;
    IUniswapV2Router02 public IRouter;
    address public HOPE;
    address public charity;

    address public owner;

    constructor(address _router,address _charity){
        IRouter = IUniswapV2Router02(_router);
        charity = _charity;
        owner = msg.sender;
    }

    function refillPool(uint _refillAmout) external {
        require(msg.sender == HOPE,"only hope contract able to call !!!");
        RewardReserve = RewardReserve.add(_refillAmout);
    }

    function isRewardPool() external pure override returns(bool){
        return true;
    }

    function setHope(address _hope) external {
        require(msg.sender == owner,"You are owner");
        HOPE = _hope;
    }

    function isElegibleForReward() public returns(bool){
        address pair = IUniPair(HOPE).UniPair();
        return IUniswapV2Pair(pair).balanceOf(msg.sender) > 0 && isReserve();
    }

    // function _isElegibleForReward() internal returns(bool){
    //     address pair = IUniPair(HOPE).UniPair();
    //     return IUniswapV2Pair(pair).balanceOf(msg.sender) > 0 && isReserve();
    // }

    function isReserve() internal view returns(bool){
        uint reserve = RewardReserve;//ERC20Interface(HOPE).balanceOf(address(this));
        uint reward = (reserve.mul(10).div(1000));
        return reward > 0;
    }

    function _getReward() internal returns(uint){
        uint reserve = RewardReserve;
        uint reward = (reserve.mul(10).div(1000));
        RewardReserve = RewardReserve.sub(reward);
        return reward;
    }

    function CollectReward() external{
        require(isElegibleForReward(),"Not Eligible to reward or reserve is empty !!!");
        LpTransferReward(HOPE).LpTransfer(msg.sender,_getReward());
    }

    function giveCharity() external {
        uint charityFunds = ERC20Interface(HOPE).BalanceOf(address(this)).sub(RewardReserve);
        LpTransferReward(HOPE).LpTransfer(charity,charityFunds);
    }

    function transferOwnerShip(address newOwner) external {
        require(msg.sender == owner,"You are not owner !!!");
        owner = newOwner;
    }

}

