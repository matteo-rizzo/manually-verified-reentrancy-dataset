/**
 *Submitted for verification at Etherscan.io on 2020-10-17
*/

pragma solidity 0.6.12;

/**
 * Staking Pool
 * 6,300 PAYOU Fully Locked with smart contract for 15 Days
 * 
 */


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */




contract TokenLock is Ownable {
    
    // enter beneficiary checksum address here
    address public constant beneficiary = 0xCa868B9a83fF6D5a3581B7245faF4e67b35c9542;

    
    // enter unlock timestamp in seconds here
    uint public constant unlockTime = 1604275199;

    function isUnlocked() public view returns (bool) {
        return now > unlockTime;
    }
    
    function claim(address _tokenAddr, uint _amount) public onlyOwner {
        require(isUnlocked());
        token(_tokenAddr).transfer(beneficiary, _amount);
    }
}