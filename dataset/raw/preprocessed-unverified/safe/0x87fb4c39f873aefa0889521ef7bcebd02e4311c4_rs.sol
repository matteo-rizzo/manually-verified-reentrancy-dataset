pragma solidity ^0.4.21;



/**

 * Changes by https://www.docademic.com/

 */



/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */







/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */





contract Destroyable is Ownable{

    /**

     * @notice Allows to destroy the contract and return the tokens to the owner.

     */

    function destroy() public onlyOwner{

        selfdestruct(owner);

    }

}









contract TokenVault is Ownable, Destroyable {

    using SafeMath for uint256;



    Token public token;



    /**

     * @dev Constructor.

     * @param _token The token address

     */

    function TokenVault(address _token) public{

        require(_token != address(0));

        token = Token(_token);

    }



    /**

     * @dev Get the token balance of the contract.

     * @return _balance The token balance of this contract in wei

     */

    function Balance() view public returns (uint256 _balance) {

        return token.balanceOf(address(this));

    }



    /**

     * @dev Get the token balance of the contract.

     * @return _balance The token balance of this contract in ether

     */

    function BalanceEth() view public returns (uint256 _balance) {

        return token.balanceOf(address(this)) / 1 ether;

    }



    /**

     * @dev Allows the owner to flush the tokens of the contract.

     */

    function transferTokens(address _to, uint256 amount) public onlyOwner {

        token.transfer(_to, amount);

    }





    /**

     * @dev Allows the owner to flush the tokens of the contract.

     */

    function flushTokens() public onlyOwner {

        token.transfer(owner, token.balanceOf(address(this)));

    }



    /**

     * @dev Allows the owner to destroy the contract and return the tokens to the owner.

     */

    function destroy() public onlyOwner {

        token.transfer(owner, token.balanceOf(address(this)));

        selfdestruct(owner);

    }



}