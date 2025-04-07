pragma solidity ^0.4.23;





/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */



/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */









 contract ETHERFLEXCrowdsale is Ownable{

  using SafeMath for uint256;

 

  // The token being sold

  TokenInterface public token;



  // how many token units a buyer gets per eth

  uint256 public ratePerEthPhase1 = 4866;

  uint256 public ratePerEthPhase2 = 2433;

  uint256 public ratePerEthPhase3 = 1081;



  // amount of raised money in wei

  uint256 public weiRaised;



  uint256 public TOKENS_SOLD;

  

  

  bool isCrowdsalePaused = false;

  uint public maxTokensToSale=51000000*10**18;

  

  /**

   * event for token purchase logging

   * @param purchaser who paid for the tokens

   * @param beneficiary who got the tokens

   * @param value weis paid for purchase

   * @param amount amount of tokens purchased

   */

  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);



  function ETHERFLEXCrowdsale(address _wallet, address _tokenAddress) public 

  {

    require(_wallet != 0x0);

    weiRaised=0;

    owner = _wallet;

    token = TokenInterface(_tokenAddress);

  }

  

  

   // fallback function can be used to buy tokens

   function () public  payable {

     buyTokens(msg.sender);

    }

   

  // low level token purchase function

  

  function buyTokens(address beneficiary) public payable {

    require(beneficiary != 0x0);

    require(isCrowdsalePaused == false);

    require(validPurchase());

    require(TOKENS_SOLD<maxTokensToSale);

    

    uint256 weiAmount = msg.value;

    uint256 tokens=0;



    // calculate token amount to be created

    if(TOKENS_SOLD<=5000000*10**18)

    {

        tokens = weiAmount.mul(ratePerEthPhase1);

    }

    else if(TOKENS_SOLD>5000000*10**18 && TOKENS_SOLD<=15000000*10**18)

    {

        tokens = weiAmount.mul(ratePerEthPhase2);

    }

    else if(TOKENS_SOLD>15000000*10**18 && TOKENS_SOLD<=51000000*10**18)

    {

        tokens = weiAmount.mul(ratePerEthPhase3);

    }

    else

    {

        revert();

    }

    

    // update state

    weiRaised = weiRaised.add(weiAmount);

    token.transfer(beneficiary,tokens);

    emit TokenPurchase(owner, beneficiary, weiAmount, tokens);

    TOKENS_SOLD = TOKENS_SOLD.add(tokens);

    forwardFunds();

  }



  // send ether to the fund collection wallet

  function forwardFunds() internal {

    owner.transfer(msg.value);

  }



  // @return true if the transaction can buy tokens

  function validPurchase() internal constant returns (bool) {

    bool nonZeroPurchase = msg.value != 0;

    return nonZeroPurchase;

  }

   

     /**

     * function to pause the crowdsale 

     * can only be called from owner wallet

     **/

     

    function pauseCrowdsale() public onlyOwner {

        isCrowdsalePaused = true;

    }



    /**

     * function to resume the crowdsale if it is paused

     * can only be called from owner wallet

     **/ 

    function resumeCrowdsale() public onlyOwner {

        isCrowdsalePaused = false;

    }

    

  

     

     // ------------------------------------------------------------------------

     // Remaining tokens for sale

     // ------------------------------------------------------------------------

     function remainingTokensForSale() public constant returns (uint) {

         return maxTokensToSale.sub(TOKENS_SOLD);

     }

    

     

     function burnUnsoldTokens() public onlyOwner 

     {

         uint value = remainingTokensForSale();

         token.burn(value);

         TOKENS_SOLD = maxTokensToSale;

     }

     

    /**

      * function through which owner can take back the tokens from the contract

      **/ 

     function takeTokensBack() public onlyOwner

     {

         uint remainingTokensInTheContract = token.balanceOf(address(this));

         token.transfer(owner,remainingTokensInTheContract);

     }

     

      /**

     * send Tokens Manually

     **/ 

    function manualTransfer(address beneficiary, uint tokens) public onlyOwner {

        token.transfer(beneficiary,tokens);

        emit TokenPurchase(owner, beneficiary, 0, tokens);

        TOKENS_SOLD = TOKENS_SOLD.add(tokens);

    }

  

 }