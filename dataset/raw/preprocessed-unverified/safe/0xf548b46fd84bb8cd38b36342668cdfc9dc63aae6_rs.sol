/**
 *Submitted for verification at Etherscan.io on 2019-11-14
*/

pragma solidity 0.5.12;



contract FaucetPay {
    
    using SafeMath for uint;
    
    event Deposit(address _from, uint256 _amount);
    event Withdrawal(address _to, uint256 _amount);
    
    address payable private adminAddress;
     
    constructor() public { 
        adminAddress = msg.sender;
    }
    
    modifier _onlyOwner(){
        require(msg.sender == adminAddress);
          _;
    }

    function changeAdminAddress(address payable _newAddress) _onlyOwner public {
        adminAddress = _newAddress;
    }   

    function deposit() public payable returns(bool) {
        
        require(msg.value > 0);
        emit Deposit(msg.sender, msg.value);
        
        return true;
        
    }

    function withdraw(address payable _address, uint256 _amount) _onlyOwner public returns(bool) {
    
        _address.transfer(_amount);
        emit Withdrawal(msg.sender, _amount);
        
        return true;
        
    }
    
}