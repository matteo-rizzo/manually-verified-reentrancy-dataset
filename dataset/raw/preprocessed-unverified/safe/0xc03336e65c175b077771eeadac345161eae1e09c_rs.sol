/**

 *Submitted for verification at Etherscan.io on 2019-03-05

*/



pragma solidity 0.4.25;







contract ERC20 {

  function totalSupply() public view returns (uint256);

  function balanceOf(address who) public view returns (uint256);

  function transfer(address to, uint256 value) public returns (bool);

  function allowance(address owner, address spender)

    public view returns (uint256);



  function transferFrom(address from, address to, uint256 value)

    public returns (bool);



  function approve(address spender, uint256 value) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

  event Approval(

    address indexed owner,

    address indexed spender,

    uint256 value

  );

}











/**

 * @title TokenTimelock

 * @dev TokenTimelock is a token holder contract that will allow a

 * beneficiary to extract the tokens after a given release time

 */

contract CGCXMarchMassLock is Ownable {

  using SafeERC20 for ERC20;



  // ERC20 basic token contract being held

  ERC20 public token;



  // beneficiery -> amounts

  mapping (address => uint256) public lockups;



  // timestamp when token release is enabled

  uint256 public releaseTime;



  constructor(address _token, uint256 _releaseTime) public {

    // solium-disable-next-line security/no-block-members

    token = ERC20(_token);

    releaseTime = _releaseTime;

  }



  function release() public  {

    releaseFrom(msg.sender);

  }



  function releaseFrom(address _beneficiary) public {

    require(block.timestamp >= releaseTime);

    uint256 amount = lockups[_beneficiary];

    require(amount > 0);

    token.safeTransfer(_beneficiary, amount);

    lockups[_beneficiary] = 0;

  }



  function releaseFromMultiple(address[] _addresses) public {

    for (uint256 i = 0; i < _addresses.length; i++) {

      releaseFrom(_addresses[i]);

    }

  } 



  function submit(address[] _addresses, uint256[] _amounts) public onlyOwner {

    for (uint256 i = 0; i < _addresses.length; i++) {

      lockups[_addresses[i]] = _amounts[i];

    }

  }



}