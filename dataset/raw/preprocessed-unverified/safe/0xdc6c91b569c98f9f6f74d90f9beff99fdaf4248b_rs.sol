/**

 *Submitted for verification at Etherscan.io on 2019-07-29

*/



// File: contract-utils/Zerox/IExchange.sol



/*



  Copyright 2018 ZeroEx Intl.



  Licensed under the Apache License, Version 2.0 (the "License");

  you may not use this file except in compliance with the License.

  You may obtain a copy of the License at



    http://www.apache.org/licenses/LICENSE-2.0



  Unless required by applicable law or agreed to in writing, software

  distributed under the License is distributed on an "AS IS" BASIS,

  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

  See the License for the specific language governing permissions and

  limitations under the License.



*/



pragma solidity ^0.5.0;

pragma experimental ABIEncoderV2;



contract IExchange {

  function executeTransaction(

        uint256 salt,

        address signerAddress,

        bytes calldata data,

        bytes calldata signature

  ) external;

}



// File: contract-utils/Zerox/LibEIP712.sol



/*



  Copyright 2018 ZeroEx Intl.



  Licensed under the Apache License, Version 2.0 (the "License");

  you may not use this file except in compliance with the License.

  You may obtain a copy of the License at



    http://www.apache.org/licenses/LICENSE-2.0



  Unless required by applicable law or agreed to in writing, software

  distributed under the License is distributed on an "AS IS" BASIS,

  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

  See the License for the specific language governing permissions and

  limitations under the License.



*/









contract LibEIP712 {



    // EIP191 header for EIP712 prefix

    string constant internal EIP191_HEADER = "\x19\x01";



    // EIP712 Domain Name value

    string constant internal EIP712_DOMAIN_NAME = "0x Protocol";



    // EIP712 Domain Version value

    string constant internal EIP712_DOMAIN_VERSION = "2";



    // Hash of the EIP712 Domain Separator Schema

    bytes32 constant internal EIP712_DOMAIN_SEPARATOR_SCHEMA_HASH = keccak256(abi.encodePacked(

        "EIP712Domain(",

        "string name,",

        "string version,",

        "address verifyingContract",

        ")"

    ));



    // Hash of the EIP712 Domain Separator data

    // solhint-disable-next-line var-name-mixedcase

    bytes32 public EIP712_DOMAIN_HASH;



    constructor ()

        public

    {

        EIP712_DOMAIN_HASH = keccak256(abi.encodePacked(

            EIP712_DOMAIN_SEPARATOR_SCHEMA_HASH,

            keccak256(bytes(EIP712_DOMAIN_NAME)),

            keccak256(bytes(EIP712_DOMAIN_VERSION)),

            bytes12(0),

            address(this)

        ));

    }



    /// @dev Calculates EIP712 encoding for a hash struct in this EIP712 Domain.

    /// @param hashStruct The EIP712 hash struct.

    /// @return EIP712 hash applied to this EIP712 Domain.

    function hashEIP712Message(bytes32 hashStruct)

        internal

        view

        returns (bytes32 result)

    {

        bytes32 eip712DomainHash = EIP712_DOMAIN_HASH;



        // Assembly for more efficient computing:

        // keccak256(abi.encodePacked(

        //     EIP191_HEADER,

        //     EIP712_DOMAIN_HASH,

        //     hashStruct    

        // ));



        assembly {

            // Load free memory pointer

            let memPtr := mload(64)



            mstore(memPtr, 0x1901000000000000000000000000000000000000000000000000000000000000)  // EIP191 header

            mstore(add(memPtr, 2), eip712DomainHash)                                            // EIP712 domain hash

            mstore(add(memPtr, 34), hashStruct)                                                 // Hash of struct



            // Compute hash

            result := keccak256(memPtr, 66)

        }

        return result;

    }

}



// File: contract-utils/Zerox/LibOrder.sol



/*



  Copyright 2018 ZeroEx Intl.



  Licensed under the Apache License, Version 2.0 (the "License");

  you may not use this file except in compliance with the License.

  You may obtain a copy of the License at



    http://www.apache.org/licenses/LICENSE-2.0



  Unless required by applicable law or agreed to in writing, software

  distributed under the License is distributed on an "AS IS" BASIS,

  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

  See the License for the specific language governing permissions and

  limitations under the License.



*/











contract LibOrder is

    LibEIP712

