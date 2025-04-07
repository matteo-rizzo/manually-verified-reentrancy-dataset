/**

 *Submitted for verification at Etherscan.io on 2019-03-14

*/



pragma solidity ^0.4.23;















contract BCBtokens is ERC20,ERC223,Owned{

 using SafeMath for uint;

 string public symbol;

 string public name;

 uint8 public decimals;

 uint256 _totalSupply;

 mapping(address=>uint) balances;

 mapping(address=>mapping(address=>uint)) allowed;

 constructor() public{

     symbol = "BCB";

     name="BCB";

     decimals=18;

     _totalSupply=99000000*10**18;

     balances[owner] = _totalSupply;

     emit Transfer(address(0),owner,_totalSupply);

  }

  function Iscontract(address _addr) public view returns(bool success){

      uint length;

      assembly{

          length:=extcodesize(_addr)

      }

      return (length>0);

  }

   

  function totalSupply() public view returns(uint){

      return _totalSupply.sub(balances[address(0)]);

  }

  function banlanceOf(address tokenOwner) public returns(uint balance){

      return balances[tokenOwner];

  }

  function transfer(address to,uint tokens) public returns(bool success){

      balances[msg.sender] = balances[msg.sender].sub(tokens);

      balances[to] = balances[to].add(tokens);

      emit Transfer(msg.sender,to,tokens);

      return true;

  }

  function transfer(address to ,uint value,bytes data) public returns(bool ok){

      if(Iscontract(to)){

          balances[msg.sender]=balances[msg.sender].sub(value);

          balances[to] = balances[to].add(value);

          ContractRceiver c = ContractRceiver(to);

          c.tokenFallBack(msg.sender,value,data);

          emit Transfer(msg.sender,to,value,data);

          return true;

      }

  }

  function approve(address spender,uint tokens) public returns(bool success){

      allowed[msg.sender][spender]=tokens;

      emit Approval(msg.sender,spender,tokens);

      return true;

  }

  function transferFrom(address from,address to,uint tokens) public returns(bool success){

      balances[from] = balances[from].sub(tokens);

      allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);

      balances[to] = balances[to].add(tokens);

      return true;

  }

  function allowance(address tokenOwner,address spender) public returns(uint remaining){

      return allowed[tokenOwner][spender];

  }

     function approveAndCall(address spender,uint tokens,bytes data) public returns(bool success){

    allowed[msg.sender][spender]=tokens;

    emit Approval(msg.sender,spender,tokens);

    ApproveAndCallFallBack(spender).receiverApproval(msg.sender,tokens,this,data);

    return true;

  }

  function () public payable{

    revert();

  }

}