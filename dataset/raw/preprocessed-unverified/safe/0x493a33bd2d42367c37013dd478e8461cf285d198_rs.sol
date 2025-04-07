pragma solidity 0.6.12;

/**
 * Foundation and Ecosystem
 * 2,300 Fully Locked with smart contract for 10 months
 * 
 */


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */




contract TokenLock is Ownable {
    
    // enter beneficiary checksum address here
    address public constant beneficiary = 0xF0977693118C812A86b16B13AB9bc455d382f70d;

    
    // enter unlock timestamp in seconds here
    uint public constant unlockTime = 1627776000;

    function isUnlocked() public view returns (bool) {
        return now > unlockTime;
    }
    
    function claim(address _tokenAddr, uint _amount) public onlyOwner {
        require(isUnlocked());
        token(_tokenAddr).transfer(beneficiary, _amount);
    }
}