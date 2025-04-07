pragma solidity ^0.4.18;



// File: zeppelin-solidity/contracts/math/SafeMath.sol



/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */





// File: zeppelin-solidity/contracts/ownership/Ownable.sol



/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */





// File: zeppelin-solidity/contracts/token/ERC20/ERC20Basic.sol



/**

 * @title ERC20Basic

 * @dev Simpler version of ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/179

 */

contract ERC20Basic {

  function totalSupply() public view returns (uint256);

  function balanceOf(address who) public view returns (uint256);

  function transfer(address to, uint256 value) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

}



// File: zeppelin-solidity/contracts/token/ERC20/ERC20.sol



/**

 * @title ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/20

 */

contract ERC20 is ERC20Basic {

  function allowance(address owner, address spender) public view returns (uint256);

  function transferFrom(address from, address to, uint256 value) public returns (bool);

  function approve(address spender, uint256 value) public returns (bool);

  event Approval(address indexed owner, address indexed spender, uint256 value);

}



// File: contracts/TokenDistribution.sol



contract TokenDistribution is Ownable {

  using SafeMath for uint256;



  ERC20 public token;



  address public wallet;



  function TokenDistribution(

    ERC20 _token,

    address _wallet) public

  {

    require(_token != address(0));

    require(_wallet != address(0));

    token = _token;

    wallet = _wallet;

  }



  function sendToken(address[] _beneficiaries, uint256 _amount) external onlyOwner {

    for (uint256 i = 0; i < _beneficiaries.length; i++) {

      require(token.transferFrom(wallet, _beneficiaries[i], _amount));

    }

  }

}