/**
 *Submitted for verification at Etherscan.io on 2019-10-21
*/

pragma solidity ^0.5.4;



contract WhitelistProxy is Ownable {
  address public whitelist;

  event Set(address whitelist);

  function set(address _whitelist) public onlyOwner {
    whitelist = _whitelist;
    emit Set(whitelist);
  }
}