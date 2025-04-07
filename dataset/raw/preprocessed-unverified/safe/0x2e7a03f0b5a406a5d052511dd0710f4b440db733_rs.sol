pragma solidity 0.4.24;



// File: node_modules/openzeppelin-solidity/contracts/ownership/Ownable.sol



/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */





// File: node_modules/openzeppelin-solidity/contracts/lifecycle/Pausable.sol



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



// File: node_modules/openzeppelin-solidity/contracts/math/SafeMath.sol



/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */





// File: contracts/CoiPreSale.sol



/**

 * @title CoiPreSale

 * @dev This crowdsale contract filters investments made according to

 *         - time

 *         - amount invested (in Wei)

 *      and forwards them to a predefined wallet in case all the filtering conditions are met.

 */

contract CoiPreSale is Pausable {

    using SafeMath for uint256;



    // start and end timestamps where investments are allowed (both inclusive)

    uint256 public startTime;

    uint256 public endTime;



    // address where funds are collected

    address public wallet;



    // track the investments made from each address

    mapping(address => uint256) public investments;



    // total amount of funds raised (in wei)

    uint256 public weiRaised;



    uint256 public minWeiInvestment;

    uint256 public maxWeiInvestment;



    /**

     * @dev Event for token purchase logging

     * @param purchaser who paid for the tokens

     * @param beneficiary who got the tokens

     * @param value weis paid for purchase

     */

    event Investment(address indexed purchaser,

        address indexed beneficiary,

        uint256 value,

        bytes payload);



    /**

     * @dev Constructor

     * @param _startTime the time to begin the crowdsale in seconds since the epoch

     * @param _endTime the time to begin the crowdsale in seconds since the epoch. Must be later than _startTime.

     * @param _minWeiInvestment the minimum amount for one single investment (in Wei)

     * @param _maxWeiInvestment the maximum amount for one single investment (in Wei)

     * @param _wallet the address to which funds will be directed to

     */

    constructor(uint256 _startTime,

        uint256 _endTime,

        uint256 _minWeiInvestment,

        uint256 _maxWeiInvestment,

        address _wallet) public {

        require(_endTime > _startTime);

        require(_minWeiInvestment > 0);

        require(_maxWeiInvestment > _minWeiInvestment);

        require(_wallet != address(0));



        startTime = _startTime;

        endTime = _endTime;



        minWeiInvestment = _minWeiInvestment;

        maxWeiInvestment = _maxWeiInvestment;



        wallet = _wallet;

    }



    /**

     * @dev External payable function to receive funds and buy tokens.

     */

    function () external payable {

        buyTokens(msg.sender);

    }



    /**

     * @dev Adapted Crowdsale#hasEnded

     * @return true if crowdsale event has started

     */

    function hasStarted() external view returns (bool) {

        return now >= startTime;

    }



    /**

     * @dev Adapted Crowdsale#hasEnded

     * @return true if crowdsale event has ended

     */

    function hasEnded() external view returns (bool) {

        return now > endTime;

    }



    /**

     * @dev Low level token purchase function

     * @param beneficiary the wallet to which the investment should be credited

     */

    function buyTokens(address beneficiary) public whenNotPaused payable {

        require(beneficiary != address(0));

        require(validPurchase());



        uint256 weiAmount = msg.value;



        // track how much wei is raised in total

        weiRaised = weiRaised.add(weiAmount);



        // track how much was transfered by the specific investor

        investments[beneficiary] = investments[beneficiary].add(weiAmount);



        emit Investment(msg.sender, beneficiary, weiAmount, msg.data);



        forwardFunds();

    }



    // send ether (wei) to the fund collection wallet

    // override to create custom fund forwarding mechanisms

    function forwardFunds() internal {

        wallet.transfer(msg.value);

    }



    // overriding Crowdsale#validPurchase to add extra cap logic

    // @return true if investors can buy at the moment

    function validPurchase() internal view returns (bool) {

        if (msg.value < minWeiInvestment || msg.value > maxWeiInvestment) {

            return false;

        }

        bool withinPeriod = (now >= startTime) && (now <= endTime);  // 1128581 1129653

        return withinPeriod;

    }

}