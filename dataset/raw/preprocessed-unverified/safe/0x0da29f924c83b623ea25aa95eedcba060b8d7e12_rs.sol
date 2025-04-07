/**

 *Submitted for verification at Etherscan.io on 2018-09-17

*/



pragma solidity ^0.4.24;





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

 * @title ERC20Basic

 * @dev Simpler version of ERC20 interface

 * See https://github.com/ethereum/EIPs/issues/179

 */

contract ERC20Basic {

  function totalSupply() public view returns (uint256);

  function balanceOf(address _who) public view returns (uint256);

  function transfer(address _to, uint256 _value) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

}





/**

 * @title ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/20

 */

contract ERC20 is ERC20Basic {

  function allowance(address _owner, address _spender)

    public view returns (uint256);



  function transferFrom(address _from, address _to, uint256 _value)

    public returns (bool);



  function approve(address _spender, uint256 _value) public returns (bool);

  event Approval(

    address indexed owner,

    address indexed spender,

    uint256 value

  );

}





/**

 * @title VeloxCrowdsale

 * @dev VeloxToken ERC20 token crowdsale contract

 */

contract VeloxCrowdsale is Ownable {

    using SafeMath for uint256;



    // The token being sold

    ERC20 public token;



    // Crowdsale start and end timestamps

    uint256 public startTime;

    uint256 public endTime;



    // Price per smallest token unit in wei

    uint256 public rate;



    // Crowdsale cap in tokens

    uint256 public cap;



    // Address where ETH and unsold tokens are collected

    address public wallet;



    // Amount of tokens sold

    uint256 public sold;



    /**

     * @dev Constructor to set instance variables

     */

    constructor(

        uint256 _startTime,

        uint256 _endTime,

        uint256 _rate,

        uint256 _cap,

        address _wallet,

        ERC20 _token

    ) public {

        require(_startTime >= block.timestamp && _endTime >= _startTime);

        require(_rate > 0);

        require(_cap > 0);

        require(_wallet != address(0));

        require(_token != address(0));



        startTime = _startTime;

        endTime = _endTime;

        rate = _rate;

        cap = _cap;

        wallet = _wallet;

        token = _token;

    }



    /**

     * @dev Event for token purchase logging

     * @param purchaser who paid for the tokens

     * @param beneficiary who got the tokens

     * @param value weis paid for purchase

     * @param amount amount of tokens purchased

     */

    event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);



    /**

    * @dev Fallback token purchase function

    */

    function () external payable {

        buyTokens(msg.sender);

    }



    /**

     * @dev Token purchase function

     * @param _beneficiary Address receiving the purchased tokens

     */

    function buyTokens(address _beneficiary) public payable {

        uint256 weiAmount = msg.value;

        require(_beneficiary != address(0));

        require(weiAmount != 0);

        require(block.timestamp >= startTime && block.timestamp <= endTime);

        uint256 tokens = weiAmount.div(rate);

        require(tokens != 0 && sold.add(tokens) <= cap);

        sold = sold.add(tokens);

        require(token.transfer(_beneficiary, tokens));

        emit TokenPurchase(

            msg.sender,

            _beneficiary,

            weiAmount,

            tokens

        );

    }



    /**

    * @dev Checks whether the cap has been reached.

    * @return Whether the cap was reached

    */

    function capReached() public view returns (bool) {

        return sold >= cap;

    }



    /**

     * @dev Boolean to protect from replaying the finalization function

     */

    bool public isFinalized = false;



    /**

     * @dev Event for crowdsale finalization (forwarding)

     */

    event Finalized();



    /**

     * @dev Must be called after crowdsale ends to forward all funds

     */

    function finalize() external onlyOwner {

        require(!isFinalized);

        require(block.timestamp > endTime || sold >= cap);

        token.transfer(wallet, token.balanceOf(this));

        wallet.transfer(address(this).balance);

        emit Finalized();

        isFinalized = true;

    }



    /**

     * @dev Function for owner to forward ETH from contract

     */

    function forwardFunds() external onlyOwner {

        require(!isFinalized);

        require(block.timestamp > startTime);

        uint256 balance = address(this).balance;

        require(balance > 0);

        wallet.transfer(balance);

    }

}