{

    // Hash for the EIP712 Order Schema

    bytes32 constant internal EIP712_ORDER_SCHEMA_HASH = keccak256(abi.encodePacked(

        "Order(",

        "address makerAddress,",

        "address takerAddress,",

        "address feeRecipientAddress,",

        "address senderAddress,",

        "uint256 makerAssetAmount,",

        "uint256 takerAssetAmount,",

        "uint256 makerFee,",

        "uint256 takerFee,",

        "uint256 expirationTimeSeconds,",

        "uint256 salt,",

        "bytes makerAssetData,",

        "bytes takerAssetData",

        ")"

    ));



    // A valid order remains fillable until it is expired, fully filled, or cancelled.

    // An order's state is unaffected by external factors, like account balances.

    enum OrderStatus {

        INVALID,                     // Default value

        INVALID_MAKER_ASSET_AMOUNT,  // Order does not have a valid maker asset amount

        INVALID_TAKER_ASSET_AMOUNT,  // Order does not have a valid taker asset amount

        FILLABLE,                    // Order is fillable

        EXPIRED,                     // Order has already expired

        FULLY_FILLED,                // Order is fully filled

        CANCELLED                    // Order has been cancelled

    }



    // solhint-disable max-line-length

    struct Order {

        address makerAddress;           // Address that created the order.      

        address takerAddress;           // Address that is allowed to fill the order. If set to 0, any address is allowed to fill the order.          

        address feeRecipientAddress;    // Address that will recieve fees when order is filled.      

        address senderAddress;          // Address that is allowed to call Exchange contract methods that affect this order. If set to 0, any address is allowed to call these methods.

        uint256 makerAssetAmount;       // Amount of makerAsset being offered by maker. Must be greater than 0.        

        uint256 takerAssetAmount;       // Amount of takerAsset being bid on by maker. Must be greater than 0.        

        uint256 makerFee;               // Amount of ZRX paid to feeRecipient by maker when order is filled. If set to 0, no transfer of ZRX from maker to feeRecipient will be attempted.

        uint256 takerFee;               // Amount of ZRX paid to feeRecipient by taker when order is filled. If set to 0, no transfer of ZRX from taker to feeRecipient will be attempted.

        uint256 expirationTimeSeconds;  // Timestamp in seconds at which order expires.          

        uint256 salt;                   // Arbitrary number to facilitate uniqueness of the order's hash.     

        bytes makerAssetData;           // Encoded data that can be decoded by a specified proxy contract when transferring makerAsset. The last byte references the id of this proxy.

        bytes takerAssetData;           // Encoded data that can be decoded by a specified proxy contract when transferring takerAsset. The last byte references the id of this proxy.

    }

    // solhint-enable max-line-length



    struct OrderInfo {

        uint8 orderStatus;                    // Status that describes order's validity and fillability.

        bytes32 orderHash;                    // EIP712 hash of the order (see LibOrder.getOrderHash).

        uint256 orderTakerAssetFilledAmount;  // Amount of order that has already been filled.

    }



    /// @dev Calculates Keccak-256 hash of the order.

    /// @param order The order structure.

    /// @return Keccak-256 EIP712 hash of the order.

    function getOrderHash(Order memory order)

        internal

        view

        returns (bytes32 orderHash)

    {

        orderHash = hashEIP712Message(hashOrder(order));

        return orderHash;

    }



    /// @dev Calculates EIP712 hash of the order.

    /// @param order The order structure.

    /// @return EIP712 hash of the order.

    function hashOrder(Order memory order)

        internal

        pure

        returns (bytes32 result)

    {

        bytes32 schemaHash = EIP712_ORDER_SCHEMA_HASH;

        bytes32 makerAssetDataHash = keccak256(order.makerAssetData);

        bytes32 takerAssetDataHash = keccak256(order.takerAssetData);



        // Assembly for more efficiently computing:

        // keccak256(abi.encodePacked(

        //     EIP712_ORDER_SCHEMA_HASH,

        //     bytes32(order.makerAddress),

        //     bytes32(order.takerAddress),

        //     bytes32(order.feeRecipientAddress),

        //     bytes32(order.senderAddress),

        //     order.makerAssetAmount,

        //     order.takerAssetAmount,

        //     order.makerFee,

        //     order.takerFee,

        //     order.expirationTimeSeconds,

        //     order.salt,

        //     keccak256(order.makerAssetData),

        //     keccak256(order.takerAssetData)

        // ));



        assembly {

            // Calculate memory addresses that will be swapped out before hashing

            let pos1 := sub(order, 32)

            let pos2 := add(order, 320)

            let pos3 := add(order, 352)



            // Backup

            let temp1 := mload(pos1)

            let temp2 := mload(pos2)

            let temp3 := mload(pos3)

            

            // Hash in place

            mstore(pos1, schemaHash)

            mstore(pos2, makerAssetDataHash)

            mstore(pos3, takerAssetDataHash)

            result := keccak256(pos1, 416)

            

            // Restore

            mstore(pos1, temp1)

            mstore(pos2, temp2)

            mstore(pos3, temp3)

        }

        return result;

    }

}



