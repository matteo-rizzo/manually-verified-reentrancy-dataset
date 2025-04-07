pragma solidity ^0.4.21;

contract ERC20Token  {

  function transfer(address to, uint256 value) public returns (bool);

}



/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */



/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */







/**

 * @title Pausable

 * @dev Base contract which allows children to implement an emergency stop mechanism.

 */

contract Pausable is Ownable {

  event Pause();

  event Unpause();



  bool public paused = false;





  /**

   * @dev Modifier to make a function callable only when the contract is not paused.

   */

  modifier whenNotPaused() {

    require(!paused);

    _;

  }



  /**

   * @dev Modifier to make a function callable only when the contract is paused.

   */

  modifier whenPaused() {

    require(paused);

    _;

  }



  /**

   * @dev called by the owner to pause, triggers stopped state

   */

  function pause() onlyOwner whenNotPaused public {

    paused = true;

   emit Pause();

  }



  /**

   * @dev called by the owner to unpause, returns to normal state

   */

  function unpause() onlyOwner whenPaused public {

    paused = false;

   emit Unpause();

  }

}

/**

 * @title Destructible

 * @dev Base contract that can be destroyed by owner. All funds in contract will be sent to the owner.

 */

contract Destructible is Pausable {



  function Destructible() public payable { }



  /**

   * @dev Transfers the current balance to the owner and terminates the contract.

   */

  function destroy() onlyOwner public {

    selfdestruct(owner);

  }



  function destroyAndSend(address _recipient) onlyOwner public {

    selfdestruct(_recipient);

  }

}









contract PTMCrowdFund is Destructible {

    event PurchaseToken (address indexed from,uint256 weiAmount,uint256 _tokens);

     uint public priceOfToken=250000000000000;//1 eth = 4000 PTM

    ERC20Token erc20Token;

    using SafeMath for uint256;

    uint256 etherRaised;

    uint public constant decimals = 18;

    function PTMCrowdFund () public {

        owner = msg.sender;

        erc20Token = ERC20Token(0x7c32DB0645A259FaE61353c1f891151A2e7f8c1e);

    }

    function updatePriceOfToken(uint256 priceInWei) external onlyOwner {

        priceOfToken = priceInWei;

    }

    

    function updateTokenAddress ( address _tokenAddress) external onlyOwner {

        erc20Token = ERC20Token(_tokenAddress);

    }

    

      function()  public whenNotPaused payable {

          require(msg.value>0);

          uint256 tokens = (msg.value * (10 ** decimals)) / priceOfToken;

          erc20Token.transfer(msg.sender,tokens);

          etherRaised += msg.value;

          

      }

      

        /**

    * Transfer entire balance to any account (by owner and admin only)

    **/

    function transferFundToAccount(address _accountByOwner) public onlyOwner {

        require(etherRaised > 0);

        _accountByOwner.transfer(etherRaised);

        etherRaised = 0;

    }



    

    /**

    * Transfer part of balance to any account (by owner and admin only)

    **/

    function transferLimitedFundToAccount(address _accountByOwner, uint256 balanceToTransfer) public onlyOwner   {

        require(etherRaised > balanceToTransfer);

        _accountByOwner.transfer(balanceToTransfer);

        etherRaised = etherRaised.sub(balanceToTransfer);

    }

    

}