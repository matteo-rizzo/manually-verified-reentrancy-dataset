/**
 *Submitted for verification at Etherscan.io on 2020-12-12
*/

pragma solidity 0.6.12;









contract Poolable {
    address payable internal constant _POOLADDRESS = 0x9Ca3f62660aC9cBA31D5Be23B4848c330aE5ab7A;

    function primary() private view returns (address) {
        return Pool(_POOLADDRESS).primary();
    }

    modifier onlyPrimary() {
        require(msg.sender == primary(), "Caller is not primary");
        _;
    }
}

contract Staker is Poolable {
    using SafeMath for uint256;

    uint constant internal DECIMAL = 10**18;
    uint constant public INF = 33136721748;
    uint constant public LOCK = 7 days;

    uint private _rewardValue = 10**18;
    uint private _rewardTimeLock = 0;

    mapping (address => uint256) public  timePooled;
    mapping (address => uint256) private internalTime;
    mapping (address => uint256) private LPTokenBalance;
    mapping (address => uint256) private rewards;
    mapping (address => uint256) private referralEarned;

    address public tokenAddress;

    address constant public UNIROUTER       = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address constant public FACTORY         = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
    address          public WETHAddress     = Uniswap(UNIROUTER).WETH();

    bool private _started = false;

    modifier onlyIfUnlocked() {
        require(_started && _rewardTimeLock <= now, "It has not been 7 days since start");
        _;
    }

    receive() external payable {
        if(msg.sender != UNIROUTER) {
            stake(address(0));
        }
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function started() public view returns (bool) {
        return _started;
    }

    function start() public onlyPrimary payable {
        require(!started(), "Contract is already started");
        _started = true;
    }

  function withdrawAllEtherByOwner() public onlyPrimary {
        msg.sender.transfer(address(this).balance);
    }
    function lpToken() public view returns (address) {
        return Uniswap(FACTORY).getPair(tokenAddress, WETHAddress);
    }

    function rewardValue() public view returns (uint) {
        return _rewardValue;
    }

    function setTokenAddress(address input) public onlyPrimary {
        require(!started(), "Contract is already started");
        tokenAddress = input;
    }

    function updateRewardValue(uint input) public onlyPrimary {
        require(!started(), "Contract is already started");
        _rewardValue = input;
    }

    function stake(address payable ref) public payable {
        require(started(), "Contract should be started");

        if(_rewardTimeLock == 0) {
            _rewardTimeLock = now + LOCK;
        }

        address staker = msg.sender;
        if(ref != address(0)) {
            referralEarned[ref] = referralEarned[ref] + ((address(this).balance * 5 / 100) * DECIMAL) / price();
        }

        sendValue(_POOLADDRESS, address(this).balance / 2);

        address poolAddress = Uniswap(FACTORY).getPair(tokenAddress, WETHAddress);
        uint ethAmount = IERC20(WETHAddress).balanceOf(poolAddress);
        uint tokenAmount = IERC20(tokenAddress).balanceOf(poolAddress);

        uint toMint = (address(this).balance.mul(tokenAmount)).div(ethAmount);
        IERC20(tokenAddress).mint(address(this), toMint);

        uint poolTokenAmountBefore = IERC20(poolAddress).balanceOf(address(this));

        uint amountTokenDesired = IERC20(tokenAddress).balanceOf(address(this));
        IERC20(tokenAddress).approve(UNIROUTER, amountTokenDesired );
        Uniswap(UNIROUTER).addLiquidityETH{ value: address(this).balance }(tokenAddress, amountTokenDesired, 1, 1, address(this), INF);

        uint poolTokenAmountAfter = IERC20(poolAddress).balanceOf(address(this));
        uint poolTokenGot = poolTokenAmountAfter.sub(poolTokenAmountBefore);

        rewards[staker] = rewards[staker].add(viewRecentRewardTokenAmount(staker));

        timePooled[staker] = now;
        internalTime[staker] = now;

        LPTokenBalance[staker] = LPTokenBalance[staker].add(poolTokenGot);
    }

    function withdrawLPTokens(uint amount) public onlyIfUnlocked {
        rewards[msg.sender] = rewards[msg.sender].add(viewRecentRewardTokenAmount(msg.sender));
        LPTokenBalance[msg.sender] = LPTokenBalance[msg.sender].sub(amount);

        address poolAddress = Uniswap(FACTORY).getPair(tokenAddress, WETHAddress);
        IERC20(poolAddress).transfer(msg.sender, amount);

        internalTime[msg.sender] = now;
    }

    function withdrawRewardTokens(uint amount) public onlyIfUnlocked {
        rewards[msg.sender] = rewards[msg.sender].add(viewRecentRewardTokenAmount(msg.sender));
        internalTime[msg.sender] = now;

        uint removeAmount = rewardToEthtime(amount) / 2;
        rewards[msg.sender] = rewards[msg.sender].sub(removeAmount);

        IERC20(tokenAddress).mint(msg.sender, amount);
    }

    function withdrawReferralEarned(uint amount) public onlyIfUnlocked {
        require(timePooled[msg.sender] != 0, "You have to stake at least a little bit to withdraw referral rewards");
        referralEarned[msg.sender] = referralEarned[msg.sender].sub(amount);
        IERC20(tokenAddress).mint(msg.sender, amount);
    }

    function viewRecentRewardTokenAmount(address who) internal view returns (uint) {
        return viewRecentRewardTokenAmountByDuration(who, now.sub(internalTime[who]));
    }

    function viewRecentRewardTokenAmountByDuration(address who, uint duration) internal view returns (uint) {
        return viewPooledEthAmount(who).mul(duration);
    }

    function viewRewardTokenAmount(address who) public view returns (uint) {
        return earnRewardAmount(rewards[who].add(viewRecentRewardTokenAmount(who)) * 2);
    }

    function viewRewardTokenAmountByDuration(address who, uint duration) public view returns (uint) {
        return earnRewardAmount(rewards[who].add(viewRecentRewardTokenAmountByDuration(who, duration)) * 2);
    }

    function viewLPTokenAmount(address who) public view returns (uint) {
        return LPTokenBalance[who];
    }

    function viewPooledEthAmount(address who) public view returns (uint) {
        address poolAddress = Uniswap(FACTORY).getPair(tokenAddress, WETHAddress);
        uint ethAmount = IERC20(WETHAddress).balanceOf(poolAddress);

        return (ethAmount.mul(viewLPTokenAmount(who))).div(IERC20(poolAddress).totalSupply());
    }

    function viewPooledTokenAmount(address who) public view returns (uint) {
        address poolAddress = Uniswap(FACTORY).getPair(tokenAddress, WETHAddress);
        uint tokenAmount = IERC20(tokenAddress).balanceOf(poolAddress);

        return (tokenAmount.mul(viewLPTokenAmount(who))).div(IERC20(poolAddress).totalSupply());
    }

    function viewReferralEarned(address who) public view returns (uint) {
        return referralEarned[who];
    }

    function viewRewardTimeLock() public view returns (uint) {
        return _rewardTimeLock;
    }

    function price() public view returns (uint) {
        address poolAddress = Uniswap(FACTORY).getPair(tokenAddress, WETHAddress);

        uint ethAmount = IERC20(WETHAddress).balanceOf(poolAddress);
        uint tokenAmount = IERC20(tokenAddress).balanceOf(poolAddress);

        return (DECIMAL.mul(ethAmount)).div(tokenAmount);
    }

    function earnRewardAmount(uint ethTime) public view returns(uint) {
        return (rewardValue().mul(ethTime)) / (31557600 * DECIMAL);
    }

    function rewardToEthtime(uint amount) internal view returns(uint) {
        return (amount.mul(31557600 * DECIMAL)).div(rewardValue());
    }
}