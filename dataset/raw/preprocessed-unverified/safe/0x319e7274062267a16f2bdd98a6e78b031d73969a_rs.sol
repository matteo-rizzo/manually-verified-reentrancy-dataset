/**
 *Submitted for verification at Etherscan.io on 2021-03-19
*/

// SPDX-License-Identifier: MIT License

pragma solidity 0.7.0;



contract PaymentSplitter {
    
    function payEth (address payable _beneficiary, address payable _admin, uint256 _originalAmount) public payable {
        _beneficiary.transfer(_originalAmount);
        _admin.transfer(msg.value - _originalAmount);
    }
    
    IERC20 public token;
    
    function payToken (address _beneficiary, address _admin, address _token, uint256 _originalAmount, uint256 _totalAmount) public payable {
        
        token = IERC20(_token);
        
        token.transferFrom(msg.sender, _beneficiary, _originalAmount);
        uint fees = _totalAmount - _originalAmount;
        token.transferFrom(msg.sender, _admin, fees);
    }
}