/**

 *Submitted for verification at Etherscan.io on 2018-09-27

*/



pragma solidity ^0.4.24;



contract owned {

    address public owner;



    function owned() public {

        owner = msg.sender;

    }



    modifier onlyOwner {

        require(msg.sender == owner);

        _;

    }



    function transferOwnership(address newOwner) onlyOwner public {

        owner = newOwner;

    }

}



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

    function allowance(address owner, address spender) public view returns (uint256);

    function transferFrom(address from, address to, uint256 value) public returns (bool);

    function approve(address spender, uint256 value) public returns (bool);

    event Approval(address indexed owner, address indexed spender, uint256 value);

}



contract CLUBERC20  is ERC20 {

    function lockBalanceOf(address who) public view returns (uint256);

}



/**

 * @title SafeERC20

 * @dev Wrappers around ERC20 operations that throw on failure.

 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,

 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.

 */





/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */





/**

 * @title ClubTransferContract

 */

contract ClubTransferContract is owned {

    using SafeERC20 for CLUBERC20;

    using SafeMath for uint;



    string public constant name = "ClubTransferContract";



    CLUBERC20 public clubToken = CLUBERC20(0x045A464727871BE7731AD0028AAAA8127B90DBd5);



    function ClubTransferContract() public {}

    

    function getBalance() constant public returns(uint256) {

        return clubToken.balanceOf(this);

    }



    function transferClub(address _to, uint _amount) onlyOwner public {

        require (_to != 0x0);

        require(clubToken.balanceOf(this) >= _amount);

        

        clubToken.safeTransfer(_to, _amount);

    }

    

    function transferBack() onlyOwner public {

        clubToken.safeTransfer(owner, clubToken.balanceOf(this));

    }

}