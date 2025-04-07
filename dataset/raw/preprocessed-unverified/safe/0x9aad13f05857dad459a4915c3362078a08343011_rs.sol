/**
 *Submitted for verification at Etherscan.io on 2021-09-30
*/

pragma solidity >=0.8.0;

// SPDX-License-Identifier: BSD-3-Clause









contract TokenSwap_Contract is Ownable {
    using SafeMath for uint;
    using EnumerableSet for EnumerableSet.AddressSet;
    
    event Bridged(address holder, uint amount, uint newAmount);
    
    /* @dev
    Contract addresses
    */
    address public constant deposit = 0x481dE76d5ab31e28A33B0EA1c1063aDCb5B1769A;
    address public constant withdraw = 0x3adC55F60B62039AB2A024256cc8b97935E12524;
    
    /* @dev
    Exchange Rate
    */
    uint public rate = 1;
    
   
    
    /* @dev
    Enable / Disable the bridge
    */
    bool public enabled = true;
    
     /* @dev
    FUNCTIONS:
    */
    
    function changeState(bool _new) public onlyOwner returns(bool){
        enabled = _new;
        return true;
    }
    
    function swap(uint amount) public returns (bool){
        require(enabled , "Bridge is disabled");
        uint _toSend = amount.mul(rate);
        require(Token(deposit).transferFrom(msg.sender, address(this), amount), "Could not get deposit token.");
        require(Token(withdraw).transfer(msg.sender, _toSend), "Could not transfer withdraw token.");
        emit Bridged(msg.sender, amount, _toSend);
        return true;
    }
    
    
}