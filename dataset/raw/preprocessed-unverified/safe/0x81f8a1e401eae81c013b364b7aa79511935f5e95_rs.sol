/**

 *Submitted for verification at Etherscan.io on 2019-03-18

*/



pragma solidity ^0.4.24;

















contract ERC725 {



    uint256 constant MANAGEMENT_KEY = 1;

    uint256 constant ACTION_KEY = 2;

    uint256 constant CLAIM_SIGNER_KEY = 3;

    uint256 constant ENCRYPTION_KEY = 4;



    event KeyAdded(bytes32 indexed key, uint256 indexed purpose, uint256 indexed keyType);

    event KeyRemoved(bytes32 indexed key, uint256 indexed purpose, uint256 indexed keyType);

    event ExecutionRequested(uint256 indexed executionId, address indexed to, uint256 indexed value, bytes data);

    event Executed(uint256 indexed executionId, address indexed to, uint256 indexed value, bytes data);

    event Approved(uint256 indexed executionId, bool approved);



    function getKey(bytes32 _key) public view returns(uint256[] purposes, uint256 keyType, bytes32 key);

    function keyHasPurpose(bytes32 _key, uint256 _purpose) public view returns (bool exists);

    function getKeysByPurpose(uint256 _purpose) public view returns(bytes32[] keys);

    function addKey(bytes32 _key, uint256 _purpose, uint256 _keyType) public returns (bool success);

    function removeKey(bytes32 _key, uint256 _purpose) public returns (bool success);

    function execute(address _to, uint256 _value, bytes _data) public returns (uint256 executionId);

    function approve(uint256 _id, bool _approve) public returns (bool success);

}





contract ERC735 {



    event ClaimRequested(uint256 indexed claimRequestId, uint256 indexed topic, uint256 scheme, address indexed issuer, bytes signature, bytes data, string uri);

    event ClaimAdded(bytes32 indexed claimId, uint256 indexed topic, uint256 scheme, address indexed issuer, bytes signature, bytes data, string uri);

    event ClaimRemoved(bytes32 indexed claimId, uint256 indexed topic, uint256 scheme, address indexed issuer, bytes signature, bytes data, string uri);

    event ClaimChanged(bytes32 indexed claimId, uint256 indexed topic, uint256 scheme, address indexed issuer, bytes signature, bytes data, string uri);



    struct Claim {

        uint256 topic;

        uint256 scheme;

        address issuer; // msg.sender

        bytes signature; // this.address + topic + data

        bytes data;

        string uri;

    }



    function getClaim(bytes32 _claimId) public view returns(uint256 topic, uint256 scheme, address issuer, bytes signature, bytes data, string uri);

    function getClaimIdsByTopic(uint256 _topic) public view returns(bytes32[] claimIds);

    function addClaim(uint256 _topic, uint256 _scheme, address issuer, bytes _signature, bytes _data, string _uri) public returns (bytes32 claimRequestId);

    function removeClaim(bytes32 _claimId) public returns (bool success);

}





contract KeyHolder is ERC725 {

    KeyHolderLibrary.KeyHolderData keyHolderData;



    constructor() public {

        KeyHolderLibrary.init(keyHolderData);

    }



    function getKey(bytes32 _key)

        public

        view

        returns(uint256[] purposes, uint256 keyType, bytes32 key)

    {

        return KeyHolderLibrary.getKey(keyHolderData, _key);

    }



    function getKeyPurposes(bytes32 _key)

        public

        view

        returns(uint256[] purposes)

    {

        return KeyHolderLibrary.getKeyPurposes(keyHolderData, _key);

    }



    function getKeysByPurpose(uint256 _purpose)

        public

        view

        returns(bytes32[] _keys)

    {

        return KeyHolderLibrary.getKeysByPurpose(keyHolderData, _purpose);

    }



    function addKey(bytes32 _key, uint256 _purpose, uint256 _type)

        public

        returns (bool success)

    {

        return KeyHolderLibrary.addKey(keyHolderData, _key, _purpose, _type);

    }



    function approve(uint256 _id, bool _approve)

        public

        returns (bool success)

    {

        return KeyHolderLibrary.approve(keyHolderData, _id, _approve);

    }



    function execute(address _to, uint256 _value, bytes _data)

        public

        returns (uint256 executionId)

    {

        return KeyHolderLibrary.execute(keyHolderData, _to, _value, _data);

    }



    function removeKey(bytes32 _key, uint256 _purpose)

        public

        returns (bool success)

    {

        return KeyHolderLibrary.removeKey(keyHolderData, _key, _purpose);

    }



    function keyHasPurpose(bytes32 _key, uint256 _purpose)

        public

        view

        returns(bool exists)

    {

        return KeyHolderLibrary.keyHasPurpose(keyHolderData, _key, _purpose);

    }



}





contract ClaimHolder is KeyHolder, ERC735 {



    ClaimHolderLibrary.Claims claims;



    function addClaim(

        uint256 _topic,

        uint256 _scheme,

        address _issuer,

        bytes _signature,

        bytes _data,

        string _uri

    )

        public

        returns (bytes32 claimRequestId)

    {

        return ClaimHolderLibrary.addClaim(

            keyHolderData,

            claims,

            _topic,

            _scheme,

            _issuer,

            _signature,

            _data,

            _uri

        );

    }



    function addClaims(

        uint256[] _topic,

        address[] _issuer,

        bytes _signature,

        bytes _data,

        uint256[] _offsets

    )

        public

    {

        ClaimHolderLibrary.addClaims(

            keyHolderData,

            claims,

            _topic,

            _issuer,

            _signature,

            _data,

            _offsets

        );

    }



    function removeClaim(bytes32 _claimId) public returns (bool success) {

        return ClaimHolderLibrary.removeClaim(keyHolderData, claims, _claimId);

    }



    function getClaim(bytes32 _claimId)

        public

        view

        returns(

            uint256 topic,

            uint256 scheme,

            address issuer,

            bytes signature,

            bytes data,

            string uri

        )

    {

        return ClaimHolderLibrary.getClaim(claims, _claimId);

    }



    function getClaimIdsByTopic(uint256 _topic)

        public

        view

        returns(bytes32[] claimIds)

    {

        return claims.byTopic[_topic];

    }

}





contract WhooseWallet is ClaimHolder {}