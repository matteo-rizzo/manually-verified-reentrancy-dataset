/**

 *Submitted for verification at Etherscan.io on 2018-09-21

*/



pragma solidity ^0.4.25;



// Author: Securypto Team | Iceman

// Telegram: ice_man0



/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */





/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */





/**

 * @title Token

 * @dev API interface for interacting with the DSGT contract 

 */





contract Crowdsale is Ownable {



  using SafeMath for uint256;



  Token public token;



  uint256 public raisedETH; // ETH raised

  uint256 public soldTokens; // Tokens Sold

  uint256 public saleMinimum = 0.1 * 1 ether;

  uint256 public price;



  address public beneficiary;



  // They'll be represented by their index numbers i.e 

  // if the state is Dormant, then the value should be 0 

  // Dormant:0, Active:1, , Successful:2

  enum State {Dormant, Active,  Successful }



  State public state;

 

  event ActiveState();

  event DormantState();

  event SuccessfulState();



  event BoughtTokens(

      address indexed who, 

      uint256 tokensBought, 

      uint256 investedETH

      );

  

  constructor() 

              public 

              {

                token = Token(0x2Ed92cae08B7E24d7C01A11049750498ebCAe8E0);

                beneficiary = msg.sender;

    }



    /**

     * Fallback function

     *

     * @dev This function will be called whenever anyone sends funds to a contract,

     * throws if the sale isn't Active or the sale minimum isn't met

     */

    function () public payable {

        require(msg.value >= saleMinimum);

        require(state == State.Active);

        require(token.balanceOf(this) > 0);

        

        buyTokens();

      }



  /**

  * @dev Function that sells available tokens

  */

  function buyTokens() public payable  {

    

    uint256 invested = msg.value;

    

    uint256 numberOfTokens = invested.mul(price);

    

    beneficiary.transfer(msg.value);

    

    token.transfer(msg.sender, numberOfTokens);

    

    raisedETH = raisedETH.add(msg.value);

    

    soldTokens = soldTokens.add(numberOfTokens);



    emit BoughtTokens(msg.sender, numberOfTokens, invested);

    

    }





  /**

   * @dev Change the price during the different rounds

   */

  function changeRate(uint256 _newPrice) public onlyOwner {

      price = _newPrice;

  }    



  /**

   *  @dev Change the sale minimum

   */

  function changeSaleMinimum(uint256 _newAmount) public onlyOwner {

      saleMinimum = _newAmount;

  }



  /**

   * @dev Ends the sale

   */

  function endSale() public onlyOwner {

    require(state == State.Active || state == State.Dormant);

    

    state = State.Successful;

    emit SuccessfulState();



    selfdestruct(owner);



  }

  

   /**

   * @dev Makes the sale dormant, no deposits are allowed

   */

  function pauseSale() public onlyOwner {

      require(state == State.Active);

      

      state = State.Dormant;

      emit DormantState();

  }

  

  /**

   * @dev Makes the sale active, thus funds can be received

   */

  function openSale() public onlyOwner {

      require(state == State.Dormant);

      

      state = State.Active;

      emit ActiveState();

  }

  

  /**

   *  @dev Returns the number of tokens in contract

   */

  function tokensAvailable() public view returns(uint256) {

      return token.balanceOf(this);

  }



}