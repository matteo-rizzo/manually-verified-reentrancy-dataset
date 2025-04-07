/**

 *Submitted for verification at Etherscan.io on 2018-11-15

*/



/**

 * Copyright (c) 2018 blockimmo AG [emailÂ protected]

 * Non-Profit Open Software License 3.0 (NPOSL-3.0)

 * https://opensource.org/licenses/NPOSL-3.0

 */

 



pragma solidity 0.4.25;





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

 * @title Escrow

 * @dev Base escrow contract, holds funds destinated to a payee until they

 * withdraw them. The contract that uses the escrow as its payment method

 * should be its owner, and provide public methods redirecting to the escrow's

 * deposit and withdraw.

 */

contract Escrow is Ownable {

  using SafeMath for uint256;



  event Deposited(address indexed payee, uint256 weiAmount);

  event Withdrawn(address indexed payee, uint256 weiAmount);



  mapping(address => uint256) private deposits;



  function depositsOf(address _payee) public view returns (uint256) {

    return deposits[_payee];

  }



  /**

  * @dev Stores the sent amount as credit to be withdrawn.

  * @param _payee The destination address of the funds.

  */

  function deposit(address _payee) public onlyOwner payable {

    uint256 amount = msg.value;

    deposits[_payee] = deposits[_payee].add(amount);



    emit Deposited(_payee, amount);

  }



  /**

  * @dev Withdraw accumulated balance for a payee.

  * @param _payee The address whose funds will be withdrawn and transferred to.

  */

  function withdraw(address _payee) public onlyOwner {

    uint256 payment = deposits[_payee];

    assert(address(this).balance >= payment);



    deposits[_payee] = 0;



    _payee.transfer(payment);



    emit Withdrawn(_payee, payment);

  }

}





/**

 * @title ConditionalEscrow

 * @dev Base abstract escrow to only allow withdrawal if a condition is met.

 */

contract ConditionalEscrow is Escrow {

  /**

  * @dev Returns whether an address is allowed to withdraw their funds. To be

  * implemented by derived contracts.

  * @param _payee The destination address of the funds.

  */

  function withdrawalAllowed(address _payee) public view returns (bool);



  function withdraw(address _payee) public {

    require(withdrawalAllowed(_payee));

    super.withdraw(_payee);

  }

}





/**

 * @title RefundEscrow

 * @dev Escrow that holds funds for a beneficiary, deposited from multiple parties.

 * The contract owner may close the deposit period, and allow for either withdrawal

 * by the beneficiary, or refunds to the depositors.

 */

contract RefundEscrow is Ownable, ConditionalEscrow {

  enum State { Active, Refunding, Closed }



  event Closed();

  event RefundsEnabled();



  State public state;

  address public beneficiary;



  /**

   * @dev Constructor.

   * @param _beneficiary The beneficiary of the deposits.

   */

  constructor(address _beneficiary) public {

    require(_beneficiary != address(0));

    beneficiary = _beneficiary;

    state = State.Active;

  }



  /**

   * @dev Stores funds that may later be refunded.

   * @param _refundee The address funds will be sent to if a refund occurs.

   */

  function deposit(address _refundee) public payable {

    require(state == State.Active);

    super.deposit(_refundee);

  }



  /**

   * @dev Allows for the beneficiary to withdraw their funds, rejecting

   * further deposits.

   */

  function close() public onlyOwner {

    require(state == State.Active);

    state = State.Closed;

    emit Closed();

  }



  /**

   * @dev Allows for refunds to take place, rejecting further deposits.

   */

  function enableRefunds() public onlyOwner {

    require(state == State.Active);

    state = State.Refunding;

    emit RefundsEnabled();

  }



  /**

   * @dev Withdraws the beneficiary's funds.

   */

  function beneficiaryWithdraw() public {

    require(state == State.Closed);

    beneficiary.transfer(address(this).balance);

  }



  /**

   * @dev Returns whether refundees can withdraw their deposits (be refunded).

   */

  function withdrawalAllowed(address _payee) public view returns (bool) {

    return state == State.Refunding;

  }

}