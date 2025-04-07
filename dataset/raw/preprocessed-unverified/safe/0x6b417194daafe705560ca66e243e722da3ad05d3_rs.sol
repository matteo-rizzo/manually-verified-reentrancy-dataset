pragma solidity 0.4.21;





/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */







/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */







contract ERC20 {

    function totalSupply() public view returns (uint256);

    function balanceOf(address who) public view returns (uint256);

    function transfer(address to, uint256 value) public returns (bool);

    function allowance(address owner, address spender) public view returns (uint256);

    function transferFrom(address from, address to, uint256 value) public returns (bool);

    function approve(address spender, uint256 value) public returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

}





/**

 * @title Airdropper

 * @author C&B

 */

contract Airdropper is Ownable {

    using SafeMath for uint;



    ERC20 public token;

    uint public multiplier;



    /// @dev constructor

    /// @param tokenAddress Address of token contract

    function Airdropper(address tokenAddress, uint decimals) public {

        require(decimals <= 77);  // 10**77 < 2**256-1 < 10**78



        token = ERC20(tokenAddress);

        multiplier = 10**decimals;

    }



    /// @dev Airdrops some tokens to some accounts.

    /// @param dests List of account addresses.

    /// @param values List of token amounts.

    function airdrop(address source, address[] dests, uint[] values) public onlyOwner {

        require(dests.length == values.length);



        for (uint256 i = 0; i < dests.length; i++) {

            require(token.transferFrom(source, dests[i], values[i].mul(multiplier)));

        }

    }



    /// @dev Return all remaining tokens back to owner.

    function returnTokens() public onlyOwner {

        token.transfer(owner, token.balanceOf(this));

    }



    function destroy() public onlyOwner {

        selfdestruct(owner);

    }

}