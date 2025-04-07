/**
 *Submitted for verification at Etherscan.io on 2021-02-26
*/

pragma solidity ^0.4.17;

/**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error
 */
 

 
contract ERC20Interface {
      function totalSupply() public  constant returns (uint totalSupply); //返回总金额
      function balanceOf(address _owner) public constant returns (uint balance);//返回地址账户金额总数
      function transfer(address _to, uint _value) public returns (bool success);//转账
      function transferFrom(address _from, address _to, uint _value) public returns (bool success);//授权之后才能转账
      function approve(address _spender, uint _value) public returns (bool success);//账户授权
      function allowance(address _owner, address _spender) public constant returns (uint remaining);//授权金额
      event Transfer(address indexed _from, address indexed _to, uint _value);
      event Approval(address indexed _owner, address indexed _spender, uint _value);
    }
 
 
 
/**
* @title Ownable
* @dev The Ownable contract has an owner address, and provides basic authorization control
* functions, this simplifies the implementation of "user permissions".
*/

 
contract USDToken is ERC20Interface,Ownable {
    string public symbol; //代币符号
    string public name;   //代币名称
    
    uint8 public decimal; //精确小数位
    uint public _totalSupply; //总的发行代币数
    
    mapping(address => uint) balances; //地址映射金额数
    mapping(address =>mapping(address =>uint)) allowed; //授权地址使用金额绑定
    
 
    //引入safemath 类库
    using SafeMath for uint;
    
    //构造函数
    //function LOPOToken() public{
    function USDToken() public{
        symbol = "USDT";
        name = "USD Token";
        decimal = 18;
        _totalSupply = 88543211000000000000000000;
        balances[msg.sender]=_totalSupply;//给发送者地址所有金额
        Transfer(address(0),msg.sender,_totalSupply );//转账事件
    }
 
    function totalSupply() public constant returns (uint totalSupply){
        return _totalSupply;
    }
    
    function balanceOf(address _owner) public constant returns (uint balance){
        return balances[_owner];
    }
 
    function transfer(address _to, uint _value) public returns (bool success){
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(msg.sender,_to,_value);
        return true;
    }
 
    function approve(address _spender, uint _value) public returns (bool success){
        allowed[msg.sender][_spender]=_value;
        Approval(msg.sender, _spender, _value);
        return true;
    }
 
    function allowance(address _owner, address _spender) public constant returns (uint remaining){
        return allowed[_owner][_spender];
    }
 
    function transferFrom(address _from, address _to, uint _value) public returns (bool success){
        allowed[_from][_to] = allowed[_from][_to].sub(_value);
        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(_from,_to,_value);
        return true;
    }
 
    //匿名函数回滚 禁止转账给me
    function() payable {
        revert();
    }

 
    //转账给任何合约
    function transferAnyERC20Token(address tokenaddress,uint tokens) public onlyOwner returns(bool success){
        ERC20Interface(tokenaddress).transfer(msg.sender,tokens);
    }
}