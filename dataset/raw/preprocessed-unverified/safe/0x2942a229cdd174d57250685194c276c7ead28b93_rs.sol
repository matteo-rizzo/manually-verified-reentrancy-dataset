/**

 *Submitted for verification at Etherscan.io on 2018-12-28

*/



pragma solidity 0.4.24;











 



/**

*

* safeMath库，防止溢出问题

*

*/





contract PAT is ERC20Interface, Owned{



  using SafeMath for uint256;

  string public symbol;

  string public name;

  uint8 public decimals;

  uint256 public totalSupply; 

  

  mapping(address => uint256) public balances;



  mapping (address => mapping(address => uint256)) public allowed; 



  constructor(string _symbol, string _name, uint8 _decimals, uint256 _initSupply) public {

    symbol = _symbol;

    name = _name;

    decimals = _decimals;

    totalSupply = _initSupply;

    balances[msg.sender] = _initSupply;



  }



  function symbol() public view returns (string) {

    return symbol;

  }



  function name() public view returns (string) {

    return name;

  }



  function decimals() public view returns (uint8) {

    return decimals;

  }



  function totalSupply() public view returns (uint256) {

    return totalSupply;

  }



  function balanceOf(address owner) public view returns (uint256) {

    return balances[owner];

  }





  /**

   * 返回owner账户可以转到spender账户的token数量

   *

   */

  function allowance(address owner, address spender) public view returns (uint256) {

    return allowed[owner][spender];

  } 



  /**

   * 

   * 向一个地址转账

   */

  function transfer(address to, uint256 value) public returns (bool) {

    require(to != address(0));

    balances[msg.sender] = balances[msg.sender].sub(value);

    balances[to] = balances[to].add(value);

    emit Transfer(msg.sender, to, value);

    return true;



  }



  /**

   *

   * 存在re-approve攻击漏洞，建议使用increaseAllowance方法

   */

  function approve(address spender, uint256 value) public returns (bool) {

    require(spender != address(0));

    allowed[msg.sender][spender] = value;

    emit Approval(msg.sender, spender, value);

    return true;

  }





  /**

   *

   * 从一个地址向另外一个地址转账

   */

  function transferFrom(address from, address to, uint256 value) public returns (bool) {

    require(to != address(0));

    balances[from] = balances[from].sub(value);

    balances[to] = balances[to].add(value);

    allowed[from][msg.sender] = allowed[from][msg.sender].sub(value);

    emit Transfer(from, to, value);

    return true;



  }



  /**

   *

   * 防止approve函数缺陷被利用, 增加spender账户对msg.sender账户token的可用量

   */

  function increaseAllowance(address spender, uint256 value) public returns (bool) {

    require(spender != address(0));

    allowed[msg.sender][spender] = allowed[msg.sender][spender].add(value);

    emit Approval(msg.sender, spender, allowed[msg.sender][spender]);

    return true;

  } 



  /**

   *

   * 防止approve函数缺陷被利用, 减少spender账户对msg.sender账户token的可用量

   */

  function decreaseAllowance(address spender, uint256 value) public returns (bool) {

    require(spender != address(0));

    allowed[msg.sender][spender] = allowed[msg.sender][spender].sub(value);

    emit Approval(msg.sender, spender, allowed[msg.sender][spender]);

    return true;

  }



}