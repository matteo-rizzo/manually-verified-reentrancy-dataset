pragma solidity ^0.4.18;





/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */







/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */







contract  HandToken {

    function totalSupply() public constant returns (uint256 _totalSupply);

    function transfer(address _to, uint256 _value) public returns (bool success) ;

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);

    function balanceOf(address _owner) view public returns (uint256 balance) ;

}





/**

 * @title 空投合约

 */

contract AirDrop is Ownable {

  using SafeMath for uint256;

  // 对应的token

  HandToken public token; 

  address public tokenAddress;

  



  /**

   * 构造函数，设置token

   */

  function AirDrop (address addr)  public {

    token = HandToken(addr);

    require(token.totalSupply() > 0);

    tokenAddress = addr;

  }



  /**

   * fallback函数，接受eth充值

   */

  function () public payable {

  }



  /**

   * 空投

   * @param dstAddress 目标地址列表

   * @param value 分发的金额

   */

  function drop(address[] dstAddress, uint256 value) public onlyOwner {

    require(dstAddress.length <= 100);  // 不能多于100个地址

    for (uint256 i = 0; i < dstAddress.length; i++) {

    	token.transfer(dstAddress[i], value);

    }

  }

}