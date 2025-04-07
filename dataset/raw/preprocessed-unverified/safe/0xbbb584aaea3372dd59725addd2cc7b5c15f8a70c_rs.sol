/**
 *Submitted for verification at Etherscan.io on 2019-07-13
*/

pragma solidity 0.4.24;
//Used to query the token info on https://bulksender.app


contract TokenQuery {
    constructor () public {
    }
    //return name/symbol/decimals/totalSupply/tokenBalance
    function queryTokenInfo(ERC20 token, bool _queryBalance, address _tokenOwner)  public view returns (string, string, uint, uint, uint) {
        if (_queryBalance){
            return (token.name(), token.symbol(),token.decimals(),token.totalSupply(),token.balanceOf(_tokenOwner));
         }
        return (token.name(), token.symbol(),token.decimals(),token.totalSupply(),0);
    }
}