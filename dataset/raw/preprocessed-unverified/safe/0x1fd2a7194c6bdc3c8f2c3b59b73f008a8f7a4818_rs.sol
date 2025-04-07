/**

 *Submitted for verification at Etherscan.io on 2018-08-09

*/



pragma solidity ^0.4.24;







contract ERC20 {

    function totalSupply() public view returns (uint256);

    function balanceOf(address who) public view returns (uint256);

    function transfer(address to, uint256 value) public returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

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

 * @title SafeERC20

 * @dev Wrappers around ERC20 operations that throw on failure.

 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,

 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.

 */







/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */







/**

 * @title TokenTimelock

 * @dev TokenTimelock is a token holder contract that will allow a

 * beneficiary to extract the tokens after a given release time

 */

contract TokenTimelock is Ownable {

    using SafeERC20 for ERC20;

    using SafeMath for uint256;



    // ERC20 basic token contract being held

    ERC20 public token;



    mapping(address => uint256) public balances;

    mapping(address => uint256) public releaseTime;





    constructor(ERC20 _token) public {

        token = _token;

    }



    function addTokens(address _owner, uint256 _value, uint256 _releaseTime) onlyOwner external returns (bool) {

        require(_owner != address(0));

        token.safeTransferFrom(msg.sender, this, _value);



        balances[_owner] = balances[_owner].add(_value);

        releaseTime[_owner] = now + _releaseTime * 1 days;

    }





    function getTokens() external {

        require(balances[msg.sender] > 0);

        require(releaseTime[msg.sender] < now);



        token.safeTransfer(msg.sender, balances[msg.sender]);

        balances[msg.sender] = 0;

        releaseTime[msg.sender] = 0;

    }

}