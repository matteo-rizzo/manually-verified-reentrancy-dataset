/**
 *Submitted for verification at Etherscan.io on 2021-05-06
*/

pragma solidity ^0.8.0;

// SPDX-License-Identifier: none






contract VNCERCBridge {
  address public admin;
  IToken public token;
  uint public nonce;
  address public feepayer;
  mapping(uint => bool) public processedNonces;

  enum Step { Burn, Mint }
  event Transfer(
    address from,
    address to,
    uint amount,
    uint date,
    uint nonce,
    Step indexed step
  );

event OwnershipTransferred(address indexed _from, address indexed _to);


  constructor(address _token) {
    admin = msg.sender;
    token = IToken(_token);
    
  }


   // transfer Ownership to other address
    function transferOwnership(address _newOwner) public {
        require(_newOwner != address(0x0));
        require(msg.sender == admin);
        emit OwnershipTransferred(admin,_newOwner);
        admin = _newOwner;
    }

 
  function mint(address to, uint amount, uint otherChainNonce) external {
    require(msg.sender == admin, 'only admin');
    require(processedNonces[otherChainNonce] == false, 'transfer already processed');
    processedNonces[otherChainNonce] = true;
    token.mint(to, amount);
    emit Transfer(
      msg.sender,
      to,
      amount,
      block.timestamp,
      otherChainNonce,
      Step.Mint
    );
  }
}