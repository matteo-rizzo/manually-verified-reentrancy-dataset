pragma solidity 0.4.24;

/*

Capital Technologies & Research - Capital (CALL) & CapitalGAS (CALLG) - Team Vault

https://www.mycapitalco.in

*/



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



/**

 * @title ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/20

 */

contract ERC20 is ERC20Basic {

  function allowance(address owner, address spender)

    public view returns (uint256);



  function transferFrom(address from, address to, uint256 value)

    public returns (bool);



  function approve(address spender, uint256 value) public returns (bool);

  event Approval(

    address indexed owner,

    address indexed spender,

    uint256 value

  );

}



/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */





/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */





contract TeamVault is Ownable {

    using SafeMath for uint256;

    ERC20 public token_call;

    ERC20 public token_callg;

    event TeamWithdrawn(address indexed teamWallet, uint256 token_call, uint256 token_callg);

    constructor (ERC20 _token_call, ERC20 _token_callg) public {

        require(_token_call != address(0));

        require(_token_callg != address(0));

        token_call = _token_call;

        token_callg = _token_callg;

    }

    function () public payable {

    }

    function withdrawTeam(address teamWallet) public onlyOwner {

        require(teamWallet != address(0));

        uint call_balance = token_call.balanceOf(this);

        uint callg_balance = token_callg.balanceOf(this);

        token_call.transfer(teamWallet, call_balance);

        token_callg.transfer(teamWallet, callg_balance);

        emit TeamWithdrawn(teamWallet, call_balance, callg_balance);

    }

}