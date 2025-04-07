pragma solidity ^0.4.18;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */


contract PullPayment {
  using SafeMath for uint256;

  mapping(address => uint256) public payments;
  uint256 public totalPayments;

  /**
  * @dev withdraw accumulated balance, called by payee.
  */
  function withdrawPayments() public {
    address payee = msg.sender;
    uint256 payment = payments[payee];

    require(payment != 0);
    require(this.balance >= payment);

    totalPayments = totalPayments.sub(payment);
    payments[payee] = 0;

    assert(payee.send(payment));
  }

  /**
  * @dev Called by the payer to store the sent amount as credit to be pulled.
  * @param dest The destination address of the funds.
  * @param amount The amount to transfer.
  */
  function asyncSend(address dest, uint256 amount) internal {
    payments[dest] = payments[dest].add(amount);
    totalPayments = totalPayments.add(amount);
  }
}

contract EtherPizza is Ownable, PullPayment {

    address public pizzaHolder;
    uint256 public pizzaPrice;

    function EtherPizza() public {
        pizzaHolder = msg.sender;
        pizzaPrice = 100000000000000000; // 0.1 ETH initial price
    }

    function gimmePizza() external payable {
        require(msg.value >= pizzaPrice);
        require(msg.sender != pizzaHolder);
        uint taxesAreSick = msg.value.div(100);
        uint hodlerPrize = msg.value.sub(taxesAreSick);
        asyncSend(pizzaHolder, hodlerPrize);
        asyncSend(owner, taxesAreSick);
        pizzaHolder = msg.sender;
        pizzaPrice = pizzaPrice.mul(2);
    }


}