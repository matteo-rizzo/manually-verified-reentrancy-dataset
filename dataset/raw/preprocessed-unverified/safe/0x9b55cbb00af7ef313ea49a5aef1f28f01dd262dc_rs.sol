pragma solidity ^0.4.17;



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

    Pause();

  }



  /**

   * @dev called by the owner to unpause, returns to normal state

   */

  function unpause() onlyOwner whenPaused public {

    paused = false;

    Unpause();

  }

}



contract BonumPreICO is Pausable{

    using SafeMath for uint;



    string public constant name = "Bonum PreICO";



    uint public fiatValueMultiplier = 10**6;

    uint public tokenDecimals = 10**18;



    address public beneficiary;



    uint public ethUsdRate;

    uint public collected = 0;

    uint public tokensSold = 0;

    uint public tokensSoldWithBonus = 0;





    event NewContribution(address indexed holder, uint tokenAmount, uint etherAmount);



    function BonumPreICO(

        address _beneficiary,

        uint _baseEthUsdRate

    ) public {

        beneficiary = _beneficiary;



        ethUsdRate = _baseEthUsdRate;

    }





    function setNewBeneficiary(address newBeneficiary) external onlyOwner {

        require(newBeneficiary != 0x0);

        beneficiary = newBeneficiary;

    }



    function setEthUsdRate(uint rate) external onlyOwner {

        require(rate > 0);

        ethUsdRate = rate;

    }



    modifier underCap(){

        require(tokensSold < uint(750000).mul(tokenDecimals));

        _;

    }



    modifier minimumAmount(){

        require(msg.value.mul(ethUsdRate).div(fiatValueMultiplier.mul(1 ether)) >= 100);

        _;

    }



    mapping (address => uint) public investors;



    function() payable public whenNotPaused minimumAmount underCap{

        uint tokens = msg.value.mul(ethUsdRate).div(fiatValueMultiplier);

        tokensSold = tokensSold.add(tokens);

        

        tokens = tokens.add(tokens.mul(25).div(100));

        tokensSoldWithBonus =  tokensSoldWithBonus.add(tokens);

        

        investors[msg.sender] = investors[msg.sender].add(tokens);

        NewContribution(msg.sender, tokens, msg.value);



        collected = collected.add(msg.value);



        beneficiary.transfer(msg.value);

    }

}