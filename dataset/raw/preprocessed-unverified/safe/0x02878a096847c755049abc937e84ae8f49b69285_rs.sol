pragma solidity ^0.4.24;



contract TokenERC20 {
  function transfer(address _to, uint256 _value) public;
}

contract CaruTokenSender is Ownable {

    function drop(TokenERC20 token, address[] to, uint256[] value) onlyOwner public {
    for (uint256 i = 0; i < to.length; i++) {
      token.transfer(to[i], value[i]);
    }
  }
}