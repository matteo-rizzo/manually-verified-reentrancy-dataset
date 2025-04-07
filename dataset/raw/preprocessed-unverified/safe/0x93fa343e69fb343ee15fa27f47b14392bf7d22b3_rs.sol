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
    using SafeMath for uint256;
    
    event LogTransfer(address indexed sender, address indexed receiver, uint256 amount);
    
    function batchTransferEtherWithSameAmount(address[] _addresses, uint _amoumt) public payable onlyOwner {
        require(_addresses.length != 0 && _amoumt != 0);
        uint checkAmount = msg.value.div(_addresses.length);
        require(_amoumt == checkAmount);
        
        for (uint i = 0; i < _addresses.length; i++) {
            require(_addresses[i] != address(0));
            _addresses[i].transfer(_amoumt);
            emit LogTransfer(msg.sender, _addresses[i], _amoumt);
        }
    }
    
    function batchTransferEther(address[] _addresses, uint[] _amoumts) public payable onlyOwner {
        require(_addresses.length == _amoumts.length || _addresses.length != 0);
        uint total = sumAmounts(_amoumts);
        require(total == msg.value);
        
        for (uint i = 0; i < _addresses.length; i++) {
            require(_addresses[i] != 0x0);
            _addresses[i].transfer(_amoumts[i]);
            emit LogTransfer(msg.sender, _addresses[i], _amoumts[i]);
        }
    }
    
    function sumAmounts(uint[] _amoumts) private pure returns (uint sumResult) {
        for (uint i = 0; i < _amoumts.length; i++) {
            require(_amoumts[i] > 0);
            sumResult = sumResult.add(_amoumts[i]);
        }
    }

}