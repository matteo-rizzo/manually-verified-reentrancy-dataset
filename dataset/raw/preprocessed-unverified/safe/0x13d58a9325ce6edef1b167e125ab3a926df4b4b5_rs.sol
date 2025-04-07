/**
 *Submitted for verification at Etherscan.io on 2021-02-02
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;
pragma experimental ABIEncoderV2;





contract PredictionMarket {
    
    AggregatorV3Interface internal priceFeed;
    
    using SafeMath for uint256;

    uint256 public latestConditionIndex;
    address payable public owner;
    
    mapping (uint256 => ConditionInfo) public conditions;
    mapping (uint256 => mapping (address => UserInfo)) public users;
    
    struct ConditionInfo
    {
        address oracle;
        int triggerPrice;
        uint256 settlementTime;
        uint256 totalBelowETHStaked;
        uint256 totalAboveETHStaked;
        address[] aboveParticipants;
        address[] belowParticipants;
        bool isSettled;
        int settledPrice;
    }
    
    struct UserInfo
    {
        uint256 belowETHStaked;
        uint256 aboveETHStaked;
    }
    
    event ConditionPrepared(
        uint256 indexed conditionIndex,
        address indexed oracle,
        uint256 indexed settlementTime,
        int triggerPrice
    );
    
    event UserPrediction(
        uint256 indexed conditionIndex,
        address indexed userAddress,
        uint256 indexed ETHStaked,
        uint8 prediction,
        uint256 timestamp
    );
    
    event UserClaimed(
        uint256 indexed conditionIndex,
        address indexed userAddress,
        uint256 indexed winningAmount
    );
    
    event ConditionSettled(
        uint256 indexed conditionIndex,
        int indexed settledPrice,
        uint256 timestamp
    );
    
    modifier onlyOwner(){
        require(msg.sender == owner,"Not Owner");
        _;
    }
    
    constructor(address payable _owner) public {
        owner = _owner;
    }
    
    function prepareCondition(address _oracle,uint256 _settlementTime, int _triggerPrice) external onlyOwner{
        require(_oracle != address(0),"Can't be 0 address");
        require(_settlementTime > block.timestamp,"Settlement Time should be greater than Trx Confirmed Time");
        latestConditionIndex = latestConditionIndex.add(1);
        ConditionInfo storage conditionInfo = conditions[latestConditionIndex];

        conditionInfo.oracle = _oracle;
        conditionInfo.settlementTime = _settlementTime;
        conditionInfo.triggerPrice = _triggerPrice;
        conditionInfo.isSettled = false;
        
        emit ConditionPrepared(latestConditionIndex, _oracle, _settlementTime, _triggerPrice);
    }
    
    function probabilityRatio(uint256 _conditionIndex) external view returns(uint256 aboveProbability,uint256 belowProbability){
        ConditionInfo storage conditionInfo = conditions[_conditionIndex];
        
        uint256 ethStakedForAbove = conditionInfo.totalAboveETHStaked;
        uint256 ethStakedForBelow = conditionInfo.totalBelowETHStaked;
        
        uint256 totalETHStaked = ethStakedForAbove.add(ethStakedForBelow);
        
        uint256 aboveProbabilityRatio = totalETHStaked > 0 ? ethStakedForAbove.mul(1e18).div(totalETHStaked) : 0;
        uint256 belowProbabilityRatio = totalETHStaked > 0 ? ethStakedForBelow.mul(1e18).div(totalETHStaked) : 0;
                                                    
        return (aboveProbabilityRatio,belowProbabilityRatio);
    }
    
    function userTotalETHStaked(uint256 _conditionIndex,address userAddress) public view returns(uint256){
        UserInfo storage userInfo = users[_conditionIndex][userAddress];
        return userInfo.aboveETHStaked.add(userInfo.belowETHStaked);
    }
    
    function betOnCondition(uint256 _conditionIndex,uint8 _prediction) public payable{
        ConditionInfo storage conditionInfo = conditions[_conditionIndex];
        require(conditionInfo.oracle !=address(0), "Condition doesn't exists");
        require(block.timestamp < conditionInfo.settlementTime,"Cannot bet after Settlement Time");
        uint256 userETHStaked = msg.value;
        require(userETHStaked > 0 wei, "Bet cannot be 0");
        require((_prediction == 0)||(_prediction == 1),"Invalid Prediction");   //prediction = 0 (price will be below), if 1 (price will be above)

        
        address userAddress = msg.sender;
        UserInfo storage userInfo = users[_conditionIndex][userAddress];
        
        if(_prediction == 0) {
            conditionInfo.belowParticipants.push(userAddress);
            conditionInfo.totalBelowETHStaked = conditionInfo.totalBelowETHStaked.add(userETHStaked);
            userInfo.belowETHStaked = userInfo.belowETHStaked.add(userETHStaked);
        }
        else{
            conditionInfo.aboveParticipants.push(userAddress);
            conditionInfo.totalAboveETHStaked = conditionInfo.totalAboveETHStaked.add(userETHStaked);
            userInfo.aboveETHStaked = userInfo.aboveETHStaked.add(userETHStaked);
        }
        emit UserPrediction(_conditionIndex,userAddress,userETHStaked,_prediction,block.timestamp);
    }
    
    function settleCondition(uint256 _conditionIndex) public {
        ConditionInfo storage conditionInfo = conditions[_conditionIndex];
        require(conditionInfo.oracle !=address(0), "Condition doesn't exists");
        require(block.timestamp >= conditionInfo.settlementTime,"Not before Settlement Time");
        require(!conditionInfo.isSettled,"Condition settled already");
        
        conditionInfo.isSettled = true;
        priceFeed = AggregatorV3Interface(conditionInfo.oracle);
        (,int latestPrice,,,) = priceFeed.latestRoundData();
        conditionInfo.settledPrice = latestPrice;
        emit ConditionSettled(_conditionIndex,latestPrice,block.timestamp);
    }
    
    function claim(uint256 _conditionIndex) public{
        ConditionInfo storage conditionInfo = conditions[_conditionIndex];
        address payable userAddress = msg.sender;
        UserInfo storage userInfo = users[_conditionIndex][userAddress];

        require(userTotalETHStaked(_conditionIndex,userAddress) > 0, "Nothing To Claim");
        
        if(!conditionInfo.isSettled){
            settleCondition(_conditionIndex);
        }
        uint256 totalPayout;    //Payout to be distributed among winners(total eth staked by loosing side)
        uint256 winnersTotalETHStaked;   //total eth staked by the winning side
        uint256 userProportion; //User Stake Proportion among the total ETH Staked by winners
        uint256 winnerPayout;
        uint256 winnerRedeemable;   //User can redeem 90% of there total winnerPayout 
        uint256 platformFees;      // remaining 10% will be treated as platformFees  
        uint256 totalWinnerRedeemable; //Amount Redeemable including winnerRedeemable & user initial Stake
        
        if(conditionInfo.settledPrice >= conditionInfo.triggerPrice){    //Users who predicted above price wins 
            totalPayout = conditionInfo.totalBelowETHStaked;
            winnersTotalETHStaked = conditionInfo.totalAboveETHStaked;
            userProportion = userInfo.aboveETHStaked.mul(1e18).div(winnersTotalETHStaked);
            winnerPayout = totalPayout.mul(userProportion).div(1e18);
            winnerRedeemable = (winnerPayout.div(1000)).mul(900);    
            platformFees = (winnerPayout.div(1000)).mul(100);         
            owner.transfer(platformFees);
            totalWinnerRedeemable = winnerRedeemable.add(userInfo.aboveETHStaked);
            userAddress.transfer(totalWinnerRedeemable);
        }
        
        else if(conditionInfo.settledPrice < conditionInfo.triggerPrice){      //Users who predicted below price wins
            totalPayout = conditionInfo.totalAboveETHStaked;
            winnersTotalETHStaked = conditionInfo.totalBelowETHStaked;
            userProportion = userInfo.belowETHStaked.mul(1e18).div(winnersTotalETHStaked);
            winnerPayout = totalPayout.mul(userProportion).div(1e18);
            winnerRedeemable = (winnerPayout.div(1000)).mul(900);     
            platformFees = (winnerPayout.div(1000)).mul(100);        
            owner.transfer(platformFees);
            totalWinnerRedeemable = winnerRedeemable.add(userInfo.belowETHStaked);
            userAddress.transfer(totalWinnerRedeemable);
        }
        emit UserClaimed(_conditionIndex,userAddress,winnerPayout);
    }
}