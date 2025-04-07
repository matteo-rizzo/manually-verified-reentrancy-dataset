/**

 *Submitted for verification at Etherscan.io on 2019-01-19

*/



pragma solidity ^0.4.24;

/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */









contract DistributeTokens is Ownable{

  

  token tokenReward;

  address public addressOfTokenUsedAsReward;

  function setTokenReward(address _addr) public onlyOwner {

    tokenReward = token(_addr);

    addressOfTokenUsedAsReward = _addr;

  }



  function distributeVariable(address[] _addrs, uint[] _bals) public onlyOwner{

    for(uint i = 0; i < _addrs.length; ++i){

      tokenReward.transfer(_addrs[i],_bals[i]);

    }

  }



  function distributeFixed(address[] _addrs, uint _amoutToEach) public onlyOwner{

    for(uint i = 0; i < _addrs.length; ++i){

      tokenReward.transfer(_addrs[i],_amoutToEach);

    }

  }



  function withdrawTokens(uint _amount) public onlyOwner {

    tokenReward.transfer(owner,_amount);

  }

}