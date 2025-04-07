/**
 *Submitted for verification at Etherscan.io on 2019-08-09
*/

pragma solidity ^0.5.10;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */


/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */


/**
 * @dev Interface of the ERC777Token standard as defined in the EIP.
 *
 * This contract uses the
 * [ERC1820 registry standard](https://eips.ethereum.org/EIPS/eip-1820) to let
 * token holders and recipients react to token movements by using setting implementers
 * for the associated interfaces in said registry. See `IERC1820Registry` and
 * `ERC1820Implementer`.
 */


/**
 * This implemetation is based on ERC965 proposed implementaion, with addition of fees like in ERC865
 * It also uses EIP712 implementation from https://github.com/wighawag/eip712-origin
 * @dev pash7ka
 */
contract ChequeOperator is Ownable {
    using ECDSA for bytes32;

    string constant public DOMAIN_NAME = 'ChequeOperator';
    string constant public DOMAIN_VERSION = '1';
    bytes32 constant public DOMAIN_SALT = 0xbf7c844597cc901be5335f7c303eeef89b16c7a598875c2ff4d345bdcd7524b5;

    struct EIP712Domain {
        string  name;
        string  version;
        uint256 chainId;
        address verifyingContract;
        bytes32 salt;
    }
    struct Cheque {
        address token;
        address to;
        uint256 amount;
        bytes data;
        uint256 fee;
        uint256 nonce;
    }
    bytes32 constant EIP712DOMAIN_TYPEHASH = keccak256(abi.encodePacked(
        "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract,bytes32 salt)"
    ));
    bytes32 constant CHEQUE_TYPEHASH = keccak256(abi.encodePacked(
        "Cheque(address token,address to,uint256 amount,bytes data,uint256 fee,uint256 nonce)"
    ));
    bytes32 public DOMAIN_SEPARATOR;    

    mapping(address => mapping(uint256 => bool)) public usedNonces; // For simple sendByCheque

    constructor(uint256 _chainId) public {
        DOMAIN_SEPARATOR = hash(EIP712Domain({
            name: DOMAIN_NAME,
            version: DOMAIN_VERSION,
            chainId: _chainId,
            verifyingContract: address(this),
            salt: DOMAIN_SALT
        }));
    }

    function sendByCheque(address _token, address _to, uint256 _amount, bytes calldata _data, uint256 _fee, uint256 _nonce, bytes calldata _signature) external {
        require(_to != address(this));

        // Check if signature is valid and get signer's address
        address signer = signerOfCheque(Cheque({
            token: _token,
            to: _to, 
            amount: _amount, 
            data: _data, 
            fee: _fee,
            nonce: _nonce
        }), _signature);
        require(signer != address(0));

        // Mark this cheque as used
        require (!usedNonces[signer][_nonce]);
        usedNonces[signer][_nonce] = true;

        // Send tokens
        IERC777 token = IERC777(_token);
        token.operatorSend(signer, _to, _amount, _data, '');

        if(_fee > 0){
	        token.operatorSend(signer, owner(), _fee, '', '');
        }
    }
    function signerOfCheque(address _token, address _to, uint256 _amount, bytes calldata _data, uint256 _fee, uint256 _nonce, bytes calldata _signature) external view returns (address) {
        return signerOfCheque(Cheque({
            token: _token,
            to: _to, 
            amount: _amount, 
            data: _data, 
            fee: _fee,
            nonce: _nonce
        }), _signature);
    }

    function signerOfCheque(Cheque memory cheque, bytes memory signature) private view returns (address) {
        bytes32 digest = keccak256(abi.encodePacked(
            "\x19\x01",
            DOMAIN_SEPARATOR,
            hash(cheque)
        ));
        return digest.recover(signature);
    }

    function hash(EIP712Domain memory eip712Domain) private pure returns (bytes32) {
        return keccak256(abi.encode(
            EIP712DOMAIN_TYPEHASH,
            keccak256(bytes(eip712Domain.name)),
            keccak256(bytes(eip712Domain.version)),
            eip712Domain.chainId,
            eip712Domain.verifyingContract,
            eip712Domain.salt
        ));
    }
    function hash(Cheque memory cheque) private pure returns (bytes32) {
        return keccak256(abi.encode(
            CHEQUE_TYPEHASH,
            cheque.token,
            cheque.to,
            cheque.amount,
            keccak256(cheque.data),
            cheque.fee,
            cheque.nonce
        ));
    }
}