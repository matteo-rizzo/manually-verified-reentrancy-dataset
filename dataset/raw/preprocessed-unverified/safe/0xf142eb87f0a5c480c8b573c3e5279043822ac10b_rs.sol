/**
 *Submitted for verification at Etherscan.io on 2021-03-21
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */


/**
 * @dev Taraxa Claim Contract
 *
 * The Claim Contract is used to distribute tokens from public sales and bounties.
 *
 * The signature contains the address of the participant, the number of tokens and
 * a nonce.
 *
 * The contract uses ecrecover to verify that the signature was created by our
 * trusted account.
 *
 * If the signature is valid, the contract will transfer the tokens from a Taraxa
 * owned wallet to the participant.
 */
contract Claim {
    IERC20 token;

    address trustedAccountAddress;
    address walletAddress;

    mapping(bytes32 => uint256) claimed;

    /**
     * @dev Sets the values for {token}, {trustedAccountAddress} and
     * {walletAddress}.
     *
     * All three of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(
        address _tokenAddress,
        address _trustedAccountAddress,
        address _walletAddress
    ) {
        token = IERC20(_tokenAddress);

        trustedAccountAddress = _trustedAccountAddress;
        walletAddress = _walletAddress;
    }

    /**
     * @dev Returns the number of tokens that have been claimed by the
     * participant.
     *
     * Used by the Claim UI app.
     */
    function getClaimedAmount(
        address _address,
        uint256 _value,
        uint256 _nonce
    ) public view returns (uint256) {
        bytes32 hash = _hash(_address, _value, _nonce);
        return claimed[hash];
    }

    /**
     * @dev Transfers the tokens from a Taraxa owned wallet to the participant.
     *
     * Emits a {Claimed} event.
     */
    function claim(
        address _address,
        uint256 _value,
        uint256 _nonce,
        bytes memory _sig
    ) public {
        bytes32 hash = _hash(_address, _value, _nonce);

        require(ECDSA.recover(hash, _sig) == trustedAccountAddress, 'Claim: Invalid signature');
        require(claimed[hash] == 0, 'Claim: Already claimed');

        claimed[hash] = _value;
        token.transferFrom(walletAddress, _address, _value);

        emit Claimed(_address, _nonce, _value);
    }

    function _hash(
        address _address,
        uint256 _value,
        uint256 _nonce
    ) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(_address, _value, _nonce));
    }

    /**
     * @dev Emitted after the tokens have been transfered to the participant.
     */
    event Claimed(address indexed _address, uint256 indexed _nonce, uint256 _value);
}