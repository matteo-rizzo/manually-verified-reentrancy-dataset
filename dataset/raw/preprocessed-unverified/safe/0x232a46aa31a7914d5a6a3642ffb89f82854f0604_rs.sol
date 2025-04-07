/**

 *Submitted for verification at Etherscan.io on 2018-10-25

*/



pragma solidity ^0.4.25;



// File: node_modules\openzeppelin-solidity\contracts\ownership\Ownable.sol



/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */





// File: contracts\GPAAirDrop.sol



/**

 * @title GPA Token AirDrop

 * @dev The main GPA AirDrop contract

 */

contract GPAAirDrop is Ownable {

  using SafeMath for uint256;



  uint8 public decimals;



  event AirdropTransferCompleted(uint256 _value);

  event ChangeDecimals(uint8 _decimals);

  event Fallback(address indexed _from, uint256 _value);



  constructor() public {

    decimals = 18;

  }



  function () public payable {

    emit Fallback(msg.sender, msg.value);

    //revert();

  }



  /*

  * @dev Fix for the ERC20 short address attack

  */

  modifier onlyPayloadSize(uint size) {

   assert(msg.data.length >= size + 4);

   _;

  }



  function setDecimals(uint8 _decimals) public onlyOwner {

    decimals = _decimals;

    emit ChangeDecimals(decimals);

  }



  function _allowanceRemain(ERC20Interface _targetToken) internal view returns (uint256) {

    return _targetToken.allowance(owner, this).div(10 ** uint256(decimals)) ;

  }



  function execAirDrop(address _tokenAddr, address[] addrList, uint256[] valList) public onlyOwner onlyPayloadSize(2 * 32) returns (uint256) {

    uint256 i = 0;

    uint256 allowanceValue = _allowanceRemain(ERC20Interface(_tokenAddr));



    while (i < addrList.length) {

      require(allowanceValue >= valList[i]);



      require(ERC20Interface(_tokenAddr).transferFrom(msg.sender, addrList[i], valList[i].mul(10 ** uint256(decimals))));



      allowanceValue.sub(valList[i]);

      i++;

    }



    emit AirdropTransferCompleted(addrList.length);

    return i;

  }



}



contract ERC20Interface {

    function totalSupply() public constant returns (uint256);

    function balanceOf(address tokenOwner) public constant returns (uint256 balance);

    function allowance(address tokenOwner, address spender) public constant returns (uint256 remaining);

    function transfer(address to, uint256 tokens) public returns (bool success);

    function approve(address spender, uint256 tokens) public returns (bool success);

    function transferFrom(address from, address to, uint256 tokens) public returns (bool success);



    event Transfer(address indexed from, address indexed to, uint256 tokens);

    event Approval(address indexed tokenOwner, address indexed spender, uint256 tokens);

}



/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */

