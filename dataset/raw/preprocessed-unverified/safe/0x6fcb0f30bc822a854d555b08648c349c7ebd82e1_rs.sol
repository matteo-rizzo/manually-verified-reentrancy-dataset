/**
 *Submitted for verification at Etherscan.io on 2020-10-08
*/

pragma solidity ^0.4.26;

contract AdoreCoin{
    
    /*=====================================
    =           EVENTS                    =
    =====================================*/
    
    event Approval(
        address indexed tokenOwner, 
        address indexed spender,
        uint tokens
    );
    
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 tokens
    );
    
    /*=====================================
    =            CONFIGURABLES            =
    =====================================*/
    string public name = "Adore Coin";
    string public symbol = "ADR";
    uint256 constant public totalSupply_ = 51000000;
    uint256 constant public decimals = 0;
    
    mapping(address => uint256) balances;
    mapping(address => mapping (address => uint256)) allowed;
    
    /*=====================================
    =            FUNCTIONS                =
    =====================================*/
    constructor() public
    {
        balances[msg.sender] = totalSupply_;
    }
    
    function totalSupply() public pure returns (uint256) {
      return totalSupply_;
    }
    
    function balanceOf(address tokenOwner) public view returns (uint) {
      return balances[tokenOwner];
    }

    function transfer(address receiver,uint numTokens) public returns (bool) {
      require(numTokens <= balances[msg.sender]);
      balances[msg.sender] = SafeMath.sub(balances[msg.sender],numTokens);
      balances[receiver] = SafeMath.add(balances[receiver],numTokens);
      emit Transfer(msg.sender, receiver, numTokens);
      return true;
    }
    
    
    function approve(address delegate,
                uint numTokens) public returns (bool) {
      allowed[msg.sender][delegate] = numTokens;
      emit Approval(msg.sender, delegate, numTokens);
      return true;
    }
    
    function allowance(address owner,
                  address delegate) public view returns (uint) {
      return allowed[owner][delegate];
    }
    
    function transferFrom(address owner, address buyer,
                     uint numTokens) public returns (bool) {
      require(numTokens <= balances[owner]);
      require(numTokens <= allowed[owner][msg.sender]);
      balances[owner] = SafeMath.sub(balances[owner],numTokens);
      allowed[owner][msg.sender] =SafeMath.sub(allowed[owner][msg.sender],numTokens);
      balances[buyer] = balances[buyer] + numTokens;
      emit Transfer(owner, buyer, numTokens);
      return true;
    }
}

