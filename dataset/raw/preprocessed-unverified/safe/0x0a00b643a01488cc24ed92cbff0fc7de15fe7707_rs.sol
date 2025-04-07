/**

 *Submitted for verification at Etherscan.io on 2018-12-12

*/



pragma solidity ^0.4.25;

pragma experimental ABIEncoderV2;



contract LibSignatureValidation {



  using LibBytes for bytes;



  function isValidSignature(bytes32 hash, address signerAddress, bytes memory signature) internal pure returns (bool) {

    require(signature.length == 65, "LENGTH_65_REQUIRED");

    uint8 v = uint8(signature[64]);

    bytes32 r = signature.readBytes32(0);

    bytes32 s = signature.readBytes32(32);

    address recovered = ecrecover(hash, v, r, s);

    return signerAddress == recovered;

  }

}



contract LibTransferRequest {



  // EIP191 header for EIP712 prefix

  string constant internal EIP191_HEADER = "\x19\x01";

  // EIP712 Domain Name value

  string constant internal EIP712_DOMAIN_NAME = "Dola Core";

  // EIP712 Domain Version value

  string constant internal EIP712_DOMAIN_VERSION = "1";

  // Hash of the EIP712 Domain Separator Schema

  bytes32 public constant EIP712_DOMAIN_SEPARATOR_SCHEMA_HASH = keccak256(abi.encodePacked(

    "EIP712Domain(",

    "string name,",

    "string version,",

    "address verifyingContract",

    ")"

  ));



  // Hash of the EIP712 Domain Separator data

  bytes32 public EIP712_DOMAIN_HASH;



  bytes32 constant internal EIP712_TRANSFER_REQUEST_TYPE_HASH = keccak256(abi.encodePacked(

    "TransferRequest(",

    "address senderAddress,",

    "address receiverAddress,",

    "uint256 value,",

    "address relayerAddress,",

    "uint256 relayerFee,",

    "uint256 salt,",

    ")"

  ));



  struct TransferRequest {

    address senderAddress;

    address receiverAddress;

    uint256 value;

    address relayerAddress;

    uint256 relayerFee;

    uint256 salt;

  }



  constructor() public {

    EIP712_DOMAIN_HASH = keccak256(abi.encode(

        EIP712_DOMAIN_SEPARATOR_SCHEMA_HASH,

        keccak256(bytes(EIP712_DOMAIN_NAME)),

        keccak256(bytes(EIP712_DOMAIN_VERSION)),

        address(this)

      ));

  }



  function hashTransferRequest(TransferRequest memory request) internal view returns (bytes32) {

    bytes32 typeHash = EIP712_TRANSFER_REQUEST_TYPE_HASH;

    bytes32 hashStruct;



    // assembly shorthand for:

    // bytes32 hashStruct = keccak256(abi.encode(

    //    EIP712_TRANSFER_REQUEST_TYPE_HASH,

    //    request.senderAddress,

    //    request.receiverAddress,

    //    request.value,

    //    request.relayerAddress,

    //    request.relayerFee,

    //    request.salt));

    assembly {

      // Back up select memory

      let temp1 := mload(sub(request, 32))



      mstore(sub(request, 32), typeHash)

      hashStruct := keccak256(sub(request, 32), 224)



      mstore(sub(request, 32), temp1)

    }

    return keccak256(abi.encodePacked(EIP191_HEADER, EIP712_DOMAIN_HASH, hashStruct));

  }







}



contract DolaCore is LibTransferRequest, LibSignatureValidation {



  using LibBytes for bytes;



  address public TOKEN_ADDRESS;

  mapping (address => mapping (address => uint256)) public requestEpoch;



  event TransferRequestFilled(address indexed from, address indexed to);



  constructor (address _tokenAddress) public LibTransferRequest() {

    TOKEN_ADDRESS = _tokenAddress;

  }



  function executeTransfer(TransferRequest memory request, bytes memory signature) public {

    // make sure the request hasn't been sent already

    require(requestEpoch[request.senderAddress][request.relayerAddress] <= request.salt, "REQUEST_INVALID");

    // Validate the sender is allowed to execute this transfer

    require(request.relayerAddress == msg.sender, "REQUEST_INVALID");

    // Validate the sender's signature

    bytes32 requestHash = hashTransferRequest(request);

    require(isValidSignature(requestHash, request.senderAddress, signature), "INVALID_REQUEST_SIGNATURE");



    address tokenAddress = TOKEN_ADDRESS;

    assembly {

      mstore(32, 0x23b872dd00000000000000000000000000000000000000000000000000000000)

      calldatacopy(36, 4, 96)

      let success := call(

        gas,            // forward all gas

        tokenAddress,   // call address of token contract

        0,              // don't send any ETH

        32,              // pointer to start of input

        100,            // length of input

        0,            // write output to far position

        32              // output size should be 32 bytes

      )

      success := and(success, or(

          iszero(returndatasize),

          and(

            eq(returndatasize, 32),

            gt(mload(0), 0)

          )

        ))

      if iszero(success) {

        mstore(0, 0x08c379a000000000000000000000000000000000000000000000000000000000)

        mstore(32, 0x0000002000000000000000000000000000000000000000000000000000000000)

        mstore(64, 0x0000000f5452414e534645525f4641494c454400000000000000000000000000)

        mstore(96, 0)

        revert(0, 100)

      }

      calldatacopy(68, 100, 64)

      success := call(

        gas,            // forward all gas

        tokenAddress,   // call address of token contract

        0,              // don't send any ETH

        32,              // pointer to start of input

        100,            // length of input

        0,            // write output over input

        32              // output size should be 32 bytes

      )

      success := and(success, or(

          iszero(returndatasize),

          and(

            eq(returndatasize, 32),

            gt(mload(0), 0)

          )

        ))

      if iszero(success) {

        mstore(0, 0x08c379a000000000000000000000000000000000000000000000000000000000)

        mstore(32, 0x0000002000000000000000000000000000000000000000000000000000000000)

        mstore(64, 0x0000000f5452414e534645525f4641494c454400000000000000000000000000)

        mstore(96, 0)

        revert(0, 100)

      }

    }



    requestEpoch[request.senderAddress][request.relayerAddress] = request.salt + 1;

  }

}