// File: contract-utils/Zerox/LibBytes.sol



/*



  Copyright 2018 ZeroEx Intl.



  Licensed under the Apache License, Version 2.0 (the "License");

  you may not use this file except in compliance with the License.

  You may obtain a copy of the License at



    http://www.apache.org/licenses/LICENSE-2.0



  Unless required by applicable law or agreed to in writing, software

  distributed under the License is distributed on an "AS IS" BASIS,

  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

  See the License for the specific language governing permissions and

  limitations under the License.



*/













// File: contract-utils/Zerox/LibDecoder.sol









contract LibDecoder {

    using LibBytes for bytes;



    function decodeFillOrder(bytes memory data) internal pure returns(LibOrder.Order memory order, uint256 takerFillAmount, bytes memory mmSignature) {

        require(

            data.length > 800,

            "LENGTH_LESS_800"

        );



        // compare method_id

        // 0x64a3bc15 is fillOrKillOrder's method id.

        require(

            data.readBytes4(0) == 0x64a3bc15,

            "WRONG_METHOD_ID"

        );

        

        bytes memory dataSlice;

        assembly {

            dataSlice := add(data, 4)

        }

        //return (order, takerFillAmount, data);

        return abi.decode(dataSlice, (LibOrder.Order, uint256, bytes));



    }



    function decodeMmSignatureWithoutSign(bytes memory signature) internal pure returns(address user, uint16 feeFactor) {

        require(

            signature.length == 87 || signature.length == 88,

            "LENGTH_87_REQUIRED"

        );



        user = signature.readAddress(65);

        feeFactor = uint16(signature.readBytes2(85));

        

        require(

            feeFactor < 10000,

            "FEE_FACTOR_MORE_THEN_10000"

        );



        return (user, feeFactor);

    }



    function decodeMmSignature(bytes memory signature) internal pure returns(uint8 v, bytes32 r, bytes32 s, address user, uint16 feeFactor) {

        (user, feeFactor) = decodeMmSignatureWithoutSign(signature);



        v = uint8(signature[0]);

        r = signature.readBytes32(1);

        s = signature.readBytes32(33);



        return (v, r, s, user, feeFactor);

    }



    function decodeUserSignatureWithoutSign(bytes memory signature) internal pure returns(address receiver) {

        require(

            signature.length == 85 || signature.length == 86,

            "LENGTH_85_REQUIRED"

        );

        receiver = signature.readAddress(65);



        return receiver;

    }



    function decodeUserSignature(bytes memory signature) internal pure returns(uint8 v, bytes32 r, bytes32 s, address receiver) {

        receiver = decodeUserSignatureWithoutSign(signature);



        v = uint8(signature[0]);

        r = signature.readBytes32(1);

        s = signature.readBytes32(33);



        return (v, r, s, receiver);

    }



    function decodeERC20Asset(bytes memory assetData) internal pure returns(address) {

        require(

            assetData.length == 36,

            "LENGTH_65_REQUIRED"

        );



        return assetData.readAddress(16);

    }

}



// File: contract-utils/Zerox/LibEncoder.sol









contract LibEncoder is

    LibEIP712

{

    // Hash for the EIP712 ZeroEx Transaction Schema

    bytes32 constant internal EIP712_ZEROEX_TRANSACTION_SCHEMA_HASH = keccak256(

        abi.encodePacked(

        "ZeroExTransaction(",

        "uint256 salt,",

        "address signerAddress,",

        "bytes data",

        ")"

    ));



    function encodeTransactionHash(

        uint256 salt,

        address signerAddress,

        bytes memory data

    )

        internal

        view 

        returns (bytes32 result)

    {

        bytes32 schemaHash = EIP712_ZEROEX_TRANSACTION_SCHEMA_HASH;

        bytes32 dataHash = keccak256(data);



        // Assembly for more efficiently computing:

        // keccak256(abi.encodePacked(

        //     EIP712_ZEROEX_TRANSACTION_SCHEMA_HASH,

        //     salt,

        //     bytes32(signerAddress),

        //     keccak256(data)

        // ));



        assembly {

            // Load free memory pointer

            let memPtr := mload(64)



            mstore(memPtr, schemaHash)                                                               // hash of schema

            mstore(add(memPtr, 32), salt)                                                            // salt

            mstore(add(memPtr, 64), and(signerAddress, 0xffffffffffffffffffffffffffffffffffffffff))  // signerAddress

            mstore(add(memPtr, 96), dataHash)                                                        // hash of data



            // Compute hash

            result := keccak256(memPtr, 128)

        }

        result = hashEIP712Message(result);

        return result;

    }

}



