/**

 *Submitted for verification at Etherscan.io on 2018-11-13

*/



pragma solidity ^0.4.24;



/**

 * Changes by https://www.docademic.com/

 */



/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */





/**

 * Changes by https://www.docademic.com/

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







contract MTCMultiTransfer is Ownable, Destroyable {

    using SafeMath for uint256;



    event Dropped(uint256 transfers, uint256 amount);



    Token public token;

    uint256 public totalDropped;



    constructor(address _token) public{

        require(_token != address(0));

        token = Token(_token);

        totalDropped = 0;

    }



    function airdropTokens(address[] _recipients, uint256[] _balances) public

    onlyOwner {

        require(_recipients.length == _balances.length);



        uint airDropped = 0;

        for (uint256 i = 0; i < _recipients.length; i++)

        {

            require(token.transfer(_recipients[i], _balances[i]));

            airDropped = airDropped.add(_balances[i]);

        }



        totalDropped = totalDropped.add(airDropped);

        emit Dropped(_recipients.length, airDropped);

    }



    /**

     * @dev Get the remain MTC on the contract.

     */

    function Balance() view public returns (uint256) {

        return token.balanceOf(address(this));

    }



    /**

         * @notice Allows the owner to flush the eth.

         */

    function flushEth() public onlyOwner {

        owner.transfer(address(this).balance);

    }



    /**

     * @notice Allows the owner to destroy the contract and return the tokens to the owner.

     */

    function destroy() public onlyOwner {

        token.transfer(owner, token.balanceOf(this));

        selfdestruct(owner);

    }



}