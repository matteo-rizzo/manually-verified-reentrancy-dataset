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

 * @title SplitPayment

 * @dev Base contract that supports multiple payees claiming funds sent to this contract

 * according to the proportion they own.

 */

contract SplitPayment {

  using SafeMath for uint256;



  uint256 public totalShares = 0;

  uint256 public totalReleased = 0;



  mapping(address => uint256) public shares;

  mapping(address => uint256) public released;

  address[] public payees;



  /**

   * @dev Constructor

   */

  constructor(address[] _payees, uint256[] _shares) public payable {

    require(_payees.length == _shares.length);



    for (uint256 i = 0; i < _payees.length; i++) {

      addPayee(_payees[i], _shares[i]);

    }

  }



  /**

   * @dev payable fallback

   */

  function () external payable {}



  /**

   * @dev Claim your share of the balance.

   */

  function claim() public {

    address payee = msg.sender;



    require(shares[payee] > 0);



    uint256 totalReceived = address(this).balance.add(totalReleased);

    uint256 payment = totalReceived.mul(

      shares[payee]).div(

        totalShares).sub(

          released[payee]

    );



    require(payment != 0);

    require(address(this).balance >= payment);



    released[payee] = released[payee].add(payment);

    totalReleased = totalReleased.add(payment);



    payee.transfer(payment);

  }





  /**

   * @dev Add a new payee to the contract.

   * @param _payee The address of the payee to add.

   * @param _shares The number of shares owned by the payee.

   */

  function addPayee(address _payee, uint256 _shares) internal {

    require(_payee != address(0));

    require(_shares > 0);

    require(shares[_payee] == 0);



    payees.push(_payee);

    shares[_payee] = _shares;

    totalShares = totalShares.add(_shares);

  }

}





contract Payments is Ownable, SplitPayment {

  constructor() public SplitPayment(new address[](0), new uint256[](0)) { }



  function addPayment(address _payee, uint256 _amount) public onlyOwner {

    addPayee(_payee, _amount);

  }

}