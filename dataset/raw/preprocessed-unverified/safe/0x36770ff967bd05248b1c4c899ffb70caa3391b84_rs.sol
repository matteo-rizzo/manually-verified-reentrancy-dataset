pragma solidity ^0.4.18;

// zeppelin-solidity: 1.5.0

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */


contract Bank {
  using SafeMath for *;

  uint public totalShares = 0;
  uint public totalReleased = 0;

  mapping(address => uint) public shares;
  mapping(address => uint) public released;
  address[] public payees;

  function Bank(address[] _payees, uint[] _shares) public payable {
    require(_payees.length == _shares.length);

    for (uint i = 0; i < _payees.length; i++) {
      addPayee(_payees[i], _shares[i]);
    }
  }

  function addPayee(address _payee, uint _shares) internal {
    require(_payee != address(0));
    require(_shares > 0);
    require(shares[_payee] == 0);

    payees.push(_payee);
    shares[_payee] = _shares;
    totalShares = totalShares.add(_shares);
  }

  function claim() public {
    address payee = msg.sender;

    require(shares[payee] > 0);

    uint totalReceived = this.balance.add(totalReleased);
    uint payment = totalReceived.mul(shares[payee]).div(totalShares).sub(released[payee]);

    require(payment != 0);
    require(this.balance >= payment);

    released[payee] = released[payee].add(payment);
    totalReleased = totalReleased.add(payment);

    payee.transfer(payment);
  }

  function () public payable {}
}