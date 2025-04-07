pragma solidity 0.5.4;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */


/** 
 * @title i5Network
 * @dev Implements voting process along with vote delegation
 */
contract i5Network {
  using SafeMath for uint256;
  event Transfer(address indexed from, address indexed to, uint256 value);
   
    function register(address payable wallet) public payable returns (bool){
        wallet.transfer(msg.value);
        emit Transfer(msg.sender, wallet, msg.value);
        return true;
    }
}