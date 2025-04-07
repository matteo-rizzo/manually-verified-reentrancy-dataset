pragma solidity ^0.4.18;
/*
MIT License

Copyright (c) 2018 TrustToken

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */




contract Claimable is Ownable {
  address public pendingOwner;

  /**
   * @dev Modifier throws if called by any account other than the pendingOwner.
   */
  modifier onlyPendingOwner() {
    require(msg.sender == pendingOwner);
    _;
  }

  /**
   * @dev Allows the current owner to set the pendingOwner address.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) onlyOwner public {
    pendingOwner = newOwner;
  }

  /**
   * @dev Allows the pendingOwner address to finalize the transfer.
   */
  function claimOwnership() onlyPendingOwner public {
    OwnershipTransferred(owner, pendingOwner);
    owner = pendingOwner;
    pendingOwner = address(0);
  }
}

contract AllowanceSheet is Claimable {
    using SafeMath for uint256;

    mapping (address => mapping (address => uint256)) public allowanceOf;

    function addAllowance(address tokenHolder, address spender, uint256 value) public onlyOwner {
        allowanceOf[tokenHolder][spender] = allowanceOf[tokenHolder][spender].add(value);
    }

    function subAllowance(address tokenHolder, address spender, uint256 value) public onlyOwner {
        allowanceOf[tokenHolder][spender] = allowanceOf[tokenHolder][spender].sub(value);
    }

    function setAllowance(address tokenHolder, address spender, uint256 value) public onlyOwner {
        allowanceOf[tokenHolder][spender] = value;
    }
}