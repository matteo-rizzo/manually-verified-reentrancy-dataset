/**

 *Submitted for verification at Etherscan.io on 2018-09-17

*/



pragma solidity ^0.4.18;

   

  // Under copy right of Joint Education Limited Partnership

  //www.jointedu.net

  

  

  

  

 

  contract ERC20Interface {

      function totalSupply() public constant returns (uint);

      function balanceOf(address tokenOwner) public constant returns (uint balance);

      function allowance(address tokenOwner, address spender) public constant returns (uint remaining);

      function transfer(address to, uint tokens) public returns (bool success);

      function approve(address spender, uint tokens) public returns (bool success);

      function transferFrom(address from, address to, uint tokens) public returns (bool success);

  

      event Transfer(address indexed from, address indexed to, uint tokens);

      event Approval(address indexed tokenOwner, address indexed spender, uint tokens);

  }

  

  

  

  contract ApproveAndCallFallBack {

      function receiveApproval(address from, uint256 tokens, address token, bytes data) public;

  }

 

  

  

  

  

  

 

 contract BS_prototype is ERC20Interface, Owned {

     using SafeMath for uint;

 

     string public symbol= "BSPTT";

     string public  name = "BS_prototype";

     uint8 public decimals;

     uint public _totalSupply;

     uint256 public constant RATE = 10000;

 

     mapping(address => uint) balances;

     mapping(address => mapping(address => uint)) allowed;

 

 

    

     function BS_prototype() public {

         symbol = "BSPTT";

         name = "BS_prototype";

         decimals = 18;

         _totalSupply = 60000000 * 10**uint(decimals);

         balances[owner] = _totalSupply;

         Transfer(address(0), owner, _totalSupply);

     }

 

 

     

     function totalSupply() public constant returns (uint) {

         return _totalSupply  - balances[address(0)];

     }

 

 

     function balanceOf(address tokenOwner) public constant returns (uint balance) {

         return balances[tokenOwner];

     }

 

 

     function transfer(address to, uint tokens) public returns (bool success) {

         balances[msg.sender] = balances[msg.sender].sub(tokens);

         balances[to] = balances[to].add(tokens);

         Transfer(msg.sender, to, tokens);

         return true;

     }

 

 

    

     function approve(address spender, uint tokens) public returns (bool success) {

         allowed[msg.sender][spender] = tokens;

         Approval(msg.sender, spender, tokens);

         return true;

     }

 

 

     

     function transferFrom(address from, address to, uint tokens) public returns (bool success) {

         balances[from] = balances[from].sub(tokens);

         allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);

         balances[to] = balances[to].add(tokens);

         Transfer(from, to, tokens);

         return true;

     }

 

      

     function allowance(address tokenOwner, address spender) public constant returns (uint remaining) {

        return allowed[tokenOwner][spender];

     }

 

 

     

    function approveAndCall(address spender, uint tokens, bytes data) public returns (bool success) {

         allowed[msg.sender][spender] = tokens;

         Approval(msg.sender, spender, tokens);

        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, this, data);

         return true;

     }

 

      function() payable public{

         creatTokens();

         

     }



    function setPriceRate ( uint256 Price) public returns (uint256){

        require(msg.sender == owner);

        uint256 RATE = Price;

        

    }

    

         function creatTokens()payable public{

         require(msg.value>0 && balances[owner]>=1000000);

         uint256 tokens = msg.value.mul(RATE);

         balances[msg.sender]= balances[msg.sender].add(tokens);

         owner.transfer(msg.value);

         balances[owner] = balances[owner].sub(tokens);

         

     }



    

    

    

 

    

     function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {

         return ERC20Interface(tokenAddress).transfer(owner, tokens);

     }

 }