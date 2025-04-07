/**

 *Submitted for verification at Etherscan.io on 2018-11-01

*/



pragma solidity 0.4.25;





/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */











contract ERC20 {

    function allowance(address owner, address spender) public view returns (uint256);

    function transferFrom(address from, address to, uint256 value) public returns (bool);

    function totalSupply() public view returns (uint256);

    function balanceOf(address who) public view returns (uint256);

    function transfer(address to, uint256 value) public returns (bool);

    function ownerTransfer(address to, uint256 value) public returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);



    function approve(address spender, uint256 value) public returns (bool);

    event Approval(address indexed owner, address indexed spender, uint256 value);



}













/**

 * @title Crowdsale

 * @dev Crowdsale is a base contract for managing a token crowdsale,

 * allowing investors to purchase tokens with ether. This contract implements

 * such functionality in its most fundamental form and can be extended to provide additional

 * functionality and/or custom behavior.

 * The external interface represents the basic interface for purchasing tokens, and conform

 * the base architecture for crowdsales. They are *not* intended to be modified / overriden.

 * The internal interface conforms the extensible and modifiable surface of crowdsales. Override

 * the methods to add functionality. Consider using 'super' where appropiate to concatenate

 * behavior.

 */

contract Crowdsale is Ownable {

    using SafeMath for uint256;

    using SafeERC20 for ERC20;



    // The token being sold

    ERC20 public token;

    address public wallet;



    uint256 public openingTime;



    uint256 public cap;                 //§Ü§Ñ§á §Ó §ä§à§Ü§Ö§ß§Ñ§ç

    uint256 public tokensSold;          //§Ü§à§Ý-§Ó§à §á§â§à§Õ§Ñ§ß§ß§í§ç §ä§à§Ü§Ö§ß§à§Ó

    uint256 public tokenPriceInWei;     //§è§Ö§ß§Ñ §ä§à§Ü§Ö§ß§Ñ §Ó §Ó§Ö§ñ§ç



    bool public isFinalized = false;



    // Amount of wei raised

    uint256 public weiRaised;





    struct Stage {

        uint stopDay;       //§Õ§Ö§ß§î §à§Ü§à§ß§é§Ñ§ß§Ú§ñ §ï§ä§Ñ§á§Ñ

        uint bonus;         //§Ò§à§ß§å§ã §Ó §á§â§à§è§Ö§ß§ä§Ñ§ç

        uint tokens;        //§Ü§à§Ý-§Ó§à §ä§à§Ü§Ö§ß§à§Ó §Õ§Ý§ñ §á§â§à§Õ§Ñ§Ø§Ú (§Ò§Ö§Ù 18 §ß§å§Ý§Ö§Û, §ß§å§Ý§Ú §Õ§à§Ò§Ñ§Ó§Ý§ñ§Ö§Þ §á§Ö§â§Ö§Õ §à§ä§á§â§Ñ§Ó§Ü§à§Û §Ú §Ò§Ö§Ù §å§é§Ö§ä§Ñ §Ò§à§ß§å§ã§ß§í§ç §ä§à§Ü§Ö§ß§à§Ó).

        uint minPurchase;   //§Þ§Ú§ß§Ú§Þ§Ñ§Ý§î§ß§Ñ§ñ §ã§å§Þ§Þ§Ñ §á§à§Ü§å§á§Ü§Ú

    }



    mapping (uint => Stage) public stages;

    uint public stageCount;

    uint public currentStage;



    mapping (address => uint) public refs;

    uint public buyerRefPercent = 500;

    uint public referrerPercent = 500;

    uint public minWithdrawValue = 200000000000000000;

    uint public globalMinWithdrawValue = 1000 ether;



    event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 tokens, uint256 bonus);

    event Finalized();





    /**

     * @dev Reverts if not in crowdsale time range.

     */

    modifier onlyWhileOpen {

        // solium-disable-next-line security/no-block-members

        require(block.timestamp >= openingTime);

        _;

    }





    constructor(address _wallet, ERC20 _token) public {

        require(_wallet != address(0));

        require(_token != address(0));



        wallet = _wallet;

        token = _token;



        cap = 32500000;

        openingTime = now;

        tokenPriceInWei = 1000000000000000;



        currentStage = 1;



        addStage(openingTime + 61    days, 10000, 2500000,  200000000000000000);

        addStage(openingTime + 122   days, 5000,  5000000,  200000000000000000);

        addStage(openingTime + 183   days, 1000,  10000000, 1000000000000000);

        //addStage(openingTime + 1000  days, 0,     9000000000000000000000000,  1000000000000000);

    }



    // -----------------------------------------

    // Crowdsale external interface

    // -----------------------------------------



    /**

     * @dev fallback function ***DO NOT OVERRIDE***

     */

    function () external payable {

        buyTokens(address(0));

    }



    function setTokenPrice(uint _price) onlyOwner public {

        tokenPriceInWei = _price;

    }



    function addStage(uint _stopDay, uint _bonus, uint _tokens, uint _minPurchase) onlyOwner public {

        require(_stopDay > stages[stageCount].stopDay);

        stageCount++;

        stages[stageCount].stopDay = _stopDay;

        stages[stageCount].bonus = _bonus;

        stages[stageCount].tokens = _tokens;

        stages[stageCount].minPurchase = _minPurchase;

    }



    function editStage(uint _stage, uint _stopDay, uint _bonus,  uint _tokens, uint _minPurchase) onlyOwner public {

        stages[_stage].stopDay = _stopDay;

        stages[_stage].bonus = _bonus;

        stages[_stage].tokens = _tokens;

        stages[_stage].minPurchase = _minPurchase;

    }





    function buyTokens(address _ref) public payable {



        uint256 weiAmount = msg.value;



        if (stages[currentStage].stopDay <= now && currentStage < stageCount) {

            _updateCurrentStage();

        }



        _preValidatePurchase(msg.sender, weiAmount);



        uint tokens = 0;

        uint bonusTokens = 0;

        uint totalTokens = 0;

        uint diff = 0;



        (tokens, bonusTokens, totalTokens, diff) = _getTokenAmount(weiAmount);



        _validatePurchase(tokens);



        weiAmount = weiAmount.sub(diff);



        if (_ref != address(0) && _ref != msg.sender) {

            uint refBonus = valueFromPercent(weiAmount, referrerPercent);

            uint buyerBonus = valueFromPercent(weiAmount, buyerRefPercent);



            refs[_ref] = refs[_ref].add(refBonus);

            diff = diff.add(buyerBonus);



            weiAmount = weiAmount.sub(buyerBonus).sub(refBonus);

        }



        if (diff > 0) {

            msg.sender.transfer(diff);

        }



        _processPurchase(msg.sender, totalTokens);

        emit TokenPurchase(msg.sender, msg.sender, msg.value, tokens, bonusTokens);



        _updateState(weiAmount, totalTokens);



        _forwardFunds(weiAmount);

    }



    // -----------------------------------------

    // Internal interface (extensible)

    // -----------------------------------------



    /**

     * @dev Validation of an incoming purchase. Use require statements to revert state when conditions are not met. Use super to concatenate validations.

     * @param _beneficiary Address performing the token purchase

     * @param _weiAmount Value in wei involved in the purchase

     */

    function _preValidatePurchase(address _beneficiary, uint256 _weiAmount) onlyWhileOpen internal view{

        require(_beneficiary != address(0));

        require(_weiAmount >= stages[currentStage].minPurchase);

        require(tokensSold < cap);

    }





    function _validatePurchase(uint256 _tokens) internal view {

        require(tokensSold.add(_tokens) <= cap);

    }





    /**

     * @dev Source of tokens. Override this method to modify the way in which the crowdsale ultimately gets and sends its tokens.

     * @param _beneficiary Address performing the token purchase

     * @param _tokenAmount Number of tokens to be emitted

     */

    function _deliverTokens(address _beneficiary, uint256 _tokenAmount) internal {

        token.safeTransfer(_beneficiary, _tokenAmount.mul(1 ether));

    }



    /**

     * @dev Executed when a purchase has been validated and is ready to be executed. Not necessarily emits/sends tokens.

     * @param _beneficiary Address receiving the tokens

     * @param _tokenAmount Number of tokens to be purchased

     */

    function _processPurchase(address _beneficiary, uint256 _tokenAmount) internal {

        _deliverTokens(_beneficiary, _tokenAmount);

    }





    /**

     * @dev Override to extend the way in which ether is converted to tokens.

     */

    function _getTokenAmount(uint256 _weiAmount) internal returns (uint,uint,uint,uint) {

        uint _tokens;

        uint _tokens_price;



        //§Ö§ã§Ý§Ú §Ó§ã§Ö §ï§ä§Ñ§á§í §á§â§à§ê§Ý§Ú, §ä§à §á§â§à§Õ§Ñ§Ö§Þ §ä§à§Ü§Ö§ß§í §Ò§Ö§Ù §Ò§à§ß§å§ã§à§Ó.

        if (currentStage == stageCount && (stages[stageCount].stopDay <= now || stages[currentStage].tokens == 0)) {

            _tokens = _weiAmount.div(tokenPriceInWei);

            _tokens_price = _tokens.mul(tokenPriceInWei);

            uint _diff = _weiAmount.sub(_tokens_price);

            return (_tokens, 0, _tokens, _diff);

        }



        uint _bonus = 0;

        uint _current_tokens = 0;

        uint _current_bonus = 0;



        for (uint i = currentStage; i <= stageCount && _weiAmount >= tokenPriceInWei; i++) {

            if (stages[i].tokens > 0 ) {

                uint _limit = stages[i].tokens.mul(tokenPriceInWei);

                //§Ö§ã§Ý§Ú §Ý§Ú§Þ§Ú§ä §Ò§à§Ý§î§ê§Ö §é§Ö§Þ _weiAmount, §ä§à§Ô§Õ§Ñ §ã§é§Ú§ä§Ñ§Ö§Þ §Ó§ã§Ö §Ú§Ù §â§Ñ§ã§é§Ö§ä§Ñ §é§ä§à §Ó§á§Ú§ã§í§Ó§Ñ§Ö§Þ§ã§ñ §Ó §Ý§Ú§Þ§Ú§ä

                //§Ú §Ó§í§ç§à§Õ§Ú§Þ §Ú§Ù §è§Ú§Ü§Ý§Ñ

                if (_limit > _weiAmount) {

                    //§Ü§à§Ý§Ú§é§Ö§ã§ä§Ó§à §ä§à§Ü§Ö§ß§à§Ó §á§à §ä§Ö§Ü§å§ë§Ö§Þ§å §á§â§Ñ§Û§ã§å (§à§ã§ä§Ñ§ß§Ö§ä§ã§ñ §à§ã§ä§Ñ§ä§à§Ü §Ö§ã§Ý§Ú §á§â§Ú§ã§Ý§Ñ§Ý§Ú  §Ò§à§Ý§î§ê§Ö §é§Ö§Þ §ß§Ñ §ä§à§é§ß§à§Ö §Ü§à§Ý§Ú§é§Ö§ã§ä§Ó§à §Þ§à§ß§Ö§ä)

                    _current_tokens = _weiAmount.div(tokenPriceInWei);

                    //§è§Ö§ß§Ñ §Ó§ã§Ö§ç §Þ§à§ß§Ö§ä, §é§ä§à§Ò§í §à§á§â§Ö§Õ§Ö§Ý§Ú§ä§î §à§ã§ä§Ñ§ä§à§Ü §ß§Ö§Ú§Ù§â§Ñ§ã§ç§à§Õ§à§Ó§Ñ§ß§ß§í§ç wei

                    _tokens_price = _current_tokens.mul(tokenPriceInWei);

                    //§á§à§Ý§å§é§Ñ§Ö§Þ §à§ã§ä§Ñ§ä§à§Ü

                    _weiAmount = _weiAmount.sub(_tokens_price);

                    //§Õ§à§Ò§Ñ§Ó§Ý§ñ§Ö§Þ §ä§à§Ü§Ö§ß§í §ä§Ö§Ü§å§ë§Ö§Ô§à §ã§ä§ï§Û§Õ§Ø§Ñ §Ü §à§Ò§ë§Ö§Þ§å §Ü§à§Ý§Ú§é§Ö§ã§ä§Ó§å

                    _tokens = _tokens.add(_current_tokens);

                    //§à§Ò§ß§à§Ó§Ý§ñ§Ö§Þ §Ý§Ú§Þ§Ú§ä§í

                    stages[i].tokens = stages[i].tokens.sub(_current_tokens);



                    _current_bonus = _current_tokens.mul(stages[i].bonus).div(10000);

                    _bonus = _bonus.add(_current_bonus);



                } else { //§Ý§Ú§Þ§Ú§ä §Þ§Ö§ß§î§ê§Ö §é§Ö§Þ §Ü§à§Ý§Ú§é§Ö§ã§ä§Ó§à wei

                    //§á§à§Ý§å§é§Ñ§Ö§Þ §Ó§ã§Ö §à§ã§ä§Ñ§Ó§ê§Ú§Ö§ã§ñ §ä§à§Ü§Ö§ß§í §Ó §ã§ä§Ö§Û§Õ§Ø§Ö

                    _current_tokens = stages[i].tokens;

                    _tokens_price = _current_tokens.mul(tokenPriceInWei);

                    _weiAmount = _weiAmount.sub(_tokens_price);

                    _tokens = _tokens.add(_current_tokens);

                    stages[i].tokens = 0;



                    _current_bonus = _current_tokens.mul(stages[i].bonus).div(10000);

                    _bonus = _bonus.add(_current_bonus);



                    _updateCurrentStage();

                }

            }

        }



        //§¦§ã§Ý§Ú §Ó §á§à§ã§Ý§Ö§Õ§ß§Ö§Þ §ã§ä§Ö§Û§ß§Õ§Ø§Ö §Ù§Ñ§Ü§à§ß§é§Ú§Ý§Ú§ã§î §ä§à§Ü§Ö§ß§í, §ä§à §Õ§à§Ò§Ú§â§Ñ§Ö§Þ §Ú§Ù §ä§Ö§ç §é§ä§à §Ò§Ö§Ù §Ò§à§ß§å§ã§à§Ó §á§â§à§Õ§Ñ§ð§ä§ã§ñ

        if (_weiAmount >= tokenPriceInWei) {

            _current_tokens = _weiAmount.div(tokenPriceInWei);

            _tokens_price = _current_tokens.mul(tokenPriceInWei);

            _weiAmount = _weiAmount.sub(_tokens_price);

            _tokens = _tokens.add(_current_tokens);

        }



        return (_tokens, _bonus, _tokens.add(_bonus), _weiAmount);

    }





    function _updateCurrentStage() internal {

        for (uint i = currentStage; i <= stageCount; i++) {

            if (stages[i].stopDay > now && stages[i].tokens > 0) {

                currentStage = i;

                break;

            }

        }

    }





    function _updateState(uint256 _weiAmount, uint256 _tokens) internal {

        weiRaised = weiRaised.add(_weiAmount);

        tokensSold = tokensSold.add(_tokens);

    }





    function getRefPercent() public {

        require(refs[msg.sender] >= minWithdrawValue);

        require(weiRaised >= globalMinWithdrawValue);

        uint _val = refs[msg.sender];

        refs[msg.sender] = 0;

        msg.sender.transfer(_val);

    }



    /**

     * @dev Overrides Crowdsale fund forwarding, sending funds to escrow.

     */

    function _forwardFunds(uint _weiAmount) internal {

        wallet.transfer(_weiAmount);

    }



    /**

    * @dev Checks whether the cap has been reached.

    * @return Whether the cap was reached

    */

    function capReached() public view returns (bool) {

        return tokensSold >= cap;

    }





    /**

     * @dev Must be called after crowdsale ends, to do some extra finalization

     * work. Calls the contract's finalization function.

     */

    function finalize() onlyOwner public {

        require(!isFinalized);

        //require(hasClosed() || capReached());



        finalization();

        emit Finalized();



        isFinalized = true;

    }



    /**

     * @dev Can be overridden to add finalization logic. The overriding function

     * should call super.finalization() to ensure the chain of finalization is

     * executed entirely.

     */

    function finalization() internal {

        if (token.balanceOf(this) > 0) {

            token.safeTransfer(wallet, token.balanceOf(this));

        }

    }





    //1% - 100, 10% - 1000 50% - 5000

    function valueFromPercent(uint _value, uint _percent) internal pure returns (uint amount)    {

        uint _amount = _value.mul(_percent).div(10000);

        return (_amount);

    }





    function setBuyerRefPercent(uint _buyerRefPercent) onlyOwner public {

        buyerRefPercent = _buyerRefPercent;

    }



    function setReferrerPercent(uint _referrerPercent) onlyOwner public {

        referrerPercent = _referrerPercent;

    }



    function setMinWithdrawValue(uint _minWithdrawValue) onlyOwner public {

        minWithdrawValue = _minWithdrawValue;

    }



    function setGlobalMinWithdrawValue(uint _globalMinWithdrawValue) onlyOwner public {

        globalMinWithdrawValue = _globalMinWithdrawValue;

    }







    /// @notice This method can be used by the owner to extract mistakenly

    ///  sent tokens to this contract.

    /// @param _token The address of the token contract that you want to recover

    ///  set to 0 in case you want to extract ether.

    function claimTokens(address _token, address _to) external onlyOwner {

        require(_to != address(0));

        if (_token == 0x0) {

            _to.transfer(address(this).balance);

            return;

        }



        ERC20 t = ERC20(_token);

        uint balance = t.balanceOf(this);

        t.safeTransfer(_to, balance);

    }



}