// File: contract-utils/Ownable/IOwnable.sol







contract IOwnable {

  function transferOwnership(address newOwner) public;



  function setOperator(address newOwner) public;

}



// File: contract-utils/Ownable/Ownable.sol











contract Ownable is

  IOwnable

{

  address public owner;

  address public operator;



  constructor ()

    public

  {

    owner = msg.sender;

  }



  modifier onlyOwner() {

    require(

      msg.sender == owner,

      "ONLY_CONTRACT_OWNER"

    );

    _;

  }



  modifier onlyOperator() {

    require(

      msg.sender == operator,

      "ONLY_CONTRACT_OPERATOR"

    );

    _;

  }



  function transferOwnership(address newOwner)

    public

    onlyOwner

  {

    if (newOwner != address(0)) {

      owner = newOwner;

    }

  }



  function setOperator(address newOperator)

    public

    onlyOwner 

  {

    operator = newOperator;

  }

}



// File: contract-utils/Interface/IUserProxy.sol







contract IUserProxy {

    function receiveToken(address tokenAddr, address userAddr, uint256 amount) external;



    function sendToken(address tokenAddr, address userAddr, uint256 amount) external;



    function receiveETH(address wethAddr) payable external;



    function sendETH(address wethAddr, address payable userAddr, uint256 amount) external;

}



// File: openzeppelin-solidity/contracts/math/SafeMath.sol







/**

 * @title SafeMath

 * @dev Unsigned math operations with safety checks that revert on error

 */





// File: contracts/TokenlonExchange.sol







contract TokenlonExchange is 

    Ownable,

    LibDecoder,

    LibEncoder

