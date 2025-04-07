/**
 *Submitted for verification at Etherscan.io on 2021-04-13
*/

pragma solidity 0.8.1;


/**
 * @dev https://eips.ethereum.org/EIPS/eip-1167[EIP 1167] is a standard for
 * deploying minimal proxy contracts, also known as "clones".
 *
 * > To simply and cheaply clone contract functionality in an immutable way, this standard specifies
 * > a minimal bytecode implementation that delegates all calls to a known, fixed address.
 *
 * The library includes functions to deploy a proxy using either `create` (traditional deployment) or `create2`
 * (salted deterministic deployment). It also includes functions to predict the addresses of clones deployed using the
 * deterministic method.
 *
 * _Available since v3.4._
 */






contract TokenFactory {

    address public tokenTemplate;

    constructor(address _tokenTemplate) {
        tokenTemplate = _tokenTemplate;
    }

    event CreateToken(string name, string symbol, uint8 decimals, address owner, bool whitelistState, address contractAddress);

    function createToken(string memory name, string memory symbol, uint8 decimals, address owner, bool whitelistState) public returns (address) {
        address tokenAddress = Clones.clone(tokenTemplate);
        ITokenInit(tokenAddress).initialize(name, symbol, decimals, owner, whitelistState);
        emit CreateToken(name, symbol, decimals, owner, whitelistState, tokenAddress);
        return tokenAddress; 
    }
}