/**

 *Submitted for verification at Etherscan.io on 2018-09-10

*/



pragma solidity ^0.4.24;



// File: openzeppelin-solidity/contracts/ownership/Ownable.sol



/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */





// File: openzeppelin-solidity/contracts/token/ERC20/ERC20Basic.sol



/**

 * @title ERC20Basic

 * @dev Simpler version of ERC20 interface

 * See https://github.com/ethereum/EIPs/issues/179

 */

contract ERC20Basic {

  function totalSupply() public view returns (uint256);

  function balanceOf(address _who) public view returns (uint256);

  function transfer(address _to, uint256 _value) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

}



// File: openzeppelin-solidity/contracts/token/ERC20/ERC20.sol



/**

 * @title ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/20

 */

contract ERC20 is ERC20Basic {

  function allowance(address _owner, address _spender)

    public view returns (uint256);



  function transferFrom(address _from, address _to, uint256 _value)

    public returns (bool);



  function approve(address _spender, uint256 _value) public returns (bool);

  event Approval(

    address indexed owner,

    address indexed spender,

    uint256 value

  );

}



// File: openzeppelin-solidity/contracts/math/SafeMath.sol



/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */





// File: contracts/LuckboxAirdrop.sol



contract LuckboxAirdrop is Ownable {

  // good to have an event different from Transfer, since tracking will be easier

  event Airdrop(address indexed to, uint256 value);



  using SafeMath for uint;



  ERC20 LCK;

  address public lckTokenAddress;



  constructor(address tokenAddress)

  public {

    lckTokenAddress = tokenAddress;

    LCK = ERC20(lckTokenAddress);

  }



  function distribute(address[] recipients, uint amount)

  public onlyOwner

  returns(uint) {

    // want to have enough tokens, so that we don't die mid-way

    require(LCK.balanceOf(this) >= amount.mul(recipients.length));



    uint i = 0;

    while (i < recipients.length) {

      LCK.transfer(recipients[i], amount);

      emit Airdrop(recipients[i], amount);

      i += 1;

    }



    return(i);

  }



  function returnTokens()

  public onlyOwner {

    // return remaining tokens to owner

    LCK.transfer(owner, LCK.balanceOf(this));

  }

}