/**

 *Submitted for verification at Etherscan.io on 2018-08-29

*/



pragma solidity ^0.4.24;



/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */







/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */







/**

 * @title ERC20Basic

 * @dev Simpler version of ERC20 interface

 * See https://github.com/ethereum/EIPs/issues/179

 */

contract ERC20Basic {

    function totalSupply() public view returns (uint256);

    function balanceOf(address who) public view returns (uint256);

    function transfer(address to, uint256 value) public returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

}





/**

 * @title SafeERC20

 * @dev Wrappers around ERC20 operations that throw on failure.

 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,

 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.

 */





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





contract BulDex is Ownable {

    using SafeERC20 for ERC20;



    mapping(address => bool) users;



    ERC20 public promoToken;

    ERC20 public bullToken;



    uint public minVal = 365000000000000000000;

    uint public bullAmount = 3140000000000000000;



    constructor(address _promoToken, address _bullToken) public {

        promoToken = ERC20(_promoToken);

        bullToken = ERC20(_bullToken);

    }



    function exchange(address _user, uint _val) public {

        require(!users[_user]);

        require(_val >= minVal);

        users[_user] = true;

        bullToken.safeTransfer(_user, bullAmount);

    }









    /// @notice This method can be used by the owner to extract mistakenly

    ///  sent tokens to this contract.

    /// @param _token The address of the token contract that you want to recover

    ///  set to 0 in case you want to extract ether.

    function claimTokens(address _token) external onlyOwner {

        if (_token == 0x0) {

            owner.transfer(address(this).balance);

            return;

        }



        ERC20 token = ERC20(_token);

        uint balance = token.balanceOf(this);

        token.transfer(owner, balance);

    }





    function setBullAmount(uint _amount) onlyOwner public {

        bullAmount = _amount;

    }

}