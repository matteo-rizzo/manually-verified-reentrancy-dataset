/**
 *Submitted for verification at Etherscan.io on 2021-07-04
*/

//SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.1;



contract StarHolder
{
    struct TokenLock
    {
        address owner;
        uint256 amount;
        uint256 unlockDate;
    }
    
    IERC20 STARLightToken;
    
    constructor()
    {
        STARLightToken = IERC20(0x2bBF4f7B8Ab300Db01d45662769821Da6E400ef4);
    }
    
    mapping(address => TokenLock[]) public userToTokenLocks;
    
    /////////////////
    // Lock functions
    
    function lockToken(uint256 _amount, uint256 _lock) external
    {
        require(_lock > 0 && _lock < 4);
        
        STARLightToken.transferFrom(msg.sender, address(this), _amount);
        
        uint256 unlockDate;
        
        if(_lock == 1) unlockDate = block.timestamp + 31540000000; // 1 year lock
        if(_lock == 2) unlockDate = block.timestamp + 63070000000; // 2 year lock
        if(_lock == 3) unlockDate = block.timestamp + 94610000000; // 3 year lock
        
        userToTokenLocks[msg.sender].push(TokenLock(
            msg.sender,
            _amount,
            unlockDate
        ));
    }
    
    /////////////////////
    // Withdraw functions
    
    function withdrawLockedToken(uint256 _index) external
    {
        TokenLock memory lock = userToTokenLocks[msg.sender][_index];
        
        require(block.timestamp >= lock.unlockDate, "You are almost there, please HODL a little longer!! ");

        STARLightToken.transfer(msg.sender, lock.amount);
        
        delete userToTokenLocks[msg.sender][_index];
    }
}