pragma solidity ^0.4.20;











/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */



















/*

file:   LibCLL.sol

ver:    0.4.0

updated:31-Mar-2016

author: Darryl Morris

email:  o0ragman0o AT gmail.com



A Solidity library for implementing a data indexing regime using

a circular linked list.



This library provisions lookup, navigation and key/index storage

functionality which can be used in conjunction with an array or mapping.



NOTICE: This library uses internal functions only and so cannot be compiled

and deployed independently from its calling contract.



This software is distributed in the hope that it will be useful,

but WITHOUT ANY WARRANTY; without even the implied warranty of

MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  

See MIT Licence for further details.

<https://opensource.org/licenses/MIT>.

*/



// LibCLL using `uint` keys





// LibCLL using `int` keys





// LibCLL using `address` keys



















contract AquaToken is Owned, Token {

    

    //imports

    using SafeMath for uint256;

    using LibHoldings for LibHoldings.Holding;

    using LibHoldings for LibHoldings.HoldingsSet;

    using LibRedemptions for LibRedemptions.Redemption;

    using LibRedemptions for LibRedemptions.RedemptionsQueue;



    //inner types

    struct DistributionContext {

        uint distributionAmount;

        uint receivedRedemptionAmount;

        uint redemptionAmount;

        uint tokenPriceWei;

        uint currentRedemptionId;



        uint totalRewardAmount;

    }

    



    struct WindUpContext {

        uint totalWindUpAmount;

        uint tokenReward;

        uint paidReward;

        address currenHolderAddress;

    }

    

    //constants

    bool constant PREV = false;

    bool constant NEXT = true;



    //state    

    enum TokenStatus {

        OnSale,

        Trading,

        Distributing,

        WindingUp

    }

    ///Status of the token contract

    TokenStatus public tokenStatus;

    

    ///Aqua Price Oracle smart contract

    AquaPriceOracle public priceOracle;

    LibHoldings.HoldingsSet internal holdings;

    uint256 internal totalSupplyOfTokens;

    LibRedemptions.RedemptionsQueue redemptionsQueue;

    

    ///The whole percentage number (0-100) of the total distributable profit 

    ///amount available for token redemption in each profit distribution round

    uint8 public redemptionPercentageOfDistribution;

    mapping (address => mapping (address => uint256)) internal allowances;



    uint [] internal rewards;



    DistributionContext internal distCtx;

    WindUpContext internal windUpCtx;

    



    //ERC-20

    ///Triggered when tokens are transferred.

    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    ///Triggered whenever approve(address _spender, uint256 _value) is called.

    event Approval(address indexed _owner, address indexed _spender, uint256 _value);    



    ///Token name

    string public name;

    ///Token symbol

    string public symbol;

    ///Number of decimals

    uint8 public decimals;

    

    ///Returns total supply of Aqua Tokens 

    function totalSupply() constant external returns (uint256) {

        return totalSupplyOfTokens;

    }



    /// Get the token balance for address _owner

    function balanceOf(address _owner) public constant returns (uint256 balance) {

        if (!holdings.exists(_owner))

            return 0;

        LibHoldings.Holding storage h = holdings.get(_owner);

        return h.totalTokens.sub(h.lockedTokens);

    }

    ///Transfer the balance from owner's account to another account

    function transfer(address _to, uint256 _value) external returns (bool success) {

        return _transfer(msg.sender, _to, _value);

    }



    /// Send _value amount of tokens from address _from to address _to

    /// The transferFrom method is used for a withdraw workflow, allowing contracts to send

    /// tokens on your behalf, for example to "deposit" to a contract address and/or to charge

    /// fees in sub-currencies; the command should fail unless the _from account has

    /// deliberately authorized the sender of the message via some mechanism; 

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {

        require(_value <= allowances[_from][msg.sender]);     // Check allowance

        allowances[_from][msg.sender] = allowances[_from][msg.sender].sub( _value);

        return _transfer(_from, _to, _value);

    }

    

    /// Allow _spender to withdraw from your account, multiple times, up to the _value amount.

    /// If this function is called again it overwrites the current allowance with _value.    

    function approve(address _spender, uint256 _value) public returns (bool success) {

        if (tokenStatus == TokenStatus.OnSale) {

            require(msg.sender == owner);

        }

        allowances[msg.sender][_spender] = _value;

        Approval(msg.sender, _spender, _value);

        return true;

    }

    

    

    /// Returns the amount that _spender is allowed to withdraw from _owner account.

    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {

        return allowances[_owner][_spender];

    }

    

    

    //custom public interface

    

    ///Event is fired when holder requests to redeem their tokens

    ///@param holder Account address of token holder requesting redemption

    ///@param _numberOfTokens Number of tokens requested

    ///@param _requestId ID assigned to the redemption request

    event RequestRedemption(address holder, uint256 _numberOfTokens, uint _requestId);

    

    ///Event is fired when holder cancels redemption request with ID = _requestId

    ///@param holder Account address of token holder cancelling redemption request

    ///@param _numberOfTokens Number of tokens affected

    ///@param _requestId ID of the redemption request that was cancelled

    event CancelRedemptionRequest(address holder, uint256 _numberOfTokens, uint256 _requestId);

    

    ///Event occurs when the redemption request is redeemed. 

    ///@param holder Account address of the token holder whose tokens were redeemed

    ///@param _requestId The ID of the redemption request

    ///@param _numberOfTokens The number of tokens redeemed

    ///@param amount The redeemed amount in Wei

    event HolderRedemption(address holder, uint _requestId, uint256 _numberOfTokens, uint amount);



    ///Event occurs when profit distribution is triggered

    ///@param amount Total amount (in Wei) available for this profit distribution round

    event DistributionStarted(uint amount);

    ///Event occurs when profit distribution round completes

    ///@param redeemedAmount Total amount (in wei) redeemed in this distribution round

    ///@param rewardedAmount Total amount rewarded as dividends in this distribution round

    ///@param remainingAmount Any minor remaining amount (due to rounding errors) that has been distributed back to iAqua

    event DistributionCompleted(uint redeemedAmount, uint rewardedAmount, uint remainingAmount);

    ///Event is triggered when token holder withdraws their balance

    ///@param holderAddress Address of the token holder account

    ///@param amount Amount in wei that has been withdrawn

    ///@param hasRemainingBalance True if there is still remaining balance

    event WithdrawBalance(address holderAddress, uint amount, bool hasRemainingBalance);

    

    ///Occurs when contract owner (iAqua) repeatedly calls continueDistribution to progress redemption and 

    ///dividend payments during profit distribution round

    ///@param _continue True if the distribution hasn¡¯t completed as yet

    event ContinueDistribution(bool _continue);



    ///The event is fired when wind-up procedure starts

    ///@param amount Total amount in Wei available for final distribution among token holders

    event WindingUpStarted(uint amount);

    

    ///Event is triggered when smart contract transitions into Trading state when trading and token transfers is allowed

    event StartTrading();

    

    ///Event is triggered when a token holders destroys their tokens

    ///@param from Account address of the token holder

    ///@param numberOfTokens Number of tokens burned (permanently destroyed)

    event Burn(address indexed from, uint256 numberOfTokens);



    /// Constructor initializes the contract

    ///@param initialSupply Initial supply of tokens

    ///@param tokenName Display name if the token

    ///@param tokenSymbol Token symbol

    ///@param decimalUnits Number of decimal points for token holding display

    ///@param _redemptionPercentageOfDistribution The whole percentage number (0-100) of the total distributable profit amount available for token redemption in each profit distribution round 

    function AquaToken(uint256 initialSupply, 

            string tokenName, 

            string tokenSymbol, 

            uint8 decimalUnits,

            uint8 _redemptionPercentageOfDistribution,

            address _priceOracle

    ) public

    {

        totalSupplyOfTokens = initialSupply;

        holdings.add(msg.sender, LibHoldings.Holding({

            totalTokens : initialSupply, 

            lockedTokens : 0,

            lastRewardNumber : 0,

            weiBalance : 0 

        }));



        name = tokenName;                         // Set the name for display purposes

        symbol = tokenSymbol;                     // Set the symbol for display purposes

        decimals = decimalUnits;                  // Amount of decimals for display purposes

    

        redemptionPercentageOfDistribution = _redemptionPercentageOfDistribution;

    

        priceOracle = AquaPriceOracle(_priceOracle);

        owner = msg.sender;

        

        tokenStatus = TokenStatus.OnSale;

        rewards.push(0);

    }

    

    ///Called by token owner enable trading with tokens

    function startTrading() onlyOwner external {

        require(tokenStatus == TokenStatus.OnSale);

        tokenStatus = TokenStatus.Trading;

        StartTrading();

    }

    

    ///Token holders can call this function to request to redeem (sell back to 

    ///the company) part or all of their tokens

    ///@param _numberOfTokens Number of tokens to redeem

    ///@return Redemption request ID (required in order to cancel this redemption request)

    function requestRedemption(uint256 _numberOfTokens) public returns (uint) {

        require(tokenStatus == TokenStatus.Trading && _numberOfTokens > 0);

        LibHoldings.Holding storage h = holdings.get(msg.sender);

        require(h.totalTokens.sub( h.lockedTokens) >= _numberOfTokens);                 // Check if the sender has enough



        uint redemptionId = redemptionsQueue.add(msg.sender, _numberOfTokens);



        h.lockedTokens = h.lockedTokens.add(_numberOfTokens);

        RequestRedemption(msg.sender, _numberOfTokens, redemptionId);

        return redemptionId;

    }

    

    ///Token holders can call this function to cancel a redemption request they 

    ///previously submitted using requestRedemption function

    ///@param _requestId Redemption request ID

    function cancelRedemptionRequest(uint256 _requestId) public {

        require(tokenStatus == TokenStatus.Trading && redemptionsQueue.exists(_requestId));

        LibRedemptions.Redemption storage r = redemptionsQueue.get(_requestId); 

        require(r.holderAddress == msg.sender);



        LibHoldings.Holding storage h = holdings.get(msg.sender); 

        h.lockedTokens = h.lockedTokens.sub(r.numberOfTokens);

        uint numberOfTokens = r.numberOfTokens;

        redemptionsQueue.remove(_requestId);



        CancelRedemptionRequest(msg.sender, numberOfTokens,  _requestId);

    }

    

    ///The function is used to enumerate redemption requests. It returns the first redemption request ID.

    ///@return First redemption request ID

    function firstRedemptionRequest() public constant returns (uint) {

        return redemptionsQueue.firstRedemption();

    }

    

    ///The function is used to enumerate redemption requests. It returns the 

    ///next redemption request ID following the supplied one.

    ///@param _currentRedemptionId Current redemption request ID

    ///@return Next redemption request ID

    function nextRedemptionRequest(uint _currentRedemptionId) public constant returns (uint) {

        return redemptionsQueue.nextRedemption(_currentRedemptionId);

    }

    

    ///The function returns redemption request details for the supplied redemption request ID

    ///@param _requestId Redemption request ID

    ///@return _holderAddress Token holder account address

    ///@return _numberOfTokens Number of tokens requested to redeem

    function getRedemptionRequest(uint _requestId) public constant returns 

                (address _holderAddress, uint256 _numberOfTokens) {

        LibRedemptions.Redemption storage r = redemptionsQueue.get(_requestId);

        _holderAddress = r.holderAddress;

        _numberOfTokens = r.numberOfTokens;

    }

    

    ///The function is used to enumerate token holders. It returns the first 

    ///token holder (that the enumeration starts from)

    ///@return Account address of the first token holder

    function firstHolder() public constant returns (address) {

        return holdings.firstHolder();

    }    

    

    ///The function is used to enumerate token holders. It returns the address 

    ///of the next token holder given the token holder address.

    ///@param _currentHolder Account address of the token holder

    ///@return Account address of the next token holder

    function nextHolder(address _currentHolder) public constant returns (address) {

        return holdings.nextHolder(_currentHolder);

    }

    

    ///The function returns token holder details given token holder account address

    ///@param _holder Account address of a token holder

    ///@return totalTokens Total tokens held by this token holder

    ///@return lockedTokens The number of tokens (out of the total held but this token holder) that are locked and await redemption to be processed

    ///@return weiBalance Wei balance of the token holder available for withdrawal.

    function getHolding(address _holder) public constant 

            returns (uint totalTokens, uint lockedTokens, uint weiBalance) {

        if (!holdings.exists(_holder)) {

            totalTokens = 0;

            lockedTokens = 0;

            weiBalance = 0;

            return;

        }

        LibHoldings.Holding storage h = holdings.get(_holder);

        totalTokens = h.totalTokens;

        lockedTokens = h.lockedTokens;

        uint stepsMade;

        (weiBalance, stepsMade) = calcFullWeiBalance(h, 0);

        return;

    }

    

    ///Token owner calls this function to start profit distribution round

    function startDistribuion() onlyOwner public payable {

        require(tokenStatus == TokenStatus.Trading);

        tokenStatus = TokenStatus.Distributing;

        startRedemption(msg.value);

        DistributionStarted(msg.value);

    } 

    

    ///Token owner calls this function to progress profit distribution round

    ///@param maxNumbeOfSteps Maximum number of steps in this progression

    ///@return False in case profit distribution round has completed

    function continueDistribution(uint maxNumbeOfSteps) public returns (bool) {

        require(tokenStatus == TokenStatus.Distributing);

        if (continueRedeeming(maxNumbeOfSteps)) {

            ContinueDistribution(true);

            return true;

        }

        uint tokenReward = distCtx.totalRewardAmount.div( totalSupplyOfTokens );

        rewards.push(tokenReward);

        uint paidReward = tokenReward.mul(totalSupplyOfTokens);





        uint unusedDistributionAmount = distCtx.totalRewardAmount.sub(paidReward);

        if (unusedDistributionAmount > 0) {

            if (!holdings.exists(owner)) { 

                holdings.add(owner, LibHoldings.Holding({

                    totalTokens : 0, 

                    lockedTokens : 0,

                    lastRewardNumber : rewards.length.sub(1),

                    weiBalance : unusedDistributionAmount 

                }));

            }

            else {

                LibHoldings.Holding storage ownerHolding = holdings.get(owner);

                ownerHolding.weiBalance = ownerHolding.weiBalance.add(unusedDistributionAmount);

            }

        }

        tokenStatus = TokenStatus.Trading;

        DistributionCompleted(distCtx.receivedRedemptionAmount.sub(distCtx.redemptionAmount), 

                            paidReward, unusedDistributionAmount);

        ContinueDistribution(false);

        return false;

    }



    ///Token holder can call this function to withdraw their balance (dividend 

    ///and redemption payments) while limiting the number of operations (in the

    ///extremely unlikely case  when withdrawBalance function exceeds gas limit)

    ///@param maxSteps Maximum number of steps to take while withdrawing holder balance

    function withdrawBalanceMaxSteps(uint maxSteps) public {

        require(holdings.exists(msg.sender));

        LibHoldings.Holding storage h = holdings.get(msg.sender); 

        uint updatedBalance;

        uint stepsMade;

        (updatedBalance, stepsMade) = calcFullWeiBalance(h, maxSteps);

        h.weiBalance = 0;

        h.lastRewardNumber = h.lastRewardNumber.add(stepsMade);

        

        bool balanceRemainig = h.lastRewardNumber < rewards.length.sub(1);

        if (h.totalTokens == 0 && h.weiBalance == 0) 

            holdings.remove(msg.sender);



        msg.sender.transfer(updatedBalance);

        

        WithdrawBalance(msg.sender, updatedBalance, balanceRemainig);

    }



    ///Token holder can call this function to withdraw their balance (dividend 

    ///and redemption payments) 

    function withdrawBalance() public {

        withdrawBalanceMaxSteps(0);

    }



    ///Set allowance for other address and notify

    ///Allows _spender to spend no more than _value tokens on your behalf, and then ping the contract about it

    ///@param _spender The address authorized to spend

    ///@param _value the max amount they can spend

    ///@param _extraData some extra information to send to the approved contract

    function approveAndCall(address _spender, uint256 _value, bytes _extraData) public returns (bool success) {

        TokenRecipient spender = TokenRecipient(_spender);

        if (approve(_spender, _value)) {

            spender.receiveApproval(msg.sender, _value, this, _extraData);

            return true;

        }

    }



    ///Token holders can call this method to permanently destroy their tokens.

    ///WARNING: Burned tokens cannot be recovered!

    ///@param numberOfTokens Number of tokens to burn (permanently destroy)

    ///@return True if operation succeeds 

    function burn(uint256 numberOfTokens) external returns (bool success) {

        require(holdings.exists(msg.sender));

        if (numberOfTokens == 0) {

            Burn(msg.sender, numberOfTokens);

            return true;

        }

        LibHoldings.Holding storage fromHolding = holdings.get(msg.sender);

        require(fromHolding.totalTokens.sub(fromHolding.lockedTokens) >= numberOfTokens);                 // Check if the sender has enough



        updateWeiBalance(fromHolding, 0);    

        fromHolding.totalTokens = fromHolding.totalTokens.sub(numberOfTokens);                         // Subtract from the sender

        if (fromHolding.totalTokens == 0 && fromHolding.weiBalance == 0) 

            holdings.remove(msg.sender);

        totalSupplyOfTokens = totalSupplyOfTokens.sub(numberOfTokens);



        Burn(msg.sender, numberOfTokens);

        return true;

    }



    ///Token owner to call this to initiate final distribution in case of project wind-up

    function windUp() onlyOwner public payable {

        require(tokenStatus == TokenStatus.Trading);

        tokenStatus = TokenStatus.WindingUp;

        uint totalWindUpAmount = msg.value;

    

        uint tokenReward = msg.value.div(totalSupplyOfTokens);

        rewards.push(tokenReward);

        uint paidReward = tokenReward.mul(totalSupplyOfTokens);



        uint unusedWindUpAmount = totalWindUpAmount.sub(paidReward);

        if (unusedWindUpAmount > 0) {

            if (!holdings.exists(owner)) { 

                holdings.add(owner, LibHoldings.Holding({

                    totalTokens : 0, 

                    lockedTokens : 0,

                    lastRewardNumber : rewards.length.sub(1),

                    weiBalance : unusedWindUpAmount 

                }));

            }

            else {

                LibHoldings.Holding storage ownerHolding = holdings.get(owner);

                ownerHolding.weiBalance = ownerHolding.weiBalance.add(unusedWindUpAmount);

            }

        }

        WindingUpStarted(msg.value);

    }

    //internal functions

    function calcFullWeiBalance(LibHoldings.Holding storage holding, uint maxSteps) internal constant 

                    returns(uint updatedBalance, uint stepsMade) {

        uint fromRewardIdx = holding.lastRewardNumber.add(1);

        updatedBalance = holding.weiBalance;

        if (fromRewardIdx == rewards.length) {

            stepsMade = 0;

            return;

        }



        uint toRewardIdx;

        if (maxSteps == 0) {

            toRewardIdx = rewards.length.sub( 1);

        }

        else {

            toRewardIdx = fromRewardIdx.add( maxSteps ).sub(1);

            if (toRewardIdx > rewards.length.sub(1)) {

                toRewardIdx = rewards.length.sub(1);

            }

        }

        for(uint idx = fromRewardIdx; 

                    idx <= toRewardIdx; 

                    idx = idx.add(1)) {

            updatedBalance = updatedBalance.add( 

                rewards[idx].mul( holding.totalTokens ) 

                );

        }

        stepsMade = toRewardIdx.sub( fromRewardIdx ).add( 1 );

        return;

    }

    

    function updateWeiBalance(LibHoldings.Holding storage holding, uint maxSteps) internal 

                returns(uint updatedBalance, uint stepsMade) {

        (updatedBalance, stepsMade) = calcFullWeiBalance(holding, maxSteps);

        if (stepsMade == 0)

            return;

        holding.weiBalance = updatedBalance;

        holding.lastRewardNumber = holding.lastRewardNumber.add(stepsMade);

    }

    



    function startRedemption(uint distributionAmount) internal {

        distCtx.distributionAmount = distributionAmount;

        distCtx.receivedRedemptionAmount = 

            (distCtx.distributionAmount.mul(redemptionPercentageOfDistribution)).div(100);

        distCtx.redemptionAmount = distCtx.receivedRedemptionAmount;

        distCtx.tokenPriceWei = priceOracle.getAquaTokenAudCentsPrice().mul(priceOracle.getAudCentWeiPrice());



        distCtx.currentRedemptionId = redemptionsQueue.firstRedemption();

    }

    

    function continueRedeeming(uint maxNumbeOfSteps) internal returns (bool) {

        uint remainingNoSteps = maxNumbeOfSteps;

        uint currentId = distCtx.currentRedemptionId;

        uint redemptionAmount = distCtx.redemptionAmount;

        uint totalRedeemedTokens = 0;

        while(currentId != 0 && redemptionAmount > 0) {

            if (remainingNoSteps == 0) { 

                distCtx.currentRedemptionId = currentId;

                distCtx.redemptionAmount = redemptionAmount;

                if (totalRedeemedTokens > 0) {

                    totalSupplyOfTokens = totalSupplyOfTokens.sub( totalRedeemedTokens );

                }

                return true;

            }

            if (redemptionAmount.div(distCtx.tokenPriceWei) < 1)

                break;



            LibRedemptions.Redemption storage r = redemptionsQueue.get(currentId);

            LibHoldings.Holding storage holding = holdings.get(r.holderAddress);

            uint updatedBalance;

            uint stepsMade;

            (updatedBalance, stepsMade) = updateWeiBalance(holding, remainingNoSteps);

            remainingNoSteps = remainingNoSteps.sub(stepsMade);          

            if (remainingNoSteps == 0) { 

                distCtx.currentRedemptionId = currentId;

                distCtx.redemptionAmount = redemptionAmount;

                if (totalRedeemedTokens > 0) {

                    totalSupplyOfTokens = totalSupplyOfTokens.sub(totalRedeemedTokens);

                }

                return true;

            }



            uint holderTokensToRedeem = redemptionAmount.div(distCtx.tokenPriceWei);

            if (holderTokensToRedeem > r.numberOfTokens)

                holderTokensToRedeem = r.numberOfTokens;



            uint holderRedemption = holderTokensToRedeem.mul(distCtx.tokenPriceWei);

            holding.weiBalance = holding.weiBalance.add( holderRedemption );



            redemptionAmount = redemptionAmount.sub( holderRedemption );

            

            r.numberOfTokens = r.numberOfTokens.sub( holderTokensToRedeem );

            holding.totalTokens = holding.totalTokens.sub(holderTokensToRedeem);

            holding.lockedTokens = holding.lockedTokens.sub(holderTokensToRedeem);

            totalRedeemedTokens = totalRedeemedTokens.add( holderTokensToRedeem );



            uint nextId = redemptionsQueue.nextRedemption(currentId);

            HolderRedemption(r.holderAddress, currentId, holderTokensToRedeem, holderRedemption);

            if (r.numberOfTokens == 0) 

                redemptionsQueue.remove(currentId);

            currentId = nextId;

            remainingNoSteps = remainingNoSteps.sub(1);

        }

        distCtx.currentRedemptionId = currentId;

        distCtx.redemptionAmount = redemptionAmount;

        totalSupplyOfTokens = totalSupplyOfTokens.sub(totalRedeemedTokens);

        distCtx.totalRewardAmount = 

            distCtx.distributionAmount.sub(distCtx.receivedRedemptionAmount).add(distCtx.redemptionAmount);

        return false;

    }





    function _transfer(address _from, address _to, uint _value) internal returns (bool success) {

        require(_to != 0x0);                                // Prevent transfer to 0x0 address. Use burn() instead

        if (tokenStatus == TokenStatus.OnSale) {

            require(_from == owner);

        }

        if (_value == 0) {

            Transfer(_from, _to, _value);

            return true;

        }

        require(holdings.exists(_from));

        

        LibHoldings.Holding storage fromHolding = holdings.get(_from);

        require(fromHolding.totalTokens.sub(fromHolding.lockedTokens) >= _value);                 // Check if the sender has enough

        

        if (!holdings.exists(_to)) { 

            holdings.add(_to, LibHoldings.Holding({

                totalTokens : _value, 

                lockedTokens : 0,

                lastRewardNumber : rewards.length.sub(1),

                weiBalance : 0 

            }));

        }

        else {

            LibHoldings.Holding storage toHolding = holdings.get(_to);

            require(toHolding.totalTokens.add(_value) >= toHolding.totalTokens);  // Check for overflows

            

            updateWeiBalance(toHolding, 0);    

            toHolding.totalTokens = toHolding.totalTokens.add(_value);                           

        }



        updateWeiBalance(fromHolding, 0);    

        fromHolding.totalTokens = fromHolding.totalTokens.sub(_value);                         // Subtract from the sender

        if (fromHolding.totalTokens == 0 && fromHolding.weiBalance == 0) 

            holdings.remove(_from);

        Transfer(_from, _to, _value);

        return true;

    }

    

}