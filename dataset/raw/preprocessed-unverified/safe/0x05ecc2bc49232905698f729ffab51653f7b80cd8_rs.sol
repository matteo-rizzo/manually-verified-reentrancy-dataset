/**
 *Submitted for verification at Etherscan.io on 2021-05-20
*/

pragma solidity 0.6.12;

    // SPDX-License-Identifier: No License

    /**
    * @title SafeMath
    * @dev Math operations with safety checks that throw on error
    */
    

    /**
    * @dev Library for managing
    * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
    * types.
    *
    * Sets have the following properties:
    *
    * - Elements are added, removed, and checked for existence in constant time
    * (O(1)).
    * - Elements are enumerated in O(n). No guarantees are made on the ordering.
    *
    * ```
    * contract Example {
    *     // Add the library methods
    *     using EnumerableSet for EnumerableSet.AddressSet;
    *
    *     // Declare a set state variable
    *     EnumerableSet.AddressSet private mySet;
    * }
    * ```
    *
    * As of v3.0.0, only sets of type `address` (`AddressSet`) and `uint256`
    * (`UintSet`) are supported.
    */
    
    
    


    

    contract RCHARTpredictionV1 is Ownable {
        using SafeMath for uint;
        using EnumerableSet for EnumerableSet.AddressSet;
        
    
        /*
        participanta[i] = [
            0 => user staked,
            1 => amount staked,
            2 => result time,
            3 => prediction time,
            4 => market pair,
            5 => value predicted at,
            6 => result value,
            7 => prediction type  0 => Down, 1 => up ,
            8 => result , 0 => Pending , 2 => Lost, 1 => Won, 3 => Withdrawn
        ]
        */

        // RCHART token contract address
        address public constant tokenAddress = 0xE63d7A762eF855114dc45c94e66365D163B3E5F6;
        // Lost token contract address
        address public constant lossPool = 0x639d0AFE157Fbb367084fc4b5c887725112148F9; 
        
    
        
        // mapping(address => uint[]) internal participants;
        
        struct Prediction {
            address user;
            uint betAmount;
            uint resultTime;
            uint betTime;
            uint marketPair;
            uint marketType;
            uint valuePredictedAt;
            uint valueResult;
            uint predictionType;
            uint result;       
            bool exists;
        }
        

        mapping(uint => Prediction)  predictions;
        
        mapping (address => uint) public totalEarnedTokens;
        mapping (address => uint) public totalClaimedTokens;
        mapping (address => uint) public totalAvailableRewards;
        mapping (address => uint) public totalPoints;
        mapping (address => uint) public totalStaked;
        event PredictionMade(address indexed user, uint matchid);
        event PointsEarned(address indexed user, uint indexed time ,  uint score);
    
        event RewardsTransferred(address indexed user, uint amount);
        event ResultDeclared(address indexed user, uint matchID);
        
        uint public payoutPercentage = 6500 ;
        uint public expresultime = 24 hours;
        uint public maximumToken = 5e18 ; 
        uint public minimumToken = 1e17 ; 
        uint public totalClaimedRewards = 0;
        
        uint public scorePrdzEq = 50 ;
     
        uint[] public matches;

    
    function getallmatches() view public  returns (uint[] memory){
        return matches;
    }
        
        function predict(uint matchID , uint amountToPredict, uint resultTime, uint predictedtime, uint marketPair, uint valuePredictedAt, uint predictionType,uint marketType) public returns (uint)  {
            require(amountToPredict >= minimumToken && amountToPredict <= maximumToken, "Cannot predict with 0 Tokens");
            require(resultTime > predictedtime, "Cannot predict at the time of result");
            require(Token(tokenAddress).transferFrom(msg.sender, address(this), amountToPredict), "Insufficient Token Allowance");
            
            require(predictions[matchID].exists !=  true  , "Match already Exists" );
            
            

            Prediction storage newprediction = predictions[matchID];
            newprediction.user =  msg.sender;
            newprediction.betAmount =  amountToPredict; 
            newprediction.resultTime =  resultTime ;
            newprediction.betTime =  predictedtime; 
            newprediction.marketPair =  marketPair ;
            newprediction.marketType =  marketType ;
            newprediction.valuePredictedAt =  valuePredictedAt ;
            newprediction.valueResult =  0 ;
            newprediction.predictionType =  predictionType ;
            newprediction.result =  0 ;
            newprediction.exists =  true ;
            matches.push(matchID) ;

            totalPoints[msg.sender] = totalPoints[msg.sender].add(amountToPredict.mul(scorePrdzEq).div(1e18));
            emit PointsEarned(msg.sender, now , amountToPredict.mul(scorePrdzEq).div(1e18));

            totalStaked[msg.sender] =  totalStaked[msg.sender].add(amountToPredict) ;
            emit PredictionMade(msg.sender, matchID);

        }
        
        function declareresult(uint curMarketValue , uint matchID  ) public  onlyOwner returns (bool)   {


                    Prediction storage eachparticipant = predictions[matchID];

                        if(eachparticipant.resultTime <= now && eachparticipant.result == 0 && curMarketValue > 0 ){

                            /* When User Predicted Up && Result is Up */
                                if(eachparticipant.valuePredictedAt  < curMarketValue && eachparticipant.predictionType  == 1  ){
                                    eachparticipant.result  = 1 ;
                                    eachparticipant.valueResult  = curMarketValue ;
                                    uint reward = eachparticipant.betAmount.mul(payoutPercentage).div(1e4);
                                    totalEarnedTokens[eachparticipant.user] = totalEarnedTokens[eachparticipant.user].add(eachparticipant.betAmount).add(reward);
                                    
                                    totalAvailableRewards[eachparticipant.user] = totalAvailableRewards[eachparticipant.user].add(eachparticipant.betAmount).add(reward);
                                }

                            /* When User Predicted Up && Result is Down */
                                if(eachparticipant.valuePredictedAt  > curMarketValue && eachparticipant.predictionType  == 1  ){
                                    eachparticipant.result  = 2 ;
                                    eachparticipant.valueResult  = curMarketValue ;
                                    Token(tokenAddress).transfer(lossPool, eachparticipant.betAmount);

                                }

                            /* When User Predicted Down && Result is Up */
                                if(eachparticipant.valuePredictedAt  < curMarketValue && eachparticipant.predictionType  == 0  ){
                                    eachparticipant.result  = 2 ;
                                    eachparticipant.valueResult  = curMarketValue ;
                                    Token(tokenAddress).transfer(lossPool, eachparticipant.betAmount);

                                }

                            /* When User Predicted Down && Result is Down */
                                if(eachparticipant.valuePredictedAt  > curMarketValue && eachparticipant.predictionType  == 0  ){
                                    eachparticipant.result  = 1 ;
                                    eachparticipant.valueResult  = curMarketValue ;
                                    uint reward = eachparticipant.betAmount.mul(payoutPercentage).div(1e4);
                                    totalEarnedTokens[eachparticipant.user] = totalEarnedTokens[eachparticipant.user].add(eachparticipant.betAmount).add(reward);
                                    totalAvailableRewards[eachparticipant.user] = totalAvailableRewards[eachparticipant.user].add(eachparticipant.betAmount).add(reward);

                                }
                        emit ResultDeclared(msg.sender, matchID);
                    
                }
                
            
                return true ;

            }


            function getmatchBasic(uint  _matchID ) view public returns (address , uint , uint , uint , uint  ) {
                        return (predictions[_matchID].user , predictions[_matchID].betAmount , predictions[_matchID].resultTime , predictions[_matchID].betTime , predictions[_matchID].marketPair  );
            }

            function getmatchAdv(uint  _matchID ) view public returns (uint , uint , uint , uint , uint  , bool  ) {
                        return (predictions[_matchID].marketType , predictions[_matchID].valuePredictedAt, predictions[_matchID].valueResult, predictions[_matchID].predictionType , predictions[_matchID].result  , predictions[_matchID].exists );
            }

            
    

        function withdrawNotExecutedResult(uint  _matchID) 
            public 
            
            returns (bool) {
            
            if(predictions[_matchID].result == 0 && predictions[_matchID].user == msg.sender && now.sub(predictions[_matchID].resultTime) > expresultime){
                Prediction storage eachparticipant = predictions[_matchID];
                eachparticipant.result =  3 ;
                Token(tokenAddress).transfer(predictions[_matchID].user, predictions[_matchID].betAmount);
            }
            
            return true ;
        }

    function addContractBalance(uint amount) public {
            require(Token(tokenAddress).transferFrom(msg.sender, address(this), amount), "Cannot add balance!");
            
        }

         function addScore(uint  score, uint amount, address _holder) 
            public 
            onlyOwner
            returns (bool) {
             totalPoints[_holder] = totalPoints[_holder].add(score);
              totalStaked[_holder] = totalStaked[_holder].add(amount);
            
            return true ;
        }

        function updateMaximum(uint  amount) 
            public 
            onlyOwner
            returns (bool) {
            maximumToken = amount;
            
            return true ;
        }

        function updateMinimum(uint  amount) 
            public 
            onlyOwner
            returns (bool) {
            minimumToken = amount;
            
            return true ;
        }

        

        function updatePayout(uint  percentage) 
            public 
            onlyOwner
            returns (bool) {
            payoutPercentage = percentage;
            
            return true ;
        }

    function updateScoreEq(uint  prdzeq) 
            public 
            onlyOwner
            returns (bool) {
            scorePrdzEq = prdzeq;
            
            return true ;
        }


    
    


        function updateAccount(address account) private {
            uint pendingDivs = totalAvailableRewards[account];
            if (pendingDivs > 0 ) {
                require(Token(tokenAddress).transfer(account, pendingDivs), "Could not transfer tokens.");
                totalClaimedTokens[account] = totalClaimedTokens[account].add(pendingDivs);
                totalAvailableRewards[account] = 0 ;
                totalClaimedRewards = totalClaimedRewards.add(pendingDivs);
                emit RewardsTransferred(account, pendingDivs);
            }
        
            
        }
        
            
        function claimDivs() public {
            updateAccount(msg.sender);
        }
        
        
        
    

    }