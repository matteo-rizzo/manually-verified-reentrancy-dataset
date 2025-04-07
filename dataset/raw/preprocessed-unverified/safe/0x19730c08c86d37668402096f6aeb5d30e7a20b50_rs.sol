/**
 *Submitted for verification at Etherscan.io on 2019-10-13
*/

pragma solidity 0.5.12;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */




contract LockTokens is Ownable {
    
    address public constant beneficiaryAddr = 0xF4A2edbB5ffC9f0859005531Bd9CCeE73E3E3079;

    uint public constant unlockTime = 1580947200;

    function canTransfer() public view returns (bool) {
        return now > unlockTime;
    }
    
    function claimTokens(address _tokenAddr, uint _amount) public onlyOwner {
        require(canTransfer());
        token(_tokenAddr).transfer(beneficiaryAddr, _amount);
    }
}