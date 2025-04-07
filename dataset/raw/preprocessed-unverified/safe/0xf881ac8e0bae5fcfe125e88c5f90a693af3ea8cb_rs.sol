/**
 *Submitted for verification at Etherscan.io on 2021-06-08
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.3;








contract ClearingHouse is Ownable {
    using SafeMath for uint256;

    mapping(address => bool) supportedTokens;
    mapping(address => uint256) nonces;

    // Double mapping as token address -> owner -> balance
    event TokensWrapped(address token, string receiver, uint256 amount);

    function deposit(address token, uint256 amount, string memory receiver) public {
        require(supportedTokens[token] == true, 'Unsupported token!');

        IERC20 tokenERC = IERC20(token);
        tokenERC.transferFrom(msg.sender, address(this), amount);

        emit TokensWrapped(token, receiver, amount);
    }

    function hashEthMsg(bytes32 _messageHash) public pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", _messageHash));
    }


    function hash(bytes memory x) public pure returns (bytes32) {
        return keccak256(x);
    }
    
    function encode(address token, uint256 amount, uint256 nonce, address sender) public pure returns (bytes memory) {
                return abi.encode(
                    token,
                    amount,
                    nonce,
                    sender
                );
    }
    
    function withdraw(address token, uint256 amount, uint256 nonce, uint8 v, bytes32 r, bytes32 s) public {
            bytes memory encoded = encode(token, amount, nonce, msg.sender);
            bytes32 hashed = hash(encoded);
            hashed = hashEthMsg(hashed);
            address recoveredAddress = ecrecover(hashed, v, r, s);
            require(recoveredAddress != address(0) && recoveredAddress == owner(), 'Invalid Signature!');
            require(nonces[msg.sender] < nonce, 'Invalid Nonce!');
            nonces[msg.sender] = nonce;
            IERC20 tokenERC = IERC20(token);
            tokenERC.transfer(msg.sender, amount);
    }

    // Admin functions for adding and removing tokens from the wrapped token system
    function addToken(address token) public onlyOwner {
        supportedTokens[token] = true;
    }

    function removeToken(address token) public onlyOwner {
        supportedTokens[token] = false;
    }
}