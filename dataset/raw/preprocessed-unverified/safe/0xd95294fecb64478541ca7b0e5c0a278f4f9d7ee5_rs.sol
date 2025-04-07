pragma solidity ^0.4.18;


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */


contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}
/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}
contract Distribution is Ownable {
  function Distribution() public {}

  function distribute(address _tokenAddr, address _tokenSupplier, address[] _to, uint256[] _value) onlyOwner public returns (bool _success) {
    require(_to.length == _value.length);
    require(_to.length <= 150);
    for (uint8 i = 0; i < _to.length; i++) {
        assert((ERC20(_tokenAddr).transferFrom(_tokenSupplier, _to[i], _value[i])) == true);
    }
    return true;
  }
}