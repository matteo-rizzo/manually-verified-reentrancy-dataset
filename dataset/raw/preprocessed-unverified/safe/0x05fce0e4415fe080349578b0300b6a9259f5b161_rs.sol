/**

 *Submitted for verification at Etherscan.io on 2018-12-15

*/



pragma solidity ^0.4.24;



/**

 * @title SafeMath

 * @dev Math operations with safety checks that revert on error

 */





contract Token {

    uint256 public totalSupply;

    function balanceOf(address _owner) constant public returns (uint256 balance);

    function transfer(address _to, uint256 _value) public returns (bool success);

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);

    function approve(address _spender, uint256 _value) public returns (bool success);

    function allowance(address _owner, address _spender) public constant returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

}





/*  ERC 20 token */

contract StandardToken is Token {



    function transfer(address _to, uint256 _value) public returns (bool success) {

      if (balances[msg.sender] >= _value && _value > 0) {

        balances[msg.sender] -= _value;

        balances[_to] += _value;

        emit Transfer(msg.sender, _to, _value);

        return true;

      } else {

        return false;

      }

    }



    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {

      if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {

        balances[_to] += _value;

        balances[_from] -= _value;

        allowed[_from][msg.sender] -= _value;

        emit Transfer(_from, _to, _value);

        return true;

      } else {

        return false;

      }

    }



    function balanceOf(address _owner) constant public returns (uint256 balance) {

        return balances[_owner];

    }



    function approve(address _spender, uint256 _value) public returns (bool success) {

        allowed[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);

        return true;

    }



    function allowance(address _owner, address _spender) constant public returns (uint256 remaining) {

      return allowed[_owner][_spender];

    }



    mapping (address => uint256) balances;

    mapping (address => mapping (address => uint256)) allowed;

}



contract PLAASlock is Ownable, StandardToken {

  using SafeMath for uint256;

  mapping (address => uint256) allocations;

  uint256 public  unlockDate = 1576418602; //Enter the Unlock Date(GNU epoch Timestamp)

  StandardToken public PLS;

  uint256 public constant exponent = 10**18; // 10**(number of decimals in the token)

  event TransferredToken(address indexed to, uint256 value);

  event FailedTransfer(address indexed to, uint256 value);

 

 

  



  constructor() public{

    PLS = StandardToken(0x8d9626315e8025b81c3bdb926db4c51dde237f52); // Enter Token Smart Contract Address

   

    allocations[0x09074cA496b17dAb0E1D359aa90cE7Ad5dbE3a93] = 12216000;  //The beneficiary address along with number of tokens to be locked.

    

  }

   function isActive() constant public returns (bool) {

    return (

        tokensAvailable() > 0 // Tokens must be available to send

    );

  }

   //below function can be used when you want to send every recipeint with different number of tokens

 

  

  

  function tokensAvailable() constant public returns (uint256) {

    return PLS.balanceOf(this);

  }

  

 

  

  function changeUnlockDate(uint256 _unlockDate) public onlyOwner{

      

      if(now> _unlockDate) revert();

      

       unlockDate = _unlockDate;

      

  }

  function unlock() external {

    if(now < unlockDate) revert();

    uint256 entitled = allocations[msg.sender];

    allocations[msg.sender] = 0;

    if(!StandardToken(PLS).transfer(msg.sender, entitled * exponent)) revert();

  }

 function destroy() onlyOwner public{

    uint256 balance = tokensAvailable();

    require (balance > 0);

    PLS.transfer(owner(), balance);

    selfdestruct(owner());

  }



}