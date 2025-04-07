pragma solidity ^0.4.18;

// ----------------------------------------------------------------------------
// Owned - Ownership model with 2 phase transfers
// Enuma Blockchain Platform
//
// Copyright (c) 2017 Enuma Technologies.
// https://www.enuma.io/
// ----------------------------------------------------------------------------


// Implements a simple ownership model with 2-phase transfer.


// ----------------------------------------------------------------------------
// Math - General Math Utility Library
// Enuma Blockchain Platform
//
// Copyright (c) 2017 Enuma Technologies.
// https://www.enuma.io/
// ----------------------------------------------------------------------------




// ----------------------------------------------------------------------------
// ERC20Interface - Standard ERC20 Interface Definition
// Enuma Blockchain Platform
//
// Copyright (c) 2017 Enuma Technologies.
// https://www.enuma.io/
// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
// Based on the final ERC20 specification at:
// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
// ----------------------------------------------------------------------------
contract ERC20Interface {

   event Transfer(address indexed _from, address indexed _to, uint256 _value);
   event Approval(address indexed _owner, address indexed _spender, uint256 _value);

   function name() public view returns (string);
   function symbol() public view returns (string);
   function decimals() public view returns (uint8);
   function totalSupply() public view returns (uint256);

   function balanceOf(address _owner) public view returns (uint256 balance);
   function allowance(address _owner, address _spender) public view returns (uint256 remaining);

   function transfer(address _to, uint256 _value) public returns (bool success);
   function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
   function approve(address _spender, uint256 _value) public returns (bool success);
}

// ----------------------------------------------------------------------------
// ERC20Batch - Contract to help batching ERC20 operations.
// Enuma Blockchain Platform
//
// Copyright (c) 2017 Enuma Technologies.
// https://www.enuma.io/
// ----------------------------------------------------------------------------


contract ERC20Batch is Owned {

   using Math for uint256;

   ERC20Interface public token;
   address public tokenHolder;


   event TransferFromBatchCompleted(uint256 _batchSize);


   function ERC20Batch(address _token, address _tokenHolder) public
      Owned()
   {
      require(_token != address(0));
      require(_tokenHolder != address(0));

      token = ERC20Interface(_token);
      tokenHolder = _tokenHolder;
   }


   function transferFromBatch(address[] _toArray, uint256[] _valueArray) public onlyOwner returns (bool success) {
      require(_toArray.length == _valueArray.length);
      require(_toArray.length > 0);

      for (uint256 i = 0; i < _toArray.length; i++) {
         require(token.transferFrom(tokenHolder, _toArray[i], _valueArray[i]));
      }

      TransferFromBatchCompleted(_toArray.length);

      return true;
   }
}