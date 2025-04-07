/**

 *Submitted for verification at Etherscan.io on 2018-10-18

*/



pragma solidity ^0.4.24;



/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */





/**

 * @title ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/20

 */







/**

 * @title AzbitTokenInterface

 * @dev ERC20 Token Interface for Azbit project

 */

contract AzbitTokenInterface is IERC20 {



    function releaseDate() external view returns (uint256);



}





/**

 * @title AzbitAirdrop

 * @dev Airdrop Smart Contract of Azbit project

 */

contract AzbitAirdrop is Ownable {



    // ** PUBLIC STATE VARIABLES **



    // Azbit token

    AzbitTokenInterface public azbitToken;





    // ** CONSTRUCTOR **



    /**

    * @dev Constructor of AzbitAirdrop Contract

    * @param tokenAddress address of AzbitToken

    */

    constructor(

        address tokenAddress

    ) 

        public 

    {

        _setToken(tokenAddress);

    }





    // ** ONLY OWNER FUNCTIONS **



    /**

    * @dev Send tokens to beneficiary by owner

    * @param beneficiary The address for tokens withdrawal

    * @param amount The token amount

    */

    function sendTokens(

        address beneficiary,

        uint256 amount

    )

        external

        onlyOwner

    {

        _sendTokens(beneficiary, amount);

    }



    /**

    * @dev Send tokens to the array of beneficiaries  by owner

    * @param beneficiaries The array of addresses for tokens withdrawal

    * @param amounts The array of tokens amount

    */

    function sendTokensArray(

        address[] beneficiaries, 

        uint256[] amounts

    )

        external

        onlyOwner

    {

        require(beneficiaries.length == amounts.length, "array lengths have to be equal");

        require(beneficiaries.length > 0, "array lengths have to be greater than zero");



        for (uint256 i = 0; i < beneficiaries.length; i++) {

            _sendTokens(beneficiaries[i], amounts[i]);

        }

    }





    // ** PUBLIC VIEW FUNCTIONS **



    /**

    * @return total tokens of this contract.

    */

    function contractTokenBalance()

        public 

        view 

        returns(uint256) 

    {

        return azbitToken.balanceOf(this);

    }





    // ** PRIVATE HELPER FUNCTIONS **



    // Helper: Set the address of Azbit Token

    function _setToken(address tokenAddress) 

        internal 

    {

        azbitToken = AzbitTokenInterface(tokenAddress);

        require(contractTokenBalance() >= 0, "The token being added is not ERC20 token");

    }



    // Helper: send tokens to beneficiary

    function _sendTokens(

        address beneficiary, 

        uint256 amount

    )

        internal

    {

        require(beneficiary != address(0), "Address cannot be 0x0");

        require(amount > 0, "Amount cannot be zero");

        require(amount <= contractTokenBalance(), "not enough tokens on this contract");



        // transfer tokens

        require(azbitToken.transfer(beneficiary, amount), "tokens are not transferred");

    }

}