pragma solidity ^0.4.18;
 
//Never Mind :P
/* @dev The Ownable contract has an owner address, and provides basic authorization control
* functions, this simplifies the implementation of "user permissions".
*/



contract NVT {
    function transfer(address _to, uint _value) public returns (bool);
}

contract NVTDrop is Ownable{
  mapping(address => bool) getDropped;
  bool public halted = true;
  uint256 public amout = 1 * 10 ** 4;
  address public NVTAddr;
  NVT NVTFace;
  function setNVTface(address _nvt) public onlyOwner {
    NVTFace = NVT(_nvt);
  }
  function setAmout(uint _amout) onlyOwner {
    amout = _amout;
  }

  function () public payable{
    require(getDropped[msg.sender] == false);
    require(halted == false);
    getDropped[msg.sender] = true;
    NVTFace.transfer(msg.sender, amout);
  }



  function getStuckCoin (address _to, uint _amout) onlyOwner{
    _to.transfer(_amout);
  }
  function halt() onlyOwner{
    halted = true;
  }
  function unhalt() onlyOwner{
    halted = false;
  }
}