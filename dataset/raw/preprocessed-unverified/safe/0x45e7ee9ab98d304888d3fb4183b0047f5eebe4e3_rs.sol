/**

 *Submitted for verification at Etherscan.io on 2018-10-15

*/



pragma solidity ^0.4.23;



/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */







/** @title Restricted

 *  Exposes onlyMonetha modifier

 */

contract Restricted is Ownable {



    event MonethaAddressSet(

        address _address,

        bool _isMonethaAddress

    );



    mapping (address => bool) public isMonethaAddress;



    /**

     *  Restrict methods in such way, that they can be invoked only by monethaAddress account.

     */

    modifier onlyMonetha() {

        require(isMonethaAddress[msg.sender]);

        _;

    }



    /**

     *  Allows owner to set new monetha address

     */

    function setMonethaAddress(address _address, bool _isMonethaAddress) onlyOwner public {

        isMonethaAddress[_address] = _isMonethaAddress;



        MonethaAddressSet(_address, _isMonethaAddress);

    }

}





/**

 *  @title MonethaSupportedTokens

 *

 *  MonethaSupportedTokens stores all erc20 token supported by Monetha

 */

contract MonethaSupportedTokens is Restricted {

    

    string constant VERSION = "0.1";

    

    struct Token {

        bytes32 token_acronym;

        address token_address;

    }

    

    mapping (uint => Token) public tokens;



    uint public tokenId;

    

    address[] private allAddresses;

    bytes32[] private allAccronym;

    

    function addToken(bytes32 _tokenAcronym, address _tokenAddress)

        external onlyMonetha

    {

        require(_tokenAddress != address(0));



        tokens[++tokenId] = Token({

            token_acronym: bytes32(_tokenAcronym),

            token_address: _tokenAddress

        });

        allAddresses.push(_tokenAddress);

        allAccronym.push(bytes32(_tokenAcronym));

    }

    

    function deleteToken(uint _tokenId)

        external onlyMonetha

    {

        

        tokens[_tokenId].token_address = tokens[tokenId].token_address;

        tokens[_tokenId].token_acronym = tokens[tokenId].token_acronym;



        uint len = allAddresses.length;

        allAddresses[_tokenId-1] = allAddresses[len-1];

        allAccronym[_tokenId-1] = allAccronym[len-1];

        allAddresses.length--;

        allAccronym.length--;

        delete tokens[tokenId];

        tokenId--;

    }

    

    function getAll() external view returns (address[], bytes32[])

    {

        return (allAddresses, allAccronym);

    }

    

}