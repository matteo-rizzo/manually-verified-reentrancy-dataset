/**

 *Submitted for verification at Etherscan.io on 2018-11-26

*/



pragma solidity ^0.4.24;



// File: node_modules/openzeppelin-solidity/contracts/math/SafeMath.sol



/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */





// File: contracts/IEntityStorage.sol







// File: contracts/Ownable.sol



/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */





// File: contracts/CBCreatureStorage.sol



/**

* @title CBCreatureStorage

* @dev Composable storage contract for recording attribute data and attached components for a CryptoBeasties card. 

* CryptoBeasties content and source code is Copyright (C) 2018 PlayStakes LLC, All rights reserved.

*/

contract CBCreatureStorage is Ownable, IEntityStorage { 

    using SafeMath for uint256;  



    struct Token {

        uint256 tokenId;

        uint256 attributes;

        uint256[] componentIds;

    }



    // Array with all Tokens, used for enumeration

    uint256[] internal allTokens;



    // Maps token ids to data

    mapping(uint256 => Token) internal tokens;



    event Stored(uint256 tokenId, uint256 attributes, uint256[] componentIds);

    event Removed(uint256 tokenId);



    /**

    * @dev Constructor function

    */

    constructor() public {

    }



    /**

    * @dev Returns whether the specified token exists

    * @param _tokenId uint256 ID of the token to query the existence of

    * @return whether the token exists

    */

    function exists(uint256 _tokenId) external view returns (bool) {

        return tokens[_tokenId].tokenId == _tokenId;

    }



    /**

    * @dev Bulk Load of Tokens

    * @param _tokenIds Array of tokenIds

    * @param _attributes Array of packed attributes value

    */

    function storeBulk(uint256[] _tokenIds, uint256[] _attributes) external onlyOwnerOrController {

        uint256[] memory _componentIds;

        for (uint index = 0; index < _tokenIds.length; index++) {

            allTokens.push(_tokenIds[index]);

            tokens[_tokenIds[index]] = Token(_tokenIds[index], _attributes[index], _componentIds);

            emit Stored(_tokenIds[index], _attributes[index], _componentIds);

        }

    }

    

    /**

    * @dev Create a new CryptoBeasties Token

    * @param _tokenId ID of the token

    * @param _attributes Packed attributes value

    * @param _componentIds Array of CryptoBeasties componentIds (i.e. PowerStones)

    */

    function store(uint256 _tokenId, uint256 _attributes, uint256[] _componentIds) external onlyOwnerOrController {

        allTokens.push(_tokenId);

        tokens[_tokenId] = Token(_tokenId, _attributes, _componentIds);

        emit Stored(_tokenId, _attributes, _componentIds);

    }



    /**

    * @dev Remove a CryptoBeasties Token from storage

    * @param _tokenId ID of the token

    */

    function remove(uint256 _tokenId) external onlyOwnerOrController {

        require(_tokenId > 0);

        require(this.exists(_tokenId));

        delete tokens[_tokenId];



        uint256 tokenIndex = 0;

        while (allTokens[tokenIndex] != _tokenId && tokenIndex < allTokens.length) {

            tokenIndex++;

        }



        // Reorg allTokens array

        uint256 lastTokenIndex = allTokens.length.sub(1);

        uint256 lastToken = allTokens[lastTokenIndex];



        allTokens[tokenIndex] = lastToken;

        allTokens[lastTokenIndex] = 0;



        allTokens.length--;

        emit Removed(_tokenId);

    }



    /**

    * @dev List all CryptoBeasties Tokens in storage

    */

    function list() external view returns (uint256[] tokenIds) {

        return allTokens;

    }



    /**

    * @dev Gets attributes and componentIds (i.e. PowerStones) for a CryptoBeastie

    * @param _tokenId uint256 for the given token

    */

    function getAttributes(uint256 _tokenId) external view returns (uint256 attrs, uint256[] compIds) {

        require(this.exists(_tokenId));

        return (tokens[_tokenId].attributes, tokens[_tokenId].componentIds);

    }



    /**

    * @dev Update CryptoBeasties attributes and Component Ids (i.e. PowerStones) CryptoBeastie

    * @param _tokenId uint256 ID of the token to update

    * @param _attributes Packed attributes value

    * @param _componentIds Array of CryptoBeasties componentIds (i.e. PowerStones)

    */

    function updateAttributes(uint256 _tokenId, uint256 _attributes, uint256[] _componentIds) external onlyOwnerOrController {

        require(this.exists(_tokenId));

        require(_attributes > 0);

        tokens[_tokenId].attributes = _attributes;

        tokens[_tokenId].componentIds = _componentIds;

        emit Stored(_tokenId, _attributes, _componentIds);

    }



    /**

    * @dev Get the total number of tokens in storage

    */

    function totalSupply() external view returns (uint256) {

        return allTokens.length;

    }



}