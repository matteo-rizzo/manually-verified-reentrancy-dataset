/**
 *Submitted for verification at Etherscan.io on 2020-11-06
*/

pragma solidity 0.6.10;




contract LazarusCreators {
  using SafeMath for uint256;

  address payable public owner;
  uint256 public ethBalance;
  uint256 public fee = 1;

  // mapping that stores credits for users.
  mapping(address => uint256) credits;

  constructor () public {
    owner = msg.sender; 
  }

  function getCredit () external payable {
    if (fee == 1) {
      require(msg.value == 0.1 ether);
    } else if (fee == 2) {
      require(msg.value == 0.25 ether);
    } else if (fee == 3) {
      require(msg.value == 0.5 ether);
    } else if (fee == 4) {
      require(msg.value == 1 ether);
    }
    ethBalance = ethBalance.add(msg.value);
    credits[msg.sender] = credits[msg.sender].add(1);
  }

  function setFee (uint256 _fee) public {
    require(msg.sender == owner);
    fee = _fee;
  }

  function getUserCredits (address _user) public view returns (uint256) {
    return credits[_user];
  }

  function useCredit () public {
    require(credits[msg.sender] >= 1);
    credits[msg.sender] = credits[msg.sender].sub(1);
  }

  function withdrawETH () public {
    require(msg.sender == owner);
    owner.transfer(ethBalance);
    ethBalance = 0;
  }

  function transferOwnership (address payable _newOwner) public {
    require(msg.sender == owner);
    owner = _newOwner;
  }
}