/**

 *Submitted for verification at Etherscan.io on 2018-09-05

*/



pragma solidity 0.4.23;



/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */





contract ERC20Basic {

  function totalSupply() public view returns (uint256);

  function balanceOf(address who) public view returns (uint256);

  function transfer(address to, uint256 value) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

}



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



/**

 * @title SafeERC20

 * @dev Wrappers around ERC20 operations that throw on failure.

 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,

 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.

 */







contract AdvisorLockUP {

  using SafeERC20 for ERC20Basic;

  using SafeMath for uint256;



  // ERC20 basic token contract being held

  ERC20Basic public token;



  // beneficiary of tokens after they are released

  address public beneficiary;



  // timestamp when token release is enabled

  uint256 public releaseTime;

  

  uint256 public month = 30 days;



  uint256 public maxThreshold = 0;

  

  uint public total_amount = 190000000 * 10 ** uint256(18);

  

  uint public twenty_percent_of_amount = (total_amount.mul(2)).div(10);

  

  uint8 current_month = 1;

  

  bool internal token_set = false;



  constructor() public {

    beneficiary = 0xA6ae9438b17997d68c3CD5e4b5B51CEE85ceD030;

    releaseTime = now + 3 * month;

  }



    function setToken(address _token) public{

        require(!token_set);

        token_set = true;

        token = ERC20Basic(_token);

    }

  /**

   * @notice Transfers tokens held by timelock to beneficiary.

   */

  function release() public {

    require(now >= releaseTime);

    assert(current_month <= 5);

    

    uint diff = now - releaseTime;

    if (diff > month){

        releaseTime = now;

    }else{

        releaseTime = now.add(month.sub(diff));

    }

    

    current_month++;

    token.safeTransfer(beneficiary, twenty_percent_of_amount);

    

  }

}