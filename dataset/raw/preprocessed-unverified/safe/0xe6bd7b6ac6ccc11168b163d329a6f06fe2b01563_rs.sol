pragma solidity 0.5.17;

   
/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */



/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */




contract SampleStaker is Ownable {
    using SafeMath for uint;
    
    event Received(address sender, address from, uint value, bytes extraData);
    
    function receiveApproval(address _from, uint256 _value, bytes memory _extraData) public {
        emit Received(msg.sender, _from, _value, _extraData);
    }
    
    function transferAnyERC20Token(address _tokenAddress, address _to, uint _amount) public onlyOwner {
        ERC20(_tokenAddress).transfer(_to, _amount);
    }
}