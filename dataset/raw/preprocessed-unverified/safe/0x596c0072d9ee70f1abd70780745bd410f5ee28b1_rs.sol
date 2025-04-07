/**

 *Submitted for verification at Etherscan.io on 2019-02-04

*/



pragma solidity ^0.5.2;



// File: openzeppelin-solidity/contracts/ownership/Ownable.sol



/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */





// File: @daostack/arc/contracts/test/ExternalTokenLockerMock.sol



contract ExternalTokenLockerMock is Ownable {



    // user => amount

    mapping (address => uint) public lockedTokenBalances;



    function lock(uint256 _amount, address _beneficiary) public onlyOwner {

        lockedTokenBalances[_beneficiary] = _amount;

    }

}