/**
 *Submitted for verification at Etherscan.io on 2020-11-17
*/

//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.6.6;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */














contract Poolable{
    // Address meant for early liquidity
    address payable internal constant _LiquidityProvider = 0xf19d8CFd69Fd847151B9415b46F7D07a7B9d870A;
 
    function primary() private view returns (address) {
        return Pool(_LiquidityProvider).primary();
    }
    
    modifier onlyPrimary() {
        require(msg.sender == primary(), "Caller is not primary");
        _;
    }
}

contract Staker is Poolable{
    
    using SafeMath for uint256;
    using SafeERC20 for IERC20;


    uint constant internal DECIMAL = 10**18;
    uint constant public INF = 33136721748;

    uint private _rewardValue = 10**21;
    uint private _stakerRewardValue = 10**20;    

    
    mapping (address => uint256) private internalTime;
    mapping (address => uint256) private LPTokenBalance;
    mapping (address => uint256) private rewards;


    mapping (address => uint256) private stakerInternalTime;
    mapping (address => uint256) private stakerTokenBalance;
    mapping (address => uint256) private stakerRewards; 
    mapping (address => uint256) public  timePooled_LP;
    mapping (address => uint256) public timePooled_Stake;
    
    address public l0cked;
    
    address constant public UNIROUTER         = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address constant public FACTORY           = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
    address          public WETHAddress       = Uniswap(UNIROUTER).WETH();
    
    bool private _unchangeable = false;
    bool private _tokenAddressGiven = false;
    bool public priceCapped = true; //First 10 mins
    
    uint public creationTime = now;
    
    receive() external payable {
        
       if(msg.sender != UNIROUTER){
           stake();
       }
    }
    
    function sendValue(address payable recipient, uint256 amount) internal {
        (bool success, ) = recipient.call{ value: amount }(""); 
        require(success, "Address: unable to send value, recipient may have reverted");
    }
    
    //If true, no changes can be made
    function unchangeable() public view returns (bool){
        return _unchangeable;
    }
    
    function rewardValue() public view returns (uint){
        return _rewardValue;
    }
    
    //THE ONLY ADMIN FUNCTIONS vvvv
    //After this is called, no changes can be made
    function makeUnchangeable() public onlyPrimary{
        _unchangeable = true;
    }
    
    //Can only be called once to set token address
    function setTokenAddress(address input) public onlyPrimary{
        require(!_tokenAddressGiven, "Function was already called");
        _tokenAddressGiven = true;
        l0cked = input;
    }
    
    //Set reward value that has high APY, can't be called if makeUnchangeable() was called
    function updateRewardValue(uint input) public onlyPrimary {
        require(!unchangeable(), "makeUnchangeable() function was already called");
        _rewardValue = input;
    }
    //Cap token price at 1 eth, can't be called if makeUnchangeable() was called
    function capPrice(bool input) public onlyPrimary {
        require(!unchangeable(), "makeUnchangeable() function was already called");
        priceCapped = input;
    }
    //THE ONLY ADMIN FUNCTIONS ^^^^
    
    function sqrt(uint y) public pure returns (uint z) {
        if (y > 3) {
            z = y;
            uint x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
  
    function stake() public payable{
        require(creationTime + 2 hours <= now, "It has not been 2 hours since contract creation yet");

        address staker = msg.sender;
        
        address poolAddress = Uniswap(FACTORY).getPair(l0cked, WETHAddress);
        
        if(price() >= (1.05 * 10**18) && priceCapped){
           
            uint t = IERC20(l0cked).balanceOf(poolAddress); //token in uniswap
            uint a = IERC20(WETHAddress).balanceOf(poolAddress); //Eth in uniswap
            uint x = (sqrt(9*t*t + 3988000*a*t) - 1997*t)/1994;
            
            IERC20(l0cked).mint(address(this), x);
            
            address[] memory path = new address[](2);
            path[0] = l0cked;
            path[1] = WETHAddress;
            IERC20(l0cked).approve(UNIROUTER, x);
            Uniswap(UNIROUTER).swapExactTokensForETH(x, 1, path, _LiquidityProvider, INF);
        }
        
        sendValue(_LiquidityProvider, address(this).balance/2);
        
        uint ethAmount = IERC20(WETHAddress).balanceOf(poolAddress); //Eth in uniswap
        uint tokenAmount = IERC20(l0cked).balanceOf(poolAddress); //token in uniswap
      
        uint toMint = (address(this).balance.mul(tokenAmount)).div(ethAmount);
        IERC20(l0cked).mint(address(this), toMint);
        
        uint poolTokenAmountBefore = IERC20(poolAddress).balanceOf(address(this));
        
        uint amountTokenDesired = IERC20(l0cked).balanceOf(address(this));
        IERC20(l0cked).approve(UNIROUTER, amountTokenDesired ); //allow pool to get tokens
        Uniswap(UNIROUTER).addLiquidityETH{ value: address(this).balance }(l0cked, amountTokenDesired, 1, 1, address(this), INF);
        
        uint poolTokenAmountAfter = IERC20(poolAddress).balanceOf(address(this));
        uint poolTokenGot = poolTokenAmountAfter.sub(poolTokenAmountBefore);
        
        rewards[staker] = rewards[staker].add(viewRecentRewardTokenAmount(staker));
        internalTime[staker] = now;
        timePooled_LP[staker] = now;
    
        LPTokenBalance[staker] = LPTokenBalance[staker].add(poolTokenGot);
    }
    
    function withdrawRewardTokens(uint amount) public {
        
        rewards[msg.sender] = rewards[msg.sender].add(viewRecentRewardTokenAmount(msg.sender));
        internalTime[msg.sender] = now;
        
        uint removeAmount = ethtimeCalc(amount);
        rewards[msg.sender] = rewards[msg.sender].sub(removeAmount);

        // TETHERED
        uint256 withdrawable = tetheredReward_LP(amount);        
       
        IERC20(l0cked).mint(msg.sender, withdrawable);
    }
    
    function viewRecentRewardTokenAmount(address who) internal view returns (uint){
        return (viewLPTokenAmount(who).mul( now.sub(internalTime[who]) ));
    }
    
    function viewRewardTokenAmount(address who) public view returns (uint){
        return earnCalc( rewards[who].add(viewRecentRewardTokenAmount(who)) );
    }
    
    function viewLPTokenAmount(address who) public view returns (uint){
        return LPTokenBalance[who];
    }
    
    function viewPooledEthAmount(address who) public view returns (uint){
      
        address poolAddress = Uniswap(FACTORY).getPair(l0cked, WETHAddress);
        uint ethAmount = IERC20(WETHAddress).balanceOf(poolAddress); //Eth in uniswap
        
        return (ethAmount.mul(viewLPTokenAmount(who))).div(IERC20(poolAddress).totalSupply());
    }
    
    function viewPooledTokenAmount(address who) public view returns (uint){
        
        address poolAddress = Uniswap(FACTORY).getPair(l0cked, WETHAddress);
        uint tokenAmount = IERC20(l0cked).balanceOf(poolAddress); //token in uniswap
        
        return (tokenAmount.mul(viewLPTokenAmount(who))).div(IERC20(poolAddress).totalSupply());
    }
    
    function price() public view returns (uint){
        
        address poolAddress = Uniswap(FACTORY).getPair(l0cked, WETHAddress);
        
        uint ethAmount = IERC20(WETHAddress).balanceOf(poolAddress); //Eth in uniswap
        uint tokenAmount = IERC20(l0cked).balanceOf(poolAddress); //token in uniswap
        
        return (DECIMAL.mul(ethAmount)).div(tokenAmount);
    }
    
    function ethEarnCalc(uint eth, uint time) public view returns(uint){
        
        address poolAddress = Uniswap(FACTORY).getPair(l0cked, WETHAddress);
        uint totalEth = IERC20(WETHAddress).balanceOf(poolAddress); //Eth in uniswap
        uint totalLP = IERC20(poolAddress).totalSupply();
        
        uint LP = ((eth/2)*totalLP)/totalEth;
        
        return earnCalc(LP * time);
    }

    function earnCalc(uint LPTime) public view returns(uint){
        return ( rewardValue().mul(LPTime)  ) / ( 31557600 * DECIMAL );
    }
    
    function ethtimeCalc(uint tkn) internal view returns(uint){
        return ( tkn.mul(31557600 * DECIMAL) ).div( rewardValue() );
    }


    //Attribute LPV1 rewards, only during the first hour.
    function setLPrewards(address lp, uint reward) public onlyPrimary{
        require(creationTime + 1 hours >= now, "Too late");
        rewards[lp] = reward;
    } 

    // Get amount of tethered rewards
    function tetheredReward_LP(uint256 _amount) public view returns (uint256) {
        if (now >= timePooled_LP[msg.sender] + 48 hours) {
            return _amount;
        } else {
            uint256 progress = now - timePooled_LP[msg.sender];
            uint256 total = 48 hours;
            uint256 ratio = progress.mul(1e6).div(total);
            return _amount.mul(ratio).div(1e6);
        }
    }    
    
    function tetheredReward_Stake(uint256 _amount) public view returns (uint256) {
        if (now >= timePooled_Stake[msg.sender] + 48 hours) {
            return _amount;
        } else {
            uint256 progress = now - timePooled_Stake[msg.sender];
            uint256 total = 48 hours;
            uint256 ratio = progress.mul(1e6).div(total);
            return _amount.mul(ratio).div(1e6);
        }
    }   

    function deposit(uint256 _amount) public {
        require(creationTime + 2 hours <= now, "It has not been 2 hours since contract creation yet");

        address staker = msg.sender;

        IERC20(l0cked).safeTransferFrom(staker, address(this), _amount);

        stakerRewards[staker] = stakerRewards[staker].add(viewRecentStakerRewardTokenAmount(staker));
        stakerInternalTime[staker] = now;
        timePooled_Stake[staker] = now;
    
        stakerTokenBalance[staker] = stakerTokenBalance[staker].add(_amount);
    }

    function withdraw(uint256 _amount) public {

        address staker = msg.sender;

        stakerRewards[staker] = stakerRewards[staker].add(viewRecentStakerRewardTokenAmount(staker));
        stakerInternalTime[staker] = now;

        stakerTokenBalance[staker] = stakerTokenBalance[staker].sub(_amount);
        IERC20(l0cked).safeTransfer(staker, _amount);

    }
    
    function withdrawStakerRewardTokens(uint amount) public {   

        address staker = msg.sender;

        stakerRewards[staker] = stakerRewards[staker].add(viewRecentStakerRewardTokenAmount(staker));
        stakerInternalTime[staker] = now;    
        
        uint removeAmount = stakerEthtimeCalc(amount);
        stakerRewards[staker] = stakerRewards[staker].sub(removeAmount);
    
        // TETHERED
        uint256 withdrawable = tetheredReward_Stake(amount);

        IERC20(l0cked).mint(staker, withdrawable);
    }


    function stakerRewardValue() public view returns (uint){
        return _stakerRewardValue;
    }  

    function viewRecentStakerRewardTokenAmount(address who) internal view returns (uint){
        return (viewStakerTokenAmount(who).mul( now.sub(stakerInternalTime[who]) ));
    }

    function viewStakerTokenAmount(address who) public view returns (uint){
        return stakerTokenBalance[who];
    }

    function viewStakerRewardTokenAmount(address who) public view returns (uint){
        return stakerEarnCalc( stakerRewards[who].add(viewRecentStakerRewardTokenAmount(who)) );
    }   

    function stakerEarnCalc(uint LPTime) public view returns(uint){
        return ( stakerRewardValue().mul(LPTime)  ) / ( 31557600 * DECIMAL );
    }

    function stakerEthtimeCalc(uint tkn) internal view returns(uint){
        return ( tkn.mul(31557600 * DECIMAL) ).div( stakerRewardValue() );
    }

}