/**

 *Submitted for verification at Etherscan.io on 2019-06-10

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



    function addKeys(bytes32[] _keys, uint256 _purpose, uint256 _type)

        public

        returns (bool success)

    {

        return KeyHolderLibrary.addKeys(keyHolderData, _keys, _purpose, _type);

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



contract WhooseWallet is ClaimHolder {

    address whooseWalletAdminAddress = 0x0000000000000000000000000000000000000000;



    constructor() public {

        bytes32 _admin = keccak256(abi.encodePacked(whooseWalletAdminAddress));

        addKey(_admin, 1, 1);



        WhooseWalletAdmin _walletAdmin = WhooseWalletAdmin(whooseWalletAdminAddress);

        _walletAdmin.addContract(address(this));

    }



    function destruct() public {

        if (msg.sender != address(this) && whooseWalletAdminAddress != address(this)) {

            bytes32 sender = keccak256(abi.encodePacked(msg.sender));

            require(KeyHolderLibrary.keyHasPurpose(keyHolderData, sender, 1), "Sender does not have management key");

        }



        selfdestruct(whooseWalletAdminAddress);

    }

}



contract managed {

    address public admin;



    constructor() public {

        admin = msg.sender;

    }



    modifier onlyAdmin {

        require(msg.sender == admin);

        _;

    }



    function transferOwnership(address newAdmin) onlyAdmin public {

        admin = newAdmin;

    }

}



contract WhooseWalletAdmin is managed {

    mapping(address => address) contracts;



    function addContract(address addr) public returns(bool success) {

        contracts[addr] = addr;

        return true;

    }



    function removeContract(address addr) public onlyAdmin returns(bool success) {

        delete contracts[addr];

        return true;

    }



    function getContract(address addr) public view onlyAdmin returns(address addr_res) {

        return contracts[addr];

    }



    // ERC725

    function getKey(address _walletAddress, bytes32 _key)

        public view onlyAdmin returns(uint256[] purposes, uint256 keyType, bytes32 key) {

        WhooseWallet _wallet = WhooseWallet(_walletAddress);

        return _wallet.getKey(_key);

    }



    function keyHasPurpose(address _walletAddress, bytes32 _key, uint256 _purpose)

        public view onlyAdmin returns (bool exists) {

        WhooseWallet _wallet = WhooseWallet(_walletAddress);

        return _wallet.keyHasPurpose(_key, _purpose);

    }



    function getKeysByPurpose(address _walletAddress, uint256 _purpose)

        public view onlyAdmin returns(bytes32[] keys) {

        WhooseWallet _wallet = WhooseWallet(_walletAddress);

        return _wallet.getKeysByPurpose(_purpose);

    }



    function addKey(address _walletAddress, bytes32 _key, uint256 _purpose, uint256 _keyType)

        public onlyAdmin returns (bool success) {

        WhooseWallet _wallet = WhooseWallet(_walletAddress);

        return _wallet.addKey(_key, _purpose, _keyType);

    }



    function addKeys(address _walletAddress, bytes32[] _keys, uint256 _purpose, uint256 _keyType)

        public onlyAdmin returns (bool success) {

        WhooseWallet _wallet = WhooseWallet(_walletAddress);

        return _wallet.addKeys(_keys, _purpose, _keyType);

    }



    function removeKey(address _walletAddress, bytes32 _key, uint256 _purpose)

        public onlyAdmin returns (bool success) {

        WhooseWallet _wallet = WhooseWallet(_walletAddress);

        return _wallet.removeKey(_key, _purpose);

    }



    function execute(address _walletAddress, address _to, uint256 _value, bytes _data)

        public onlyAdmin returns (uint256 executionId) {

        WhooseWallet _wallet = WhooseWallet(_walletAddress);

        return _wallet.execute(_to, _value, _data);

    }



    function approve(address _walletAddress, uint256 _id, bool _approve)

        public onlyAdmin returns (bool success) {

        WhooseWallet _wallet = WhooseWallet(_walletAddress);

        return _wallet.approve(_id, _approve);

    }



    // ERC735

    function getClaim(address _walletAddress, bytes32 _claimId)

        public onlyAdmin view returns(uint256 topic, uint256 scheme, address issuer, bytes signature, bytes data, string uri) {

        WhooseWallet _wallet = WhooseWallet(_walletAddress);

        return _wallet.getClaim(_claimId);

    }



    function getClaimIdsByTopic(address _walletAddress, uint256 _topic)

        public onlyAdmin view returns(bytes32[] claimIds) {

        WhooseWallet _wallet = WhooseWallet(_walletAddress);

        return _wallet.getClaimIdsByTopic(_topic);

    }



    function addClaim(address _walletAddress, uint256 _topic, uint256 _scheme, address issuer, bytes _signature, bytes _data, string _uri)

        public onlyAdmin returns (bytes32 claimRequestId) {

        WhooseWallet _wallet = WhooseWallet(_walletAddress);

        return _wallet.addClaim(_topic, _scheme, issuer, _signature, _data, _uri);

    }



    function removeClaim(address _walletAddress, bytes32 _claimId)

        public onlyAdmin returns (bool success) {

        WhooseWallet _wallet = WhooseWallet(_walletAddress);

        return _wallet.removeClaim(_claimId);

    }



    function kill(address _walletAddress)

        public onlyAdmin returns (bool success) {

        WhooseWallet _wallet = WhooseWallet(_walletAddress);

        _wallet.destruct();

        return true;

    }

}