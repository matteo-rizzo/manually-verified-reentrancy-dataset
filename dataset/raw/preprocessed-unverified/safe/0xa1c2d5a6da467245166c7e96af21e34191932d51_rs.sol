pragma solidity ^0.4.23;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */



/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */



contract BatchTransferEther is Ownable {
    
    event LogTransfer(address indexed sender, address indexed receiver, uint256 amount);
    
    function batchTransferEther(address[] _addresses, uint _amoumt) public payable onlyOwner {
        require(_addresses.length != 0 && _amoumt != 0);
        uint checkAmount = msg.value / _addresses.length;
        require(_amoumt == checkAmount);
        
        for (uint i = 0; i < _addresses.length; i++) {
            require(_addresses[i] != address(0));
            _addresses[i].transfer(_amoumt);
            emit LogTransfer(msg.sender, _addresses[i], _amoumt);
        }
    }
}