{

    string public version = "0.0.3";



    IExchange internal ZX_EXCHANGE;

    IUserProxy internal USER_PROXY; 

    address internal WETH_ADDR;



    // exchange is enabled

    bool public isEnabled = false;



    // marketMakerProxy white list:

    mapping(address=>bool) public isMarketMakerProxy;



    // executeTxHash => user

    mapping(bytes32=>address) public transactions;



    constructor () public {

        owner = msg.sender;

        operator = msg.sender;

    }



    // events

    event FillOrder(

        bytes32 indexed executeTxHash,

        address indexed userAddr,

        address receiverAddr,

        uint256 filledAmount, 

        uint256 acutalMakerAssetAmount

    );



    // fillOrder with token

    // sender is any external accounts

    // 0x order successed send eth to user

    function fillOrderWithToken(

        uint256 userSalt,

        bytes memory data,

        bytes memory userSignature

    )

        public

    {

        require(isEnabled, "EXCHANGE_DISABLED");



        // decode & assert

        (LibOrder.Order memory order,

        address user,

        address receiver,

        uint16 feeFactor,

        address makerAssetAddr,

        address takerAssetAddr,

        bytes32 transactionHash) = assertTransaction(userSalt, data, userSignature);



        // saved transaction

        transactions[transactionHash] = user;



        // USER_PROXY transfer user's token

        USER_PROXY.receiveToken(takerAssetAddr, user, order.takerAssetAmount);



        // send tx to 0x

        ZX_EXCHANGE.executeTransaction(

            userSalt,

            address(USER_PROXY),

            data,

            userSignature

        );



        // settle token/ETH to user

        uint256 acutalMakerAssetAmount = settle(receiver, makerAssetAddr, order.makerAssetAmount, feeFactor);



        emit FillOrder(transactionHash, user, receiver, order.takerAssetAmount, acutalMakerAssetAmount);

    }



    function fillOrderWithETH(

        uint256 userSalt,

        bytes memory data,

        bytes memory userSignature

    )

        public

        payable

    {

        require(isEnabled, "EXCHANGE_DISABLED");



        // decode & assert

        (LibOrder.Order memory order,

        address user,

        address receiver,

        uint16 feeFactor,

        address makerAssetAddr,

        address takerAssetAddr,

        bytes32 transactionHash) = assertTransaction(userSalt, data, userSignature);



        require(

            msg.sender == user,

            "SENDER_IS_NOT_USER"

        );



        require(

            WETH_ADDR == takerAssetAddr,

            "USER_ASSET_NOT_WETH"

        );



        require(

            msg.value == order.takerAssetAmount,

            "ETH_NOT_ENOUGH"

        );



        // saved transaction

        transactions[transactionHash] = user;



        // USER_PROXY receive eth from TokenlonExchange

        USER_PROXY.receiveETH.value(msg.value)(WETH_ADDR);



        // send tx to 0x

        ZX_EXCHANGE.executeTransaction(

            userSalt,

            address(USER_PROXY),

            data,

            userSignature

        );



        // settle token/ETH to user

        uint256 acutalMakerAssetAmount = settle(receiver, makerAssetAddr, order.makerAssetAmount, feeFactor);



        emit FillOrder(transactionHash, user, receiver, order.takerAssetAmount, acutalMakerAssetAmount);

    }



    // assert & decode transaction

    function assertTransaction(uint256 userSalt, bytes memory data, bytes memory userSignature)

    public view returns(

        LibOrder.Order memory order,

        address user,

        address receiver,

        uint16 feeFactor,

        address makerAssetAddr,

        address takerAssetAddr,

        bytes32 transactionHash

    ){

        // decode fillOrder data

        uint256 takerFillAmount;

        bytes memory mmSignature;

        (order, takerFillAmount, mmSignature) = decodeFillOrder(data);



        require(

            this.isMarketMakerProxy(order.makerAddress),

            "MAKER_ADDRESS_ERROR"

        );



        require(

            order.takerAddress == address(USER_PROXY),

            "TAKER_ADDRESS_ERROR"

        );

        require(

            order.takerAssetAmount == takerFillAmount,

            "FIll_AMOUNT_ERROR"

        );



        // generate transactionHash

        transactionHash = encodeTransactionHash(

            userSalt,

            address(USER_PROXY),

            data

        );



        require(

            transactions[transactionHash] == address(0),

            "EXECUTED_TX_HASH"

        );



        // decode mmSignature

        (user, feeFactor) = decodeMmSignatureWithoutSign(mmSignature);



        require(

            feeFactor < 10000,

            "FEE_FACTOR_MORE_THEN_10000"

        );



        // decode userSignature

        receiver = decodeUserSignatureWithoutSign(userSignature);



        require(

            receiver != address(0),

            "INVALID_RECIVER"

        );



        // decode asset

        // just support ERC20

        makerAssetAddr = decodeERC20Asset(order.makerAssetData);

        takerAssetAddr = decodeERC20Asset(order.takerAssetData);



        return (

            order,

            user,

            receiver,

            feeFactor,

            makerAssetAddr,

            takerAssetAddr,

            transactionHash

        );        

    }



    // settle

    function settle(address receiver, address makerAssetAddr, uint256 makerAssetAmount, uint16 feeFactor) internal returns(uint256) {

        uint256 settleAmount = deductFee(makerAssetAmount, feeFactor);



        if (makerAssetAddr == WETH_ADDR){

            USER_PROXY.sendETH(WETH_ADDR, address(uint160(receiver)), settleAmount);

        } else {

            USER_PROXY.sendToken(makerAssetAddr, receiver, settleAmount);

        }



        return settleAmount;

    }



    // deduct fee

    function deductFee(uint256 makerAssetAmount, uint16 feeFactor) internal pure returns (uint256) {

        if(feeFactor == 0) {

            return makerAssetAmount;

        }



        uint256 fee = SafeMath.div(SafeMath.mul(makerAssetAmount, feeFactor), 10000);

        return SafeMath.sub(makerAssetAmount, fee);

    }



    // manage 

    function registerMMP(address _marketMakerProxy, bool _add) public onlyOperator {

        isMarketMakerProxy[_marketMakerProxy] = _add;

    }



    function setProxy(IExchange _exchange, IUserProxy _userProxy, address _weth) public onlyOperator {

        ZX_EXCHANGE = _exchange;

        USER_PROXY = _userProxy;

        WETH_ADDR = _weth;



        // this const follow ZX_EXCHANGE address

        // encodeTransactionHash depend ZX_EXCHANGE address

        EIP712_DOMAIN_HASH = keccak256(

            abi.encodePacked(

                EIP712_DOMAIN_SEPARATOR_SCHEMA_HASH,

                keccak256(bytes(EIP712_DOMAIN_NAME)),

                keccak256(bytes(EIP712_DOMAIN_VERSION)),

                bytes12(0),

                address(ZX_EXCHANGE)

            )

        );

    }



    function setEnabled(bool _enable) public onlyOperator {

        isEnabled = _enable;

    }



}