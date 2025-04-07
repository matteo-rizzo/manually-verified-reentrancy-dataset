/**
 *Submitted for verification at Etherscan.io on 2020-08-03
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

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
 * https://eips.ethereum.org/EIPS/eip-1820[ERC1820 registry standard] to let
 * token holders and recipients react to token movements by using setting implementers
 * for the associated interfaces in said registry. See {IERC1820Registry} and
 * {ERC1820Implementer}.
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
    bytes32 constant public DOMAIN_SALT = 0x1ab0cf5e94e46a869b93264d337a8ee094e220acc53dd0b56d94a74a865b664b;

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